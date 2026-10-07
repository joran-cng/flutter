import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/event_draft.dart';

class DraftFileInfo {
  const DraftFileInfo({
    required this.draftId,
    required this.filePath,
    required this.fileSizeBytes,
    required this.lastModified,
    required this.parseResult,
  });

  final String draftId;
  final String filePath;
  final int fileSizeBytes;
  final DateTime lastModified;
  final DraftParseResult parseResult;

  String get displayTitle {
    if (!parseResult.isSuccess) {
      return '(brouillon illisible)';
    }
    final title = parseResult.draft!.title.trim();
    return title.isEmpty ? '(sans titre)' : title;
  }
}

class DraftRepository {
  DraftRepository._();

  static final DraftRepository instance = DraftRepository._();

  Directory? _draftsDir;
  static const _draftsFolderName = 'event_drafts';
  static const _fileSuffix = '.json';

  Future<void> init() async {
    _draftsDir = await _ensureDraftsDirectory();
    await purgeOldTemporaryFiles(maxAgeDays: 7);
  }

  Future<Directory> _ensureDraftsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}$_draftsFolderName');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String safeFileNameForId(String id) {
    final sanitized = id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return 'draft_$sanitized$_fileSuffix';
  }

  File _fileForId(String id) {
    final dir = _draftsDir;
    if (dir == null) {
      throw StateError('DraftRepository.init() required.');
    }
    return File('${dir.path}${Platform.pathSeparator}${safeFileNameForId(id)}');
  }

  Future<void> saveDraft(EventDraft draft) async {
    await init();
    final target = _fileForId(draft.id);
    final temp = File('${target.path}.tmp');
    final updated = draft.copyWith(lastModified: DateTime.now());
    final payload = jsonEncode(updated.toJson());
    await temp.writeAsString(payload, flush: true);
    if (target.existsSync()) {
      await target.delete();
    }
    await temp.rename(target.path);
  }

  Future<DraftParseResult> loadDraft(String id) async {
    await init();
    final file = _fileForId(id);
    if (!file.existsSync()) {
      return DraftParseResult.success(EventDraft.empty(id: id));
    }
    final length = await file.length();
    if (length == 0) {
      return DraftParseResult.success(EventDraft.empty(id: id));
    }
    final body = await file.readAsString();
    final result = parseDraftJson(body);
    if (result.isSuccess) {
      return result;
    }
    return result;
  }

  Future<List<DraftFileInfo>> listDrafts() async {
    await init();
    final dir = _draftsDir!;
    if (!dir.existsSync()) {
      return [];
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith(_fileSuffix))
        .where((file) => !file.path.endsWith('$_fileSuffix.tmp'))
        .toList();

    final bodies = <String>[];
    final metas = <({File file, int size, DateTime modified})>[];

    for (final file in files) {
      final stat = await file.stat();
      final body = await file.readAsString();
      bodies.add(body);
      metas.add((file: file, size: stat.size, modified: stat.modified));
    }

    final parsed = await compute(parseDraftBodiesInBackground, bodies);

    final entries = <DraftFileInfo>[];
    for (var i = 0; i < files.length; i++) {
      final name = metas[i].file.uri.pathSegments.last;
      final id = _idFromFileName(name);
      entries.add(
        DraftFileInfo(
          draftId: id,
          filePath: metas[i].file.path,
          fileSizeBytes: metas[i].size,
          lastModified: metas[i].modified,
          parseResult: parsed[i],
        ),
      );
    }

    entries.sort(
      (a, b) => b.lastModified.compareTo(a.lastModified),
    );
    return entries;
  }

  String _idFromFileName(String name) {
    var base = name;
    if (base.startsWith('draft_')) {
      base = base.substring(6);
    }
    if (base.endsWith(_fileSuffix)) {
      base = base.substring(0, base.length - _fileSuffix.length);
    }
    return base;
  }

  Future<void> deleteDraft(String id) async {
    await init();
    final file = _fileForId(id);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> deleteAllDrafts() async {
    await init();
    final dir = _draftsDir!;
    if (!dir.existsSync()) {
      return;
    }
    for (final entity in dir.listSync()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }

  Future<void> purgeOldTemporaryFiles({required int maxAgeDays}) async {
    final tempDir = await getTemporaryDirectory();
    if (!tempDir.existsSync()) {
      return;
    }
    final cutoff = DateTime.now().subtract(Duration(days: maxAgeDays));
    for (final entity in tempDir.listSync()) {
      if (entity is! File) {
        continue;
      }
      if (!entity.path.endsWith('.tmp')) {
        continue;
      }
      final modified = await entity.lastModified();
      if (modified.isBefore(cutoff)) {
        await entity.delete();
      }
    }
  }
}
