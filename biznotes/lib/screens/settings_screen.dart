import 'package:flutter/material.dart';

import '../storage/storage_manager.dart';

/// Экран настроек: выбор способа хранения и (опционально) синхронизация.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StorageMode _mode = StorageManager.instance.mode;
  bool _sync = false;

  Future<void> _setMode(StorageMode? m) async {
    if (m == null) return;
    await StorageManager.instance.setMode(m);
    setState(() => _mode = m);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          const _SectionTitle('Хранилище заметок'),
          RadioListTile<StorageMode>(
            value: StorageMode.sqlite,
            groupValue: _mode,
            onChanged: _setMode,
            title: const Text('База данных SQLite'),
            subtitle: const Text(
                'Локальное структурированное хранение (по умолчанию)'),
          ),
          RadioListTile<StorageMode>(
            value: StorageMode.file,
            groupValue: _mode,
            onChanged: _setMode,
            title: const Text('Файловая система устройства'),
            subtitle:
                const Text('Каждая заметка сохраняется отдельным файлом (JSON)'),
          ),
          const Divider(),
          const _SectionTitle('Синхронизация'),
          SwitchListTile(
            value: _sync,
            onChanged: (v) => setState(() => _sync = v),
            title: const Text('Облачная синхронизация'),
            subtitle: const Text(
                'Firebase · дополнительно (демонстрационный переключатель)'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Примечание: заметки в режимах «SQLite» и «Файловая система» '
              'хранятся независимо. При переключении режима список показывает '
              'заметки выбранного хранилища.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
