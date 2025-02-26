import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list_sqflite/services/database_services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseServices _databaseServices = DatabaseServices.instance;
  String? _task;
  void _addTask() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Add Task'),
            content: TextField(
              onChanged: (value) => _task = value,
              decoration: const InputDecoration(
                  hintText: 'Enter task', border: OutlineInputBorder()),
            ),
            actions: [
              MaterialButton(
                  child:
                      Text('Add Task', style: TextStyle(color: Colors.white)),
                  color: Colors.blue,
                  onPressed: () {
                    if (_task == null || _task == '') {
                      return;
                    }
                    _databaseServices.add(_task!);
                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          FloatingActionButton(onPressed: _addTask, child: Icon(Icons.add)),
    );
  }
}
