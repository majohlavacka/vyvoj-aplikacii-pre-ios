import 'package:flutter/foundation.dart';

/// Centrálna správa stavu To-Do aplikácie.
/// Uchováva zoznam úloh a zvolenú prioritu a pri každej zmene
/// upozorní widgety cez notifyListeners().
class TodoProvider extends ChangeNotifier {
  final List<MyTodo> _todos = [];
  TodoPriority _priority = TodoPriority.Normal;

  /// Zoznam úloh len na čítanie – meniť sa dá iba cez metódy nižšie.
  List<MyTodo> get todos => List.unmodifiable(_todos);

  TodoPriority get priority => _priority;

  /// Zmena zvolenej priority v BottomSheete
  void setPriority(TodoPriority value) {
    _priority = value;
    notifyListeners();
  }

  /// Pridanie novej úlohy so zvolenou prioritou
  void addTodo(String name) {
    _todos.add(
      MyTodo(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        priority: _priority,
      ),
    );
    notifyListeners();
  }

  /// Označenie úlohy ako splnená / nesplnená
  void toggleTodoStatus(int index, bool value) {
    _todos[index].completed = value;
    notifyListeners();
  }

  /// Odstránenie úlohy (dobrovoľné rozšírenie)
  void removeTodo(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }
}

/// Model (dátová trieda) pre jednu úlohu
class MyTodo {
  int id; // unikátne ID úlohy
  String name; // názov úlohy
  bool completed; // či je úloha dokončená
  TodoPriority priority; // priorita úlohy

  MyTodo({
    required this.id,
    required this.name,
    this.completed = false,
    required this.priority,
  });
}

/// Enum (výčtový typ) – definovanie troch úrovní priority
enum TodoPriority { Low, Normal, High }
