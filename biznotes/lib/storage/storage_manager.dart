import 'package:shared_preferences/shared_preferences.dart';

import 'file_storage.dart';
import 'note_storage.dart';
import 'sqlite_storage.dart';

enum StorageMode { sqlite, file }

/// Управляет выбором активного хранилища и запоминает выбор пользователя.
/// Заметки в режимах SQLite и «Файловая система» хранятся независимо.
class StorageManager {
  StorageManager._();
  static final StorageManager instance = StorageManager._();

  final SqliteStorage _sqlite = SqliteStorage();
  final FileStorage _file = FileStorage();
  StorageMode _mode = StorageMode.sqlite;

  StorageMode get mode => _mode;

  NoteStorage get storage =>
      _mode == StorageMode.sqlite ? _sqlite : _file;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = prefs.getString('storage_mode') == 'file'
        ? StorageMode.file
        : StorageMode.sqlite;
    await storage.init();
  }

  Future<void> setMode(StorageMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'storage_mode', mode == StorageMode.file ? 'file' : 'sqlite');
    await storage.init();
  }
}
