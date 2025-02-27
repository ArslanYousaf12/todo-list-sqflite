import 'package:flutter/material.dart';
import 'package:todo_list_sqflite/models/task_category.dart';
import 'package:todo_list_sqflite/models/task_timer.dart';
import 'package:todo_list_sqflite/services/database_services.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  String? _task;
  final TextEditingController _textController = TextEditingController();
  int _selectedCategory = 1; // Default category
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showDateTimePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addTask() {
    _selectedDateTime = null; // Reset selected datetime
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: const Text('Add New Task',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textController,
                    onChanged: (value) => _task = value,
                    decoration: InputDecoration(
                      hintText: 'Enter task',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Text(category.icon),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(_selectedDateTime == null
                        ? 'Set reminder'
                        : 'Reminder: ${DateFormat('MMM d, y HH:mm').format(_selectedDateTime!)}'),
                    trailing: IconButton(
                      icon: Icon(_selectedDateTime == null
                          ? Icons.alarm_add
                          : Icons.alarm_off),
                      onPressed: () {
                        if (_selectedDateTime == null) {
                          _showDateTimePicker();
                          setStateDialog(() {});
                        } else {
                          setStateDialog(() {
                            _selectedDateTime = null;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_task?.isNotEmpty ?? false) {
                      final taskId = await _databaseServices.add(
                        _task!,
                        _selectedCategory,
                      );

                      if (_selectedDateTime != null) {
                        await _databaseServices.setTaskTimer(
                          taskId,
                          _selectedDateTime!,
                        );
                      }

                      setState(() {
                        _textController.clear();
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Implement sorting functionality
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: FutureBuilder(
          future: _databaseServices.getTasks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final task = snapshot.data![index];
                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Dismissible(
                    key: Key(task.id.toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        _databaseServices.deleteTask(task.id);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Task deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() {
                                _databaseServices.add(
                                    task.content, task.categoryId);
                              });
                            },
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: task.status == 1,
                            onChanged: (value) {
                              setState(() {
                                _databaseServices.updateTaskStatus(
                                  task.id,
                                  value == true ? 1 : 0,
                                );
                              });
                            },
                          ),
                          Text(categories
                              .firstWhere((cat) => cat.id == task.categoryId)
                              .icon),
                        ],
                      ),
                      title: Text(
                        task.content,
                        style: TextStyle(
                          decoration: task.status == 1
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.status == 1 ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: FutureBuilder<TaskTimer?>(
                        future: _databaseServices.getTaskTimer(task.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Tooltip(
                              message: DateFormat('MMM d, y HH:mm')
                                  .format(snapshot.data!.scheduledTime),
                              child: const Icon(Icons.alarm, size: 20),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
