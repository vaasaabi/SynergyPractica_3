import '../models/note.dart';

/// Единый интерфейс хранилища заметок.
/// Две реализации: SQLite (sqflite) и файловая система (JSON-файлы).
abstract class NoteStorage {
  Future<void> init();
  Future<List<Note>> getAll();
  Future<Note> add(Note note);
  Future<void> update(Note note);
  Future<void> delete(int id);
  Future<List<Note>> search(String query);
}
