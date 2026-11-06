import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/note.dart';
import 'note_storage.dart';

/// Хранение заметок в файловой системе устройства:
/// каждая заметка сохраняется отдельным JSON-файлом в подкаталоге notes/.
class FileStorage implements NoteStorage {
  Directory? _dir;

  @override
  Future<void> init() async {
    if (_dir != null) return;
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'notes'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _dir = dir;
  }

  Future<Directory> get _directory async {
    await init();
    return _dir!;
  }

  File _fileFor(int id) => File(p.join(_dir!.path, '$id.json'));

  @override
  Future<List<Note>> getAll() async {
    final dir = await _directory;
    final notes = <Note>[];
    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final map =
              jsonDecode(await entity.readAsString()) as Map<String, dynamic>;
          notes.add(Note.fromMap(map));
        } catch (_) {
          // повреждённые файлы пропускаем
        }
      }
    }
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<Note> add(Note note) async {
    await _directory;
    var id = DateTime.now().microsecondsSinceEpoch;
    while (await _fileFor(id).exists()) {
      id++;
    }
    final saved = note.copyWith(id: id);
    await _fileFor(id).writeAsString(jsonEncode(saved.toMap()));
    return saved;
  }

  @override
  Future<void> update(Note note) async {
    await _directory;
    if (note.id == null) return;
    await _fileFor(note.id!).writeAsString(jsonEncode(note.toMap()));
  }

  @override
  Future<void> delete(int id) async {
    await _directory;
    final file = _fileFor(id);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<List<Note>> search(String query) async {
    final all = await getAll();
    final q = query.toLowerCase();
    return all
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q) ||
            n.date.contains(q) ||
            n.time.contains(q))
        .toList();
  }
}
