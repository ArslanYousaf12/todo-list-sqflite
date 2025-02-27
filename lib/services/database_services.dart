import 'package:flutter/foundation.dart';
import 'package:path/path.dart'; // Importing path package to handle file paths
import 'package:sqflite/sqflite.dart';
import 'package:todo_list_sqflite/models/task_model.dart'; // Importing sqflite package for SQLite database operations

class DatabaseServices {
  // Singleton pattern to ensure only one instance of DatabaseServices exists
  static final DatabaseServices instance = DatabaseServices._internal();
  static Database? _database; // Private variable to hold the database instance

  // Private constructor
  DatabaseServices._internal();

  // Table and column names
  final String _taskTable = 'task';
  final String _taskColumnId = 'id';
  final String _taskColumnContent = 'content';
  final String _taskColumnStatus = 'status';

  // Getter for the database instance
  Future<Database> get database async {
    if (_database != null) {
      return _database!; // Return existing database instance if it exists
    }
    _database = await getDatabase(); // Otherwise, initialize the database
    return _database!;
  }

  // Method to initialize and open the database
  Future<Database> getDatabase() async {
    final databaseDir =
        await getDatabasesPath(); // Get the path to the database directory
    final databasePath = join(databaseDir,
        'todo_list.db'); // Create the full path for the database file
    final database = await openDatabase(
      version: 1,
      databasePath,
      onCreate: (db, version) {
        // SQL query to create the task table
        db.execute('''
        CREATE TABLE $_taskTable (
          $_taskColumnId INTEGER PRIMARY KEY,
          $_taskColumnContent TEXT NOT NULL,
          $_taskColumnStatus INTEGER NOT NULL)
         ''');
      },
    );
    return database; // Return the database instance
  }

  void add(String content) async {
    final db = await database; // Get the database instance
    db.insert(
      _taskTable,
      {
        _taskColumnContent: content,
        _taskColumnStatus: 0,
      },
    );
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final data = await db.query(_taskTable);
    debugPrint(data.toString());
    return data
        .map(
          (e) => TaskModel(
            id: e["id"] as int,
            status: e["status"] as int,
            content: e["content"] as String,
          ),
        )
        .toList();
  }

  void updateTaskStatus(id, value) async {
    final db = await database;
    db.update(
        _taskTable,
        {
          _taskColumnStatus: value,
        },
        where: '$_taskColumnId = ?',
        whereArgs: [id]);
  }

  void deleteTask(int id) async {
    final db = await database;
    db.delete(
      _taskTable,
      where: '$_taskColumnId = ?',
      whereArgs: [id],
    );
  }
}
