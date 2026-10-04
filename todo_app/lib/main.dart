import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todo_page.dart';
import 'todo_provider.dart';

void main() {
  runApp(
    // Provider je nad MaterialApp, takže je dostupný v celom strome
    // vrátane BottomSheetu a dialógov.
    ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoPage(),
    );
  }
}
