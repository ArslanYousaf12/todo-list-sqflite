import 'package:flutter/foundation.dart';
import 'package:path/path.dart'; // Importing path package to handle file paths
import 'package:sqflite/sqflite.dart'; // Importing sqflite package for SQLite database operations
import 'package:todo_list_sqflite/models/task_model.dart'; // Importing task model

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
      databasePath,
      version: 1,
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

  // Method to add a new task to the database
  void add(String content) async {
    final db = await database; // Get the database instance
    db.insert(
      _taskTable,
      {
        _taskColumnContent: content,
        _taskColumnStatus: 0, // Default status is 0 (incomplete)
      },
    );
  }

  // Method to retrieve all tasks from the database
  Future<List<TaskModel>> getTasks() async {
    final db = await database; // Get the database instance
    final data =
        await db.query(_taskTable); // Query all rows from the task table
    debugPrint(data.toString()); // Print the retrieved data for debugging
    return data
        .map(
          (e) => TaskModel(
            id: e["id"] as int,
            status: e["status"] as int,
            content: e["content"] as String,
          ),
        )
        .toList(); // Convert the data to a list of TaskModel objects
  }

  // Method to update the status of a task
  void updateTaskStatus(int id, int value) async {
    final db = await database; // Get the database instance
    db.update(
      _taskTable,
      {
        _taskColumnStatus: value, // Update the status column
      },
      where: '$_taskColumnId = ?', // Specify the row to update
      whereArgs: [id], // Provide the id of the task to update
    );
  }

  // Method to delete a task from the database
  void deleteTask(int id) async {
    final db = await database; // Get the database instance
    db.delete(
      _taskTable,
      where: '$_taskColumnId = ?', // Specify the row to delete
      whereArgs: [id], // Provide the id of the task to delete
    );
  }
}
