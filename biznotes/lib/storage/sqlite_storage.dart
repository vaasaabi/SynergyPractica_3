import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/note.dart';
import 'note_storage.dart';

/// Локальное хранение заметок в реляционной базе данных SQLite.
class SqliteStorage implements NoteStorage {
  Database? _db;

  @override
  Future<void> init() async {
    if (_db != null) return;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'biznotes.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            date TEXT,
            time TEXT,
            content TEXT,
            updatedAt INTEGER
          )
        ''');
      },
    );
  }

  Future<Database> get _database async {
    await init();
    return _db!;
  }

  @override
  Future<List<Note>> getAll() async {
    final db = await _database;
    final rows = await db.query('notes', orderBy: 'updatedAt DESC');
    return rows.map(Note.fromMap).toList();
  }

  @override
  Future<Note> add(Note note) async {
    final db = await _database;
    final id = await db.insert('notes', note.toMap());
    return note.copyWith(id: id);
  }

  @override
  Future<void> update(Note note) async {
    final db = await _database;
    await db.update('notes', note.toMap(),
        where: 'id = ?', whereArgs: [note.id]);
  }

  @override
  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Note>> search(String query) async {
    final db = await _database;
    final q = '%$query%';
    final rows = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ? OR date LIKE ? OR time LIKE ?',
      whereArgs: [q, q, q, q],
      orderBy: 'updatedAt DESC',
    );
    return rows.map(Note.fromMap).toList();
  }
}
