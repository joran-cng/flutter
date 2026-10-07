import 'dart:convert';

class EventDraft {
  EventDraft({
    required this.id,
    required this.title,
    required this.location,
    this.eventDate,
    required this.category,
    required this.lastModified,
    this.reminderEnabled = false,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 2;

  final String id;
  final String title;
  final String location;
  final DateTime? eventDate;
  final String category;
  final DateTime lastModified;
  final bool reminderEnabled;
  final int schemaVersion;

  EventDraft copyWith({
    String? title,
    String? location,
    DateTime? eventDate,
    String? category,
    DateTime? lastModified,
    bool? reminderEnabled,
  }) {
    return EventDraft(
      id: id,
      title: title ?? this.title,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      category: category ?? this.category,
      lastModified: lastModified ?? this.lastModified,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      schemaVersion: schemaVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': currentSchemaVersion,
      'id': id,
      'title': title,
      'location': location,
      'eventDate': eventDate?.toIso8601String(),
      'category': category,
      'lastModified': lastModified.toIso8601String(),
      'reminderEnabled': reminderEnabled,
    };
  }

  factory EventDraft.fromJson(Map<String, dynamic> json) {
    final version = _readInt(json['schemaVersion'], fallback: 1);
    if (version <= 1) {
      return EventDraft(
        id: _readString(json['id'], fallback: _generateId()),
        title: _readString(json['title']),
        location: _readString(json['city']),
        eventDate: _readDate(json['eventDate']),
        category: _readString(json['category']),
        lastModified: _readDate(json['lastModified']) ?? DateTime.now(),
        reminderEnabled: false,
        schemaVersion: currentSchemaVersion,
      );
    }

    return EventDraft(
      id: _readString(json['id'], fallback: _generateId()),
      title: _readString(json['title']),
      location: _readString(json['location']),
      eventDate: _readDate(json['eventDate']),
      category: _readString(json['category']),
      lastModified: _readDate(json['lastModified']) ?? DateTime.now(),
      reminderEnabled: json['reminderEnabled'] == true,
      schemaVersion: currentSchemaVersion,
    );
  }

  factory EventDraft.empty({String? id}) {
    final now = DateTime.now();
    return EventDraft(
      id: id ?? _generateId(),
      title: '',
      location: '',
      category: '',
      lastModified: now,
    );
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  static int _readInt(Object? value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  static String _readString(Object? value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }

  static DateTime? _readDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

class DraftParseResult {
  const DraftParseResult.success(this.draft) : errorMessage = null;

  const DraftParseResult.failure(this.errorMessage) : draft = null;

  final EventDraft? draft;
  final String? errorMessage;

  bool get isSuccess => draft != null;
}

DraftParseResult parseDraftJson(String body) {
  if (body.trim().isEmpty) {
    return DraftParseResult.success(EventDraft.empty());
  }
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      return const DraftParseResult.failure('Brouillon illisible.');
    }
    return DraftParseResult.success(EventDraft.fromJson(decoded));
  } catch (_) {
    return const DraftParseResult.failure('Brouillon illisible.');
  }
}

List<DraftParseResult> parseDraftBodiesInBackground(List<String> bodies) {
  return bodies.map(parseDraftJson).toList();
}
