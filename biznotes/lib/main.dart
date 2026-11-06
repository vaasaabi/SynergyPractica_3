import 'package:flutter/material.dart';

import 'screens/notes_list_screen.dart';
import 'storage/storage_manager.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageManager.instance.load();
  runApp(const BizNotesApp());
}

class BizNotesApp extends StatelessWidget {
  const BizNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BizNotes',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const NotesListScreen(),
    );
  }
}
