import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todo_provider.dart';

/// Hlavná stránka aplikácie so zoznamom úloh (To-Do list).
/// Stav aplikácie je v TodoProvider; StatefulWidget zostal len kvôli
/// TextEditingController, ktorý treba korektne uvoľniť v dispose().
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  // Kontrolér na prístup k hodnote z TextFieldu
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Funkcia, ktorá sa zavolá pri kliknutí na "SAVE"
  void _addTodo() {
    // Kontrola prázdneho poľa
    if (_controller.text.isEmpty) {
      showMsg(context, 'Input field must not be empty');
      return;
    }

    // Pridanie úlohy cez Provider
    context.read<TodoProvider>().addTodo(_controller.text);
    _controller.clear();

    // Zatvorenie spodného okna (BottomSheet)
    Navigator.pop(context);
  }

  /// Hlavné rozloženie obrazovky
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoSheet,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text('My Todos')),

      // Consumer sa prekreslí pri každom notifyListeners()
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          final todos = todoProvider.todos;

          if (todos.isEmpty) {
            return const Center(child: Text('Nothing to do!'));
          }

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              return TodoItem(
                todo: todos[index],
                onChanged: (value) =>
                    todoProvider.toggleTodoStatus(index, value),
                onDelete: () => todoProvider.removeTodo(index),
              );
            },
          );
        },
      ),
    );
  }

  /// Zobrazí spodné okno (BottomSheet) na pridanie novej úlohy
  void _showAddTodoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Textové pole pre názov úlohy
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'What to do?'),
            ),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Select Priority'),
            ),

            // Výber priority – Consumer sa prekreslí po zmene priority
            Consumer<TodoProvider>(
              builder: (context, todoProvider, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...TodoPriority.values.map(
                    (value) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<TodoPriority>(
                          value: value,
                          groupValue: todoProvider.priority,
                          onChanged: (selected) =>
                              todoProvider.setPriority(selected!),
                        ),
                        Text(value.name),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            ElevatedButton(onPressed: _addTodo, child: const Text('SAVE')),
          ],
        ),
      ),
    );
  }
}

/// Pomocná funkcia – zobrazí dialógové okno s chybovou hláškou
void showMsg(BuildContext context, String s) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Caution!'),
      content: Text(s),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
      ],
    ),
  );
}

/// Widget pre jednotlivú úlohu – riadok so zaškrtávacím políčkom
class TodoItem extends StatelessWidget {
  final MyTodo todo;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
  });

  /// Farba podľa priority (dobrovoľné rozšírenie)
  Color get _priorityColor => switch (todo.priority) {
        TodoPriority.Low => Colors.green,
        TodoPriority.Normal => Colors.orange,
        TodoPriority.High => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(todo.name),
      subtitle: Text(
        'Priority: ${todo.priority.name}',
        style: TextStyle(color: _priorityColor, fontWeight: FontWeight.bold),
      ),
      value: todo.completed,
      onChanged: (value) => onChanged(value!),
      secondary: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Delete',
        onPressed: onDelete,
      ),
    );
  }
}
