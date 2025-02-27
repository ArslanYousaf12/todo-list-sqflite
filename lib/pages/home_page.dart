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
                    setState(() {
                      _databaseServices.add(_task!);
                    });

                    Navigator.of(context).pop();
                  })
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _databaseServices.getTasks(),
          builder: (context, snapshot) {
            return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final task = snapshot.data![index];
                  return ListTile(
                    onLongPress: () {
                      setState(() {
                        _databaseServices.deleteTask(task.id);
                      });
                    },
                    title: Text(task.content),
                    trailing: Checkbox(
                        value: task.status == 1,
                        onChanged: (value) {
                          setState(() {
                            _databaseServices.updateTaskStatus(
                                task.id, value == true ? 1 : 0);
                          });
                        }),
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: _addTask, child: const Icon(Icons.add)),
    );
  }
}
