import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/participant.dart';
import 'exceptions.dart';

class UsersPageResult {
  const UsersPageResult({
    required this.users,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<Participant> users;
  final int total;
  final int skip;
  final int limit;
}

UsersPageResult parseUsersPageFromJson(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const DecodingException('Réponse illisible du service.');
    }

    final usersJson = decoded['users'];
    final users = <Participant>[];
    if (usersJson is List) {
      for (final item in usersJson) {
        if (item is Map<String, dynamic>) {
          users.add(Participant.fromJson(item));
        }
      }
    }

    return UsersPageResult(
      users: users,
      total: _readInt(decoded['total']),
      skip: _readInt(decoded['skip']),
      limit: _readInt(decoded['limit'], fallback: 20),
    );
  } on FormatException {
    throw const DecodingException('Réponse illisible du service.');
  }
}

Participant parseParticipantFromJson(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const DecodingException('Réponse illisible du service.');
    }
    return Participant.fromJson(decoded);
  } on FormatException {
    throw const DecodingException('Réponse illisible du service.');
  }
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value == null) {
    return fallback;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

class UsersApi {
  UsersApi({
    http.Client? client,
    this.simulateDelay = false,
    this.forceServerError = false,
    this.requestTimeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  static const _host = 'dummyjson.com';

  final http.Client _client;
  final bool simulateDelay;
  final bool forceServerError;
  final Duration requestTimeout;

  void close() {
    _client.close();
  }

  void _logRequest(String label, Uri uri) {
    final stamp = DateTime.now().toIso8601String();
    debugPrint('[UsersApi $stamp] $label → ${uri.path}?${uri.query}');
  }

  Future<UsersPageResult> fetchUsers({
    int limit = 20,
    int skip = 0,
  }) async {
    if (forceServerError) {
      final uri = Uri.https(_host, '/http/500');
      _logRequest('fetchUsers (500 forcé)', uri);
      await _executeWithRetry(() => _get(uri));
    }

    final query = <String, String>{
      'limit': '$limit',
      'skip': '$skip',
      'select': 'firstName,lastName,email,image,company',
    };
    if (simulateDelay) {
      query['delay'] = '1500';
    }

    final uri = Uri.https(_host, '/users', query);
    _logRequest('fetchUsers', uri);
    final body = await _executeWithRetry(() => _get(uri));
    return compute(parseUsersPageFromJson, body);
  }

  Future<UsersPageResult> searchUsers(
    String query, {
    int limit = 10,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return fetchUsers(limit: limit, skip: 0);
    }

    final params = <String, String>{
      'q': trimmed,
      'limit': '$limit',
    };
    if (simulateDelay) {
      params['delay'] = '1500';
    }

    final uri = Uri.https(_host, '/users/search', params);
    _logRequest('searchUsers', uri);
    final body = await _executeWithRetry(() => _get(uri));
    return compute(parseUsersPageFromJson, body);
  }

  Future<Participant> fetchUserById(int id) async {
    final uri = Uri.https(_host, '/users/$id');
    _logRequest('fetchUserById', uri);
    final body = await _executeWithRetry(() => _get(uri));
    return parseParticipantFromJson(body);
  }

  Future<Participant> addParticipant({
    required String firstName,
    required String lastName,
  }) async {
    final uri = Uri.https(_host, '/users/add');
    _logRequest('addParticipant (POST)', uri);
    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'firstName': firstName,
              'lastName': lastName,
            }),
          )
          .timeout(requestTimeout);
      final body = _responseBodyOrThrow(response);
      return parseParticipantFromJson(body);
    } on FormatException {
      throw const DecodingException(
        'Données reçues illisibles. Réessayez plus tard.',
      );
    } on TimeoutException {
      throw const NetworkException(
        'Délai dépassé. Vérifiez votre connexion et réessayez.',
      );
    } on http.ClientException catch (error) {
      throw NetworkException(
        'Connexion impossible : ${error.message}',
      );
    }
  }

  Future<String> _get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(requestTimeout);
      return _responseBodyOrThrow(response);
    } on TimeoutException {
      throw const NetworkException(
        'Délai dépassé. Vérifiez votre connexion et réessayez.',
      );
    } on http.ClientException catch (error) {
      throw NetworkException(
        'Connexion impossible : ${error.message}',
      );
    }
  }

  Future<String> _executeWithRetry(
    Future<String> Function() action,
  ) async {
    const delays = [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ];

    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await action();
      } on NotFoundException {
        rethrow;
      } on DecodingException {
        rethrow;
      } on ApiException catch (error) {
        lastError = error;
        final retryable = error is NetworkException ||
            (error is ServerException && error.statusCode >= 500);
        if (!retryable || attempt == 2) {
          rethrow;
        }
        final wait = delays[attempt];
        debugPrint(
          '[UsersApi ${DateTime.now().toIso8601String()}] '
          'nouvelle tentative dans ${wait.inSeconds}s (${attempt + 2}/3)',
        );
        await Future<void>.delayed(wait);
      }
    }

    throw lastError ?? const NetworkException('Erreur réseau inconnue.');
  }

  String _responseBodyOrThrow(http.Response response) {
    final code = response.statusCode;
    if (code == 404) {
      throw const NotFoundException('Participant introuvable.');
    }
    if (code >= 500) {
      throw ServerException(
        'Le service est momentanément indisponible, veuillez réessayer.',
        code,
      );
    }
    if (code >= 200 && code < 300) {
      return response.body;
    }
    throw ServerException(
      'Le service a répondu avec une erreur ($code).',
      code,
    );
  }
}
