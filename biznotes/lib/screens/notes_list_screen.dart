import 'package:flutter/material.dart';

import '../models/note.dart';
import '../storage/storage_manager.dart';
import 'note_edit_screen.dart';
import 'settings_screen.dart';

/// Главный экран: список заметок, поиск и кнопка добавления.
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _notes = [];
  bool _loading = true;
  bool _searching = false;
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final storage = StorageManager.instance.storage;
    final notes =
        _query.isEmpty ? await storage.getAll() : await storage.search(_query);
    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  Future<void> _openEditor([Note? note]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditScreen(note: note)),
    );
    if (changed == true) _reload();
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    _reload(); // хранилище могло измениться
  }

  void _toggleSearch() {
    setState(() {
      if (_searching) {
        _searching = false;
        _query = '';
        _searchCtrl.clear();
        _reload();
      } else {
        _searching = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Поиск заметок',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (v) {
                  _query = v;
                  _reload();
                },
              )
            : const Text('BizNotes'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            tooltip: _searching ? 'Закрыть поиск' : 'Поиск',
            onPressed: _toggleSearch,
          ),
          if (!_searching)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Настройки',
              onPressed: _openSettings,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildCard(_notes[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        tooltip: 'Новая заметка',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            _query.isEmpty ? 'Пока нет заметок' : 'Ничего не найдено',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Note n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          n.title.isEmpty ? '(без заголовка)' : n.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${n.date} · ${n.time}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            if (n.content.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
        onTap: () => _openEditor(n),
      ),
    );
  }
}
