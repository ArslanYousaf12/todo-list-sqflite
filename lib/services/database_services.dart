import 'package:flutter/foundation.dart';
import 'package:path/path.dart'; // Importing path package to handle file paths
import 'package:sqflite/sqflite.dart'; // Importing sqflite package for SQLite database operations
import 'package:todo_list_sqflite/models/task_model.dart'; // Importing task model
import 'package:todo_list_sqflite/models/task_timer.dart';

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
  final String _taskColumnCategory = 'category_id';

  // Add timer table and columns
  final String _timerTable = 'task_timer';
  final String _timerColumnTaskId = 'task_id';
  final String _timerColumnScheduledTime = 'scheduled_time';
  final String _timerColumnIsNotified = 'is_notified';

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
        'todo_list3.db'); // Create the full path for the database file
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $_taskTable (
          $_taskColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_taskColumnContent TEXT NOT NULL,
          $_taskColumnStatus INTEGER NOT NULL,
          $_taskColumnCategory INTEGER NOT NULL)
        ''');

        await db.execute('''
        CREATE TABLE $_timerTable (
          $_timerColumnTaskId INTEGER PRIMARY KEY,
          $_timerColumnScheduledTime TEXT NOT NULL,
          $_timerColumnIsNotified INTEGER NOT NULL,
          FOREIGN KEY ($_timerColumnTaskId) REFERENCES $_taskTable ($_taskColumnId) ON DELETE CASCADE)
        ''');
      },
    );
    return database; // Return the database instance
  }

  // Method to add a new task to the database
  Future<int> add(String content, int categoryId) async {
    final db = await database; // Get the database instance
    return db.insert(
      _taskTable,
      {
        _taskColumnContent: content,
        _taskColumnStatus: 0, // Default status is 0 (incomplete)
        _taskColumnCategory: categoryId,
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
            categoryId: e["category_id"] as int,
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

  // Add methods for timer operations
  Future<void> setTaskTimer(int taskId, DateTime scheduledTime) async {
    final db = await database;
    await db.insert(
      _timerTable,
      TaskTimer(taskId: taskId, scheduledTime: scheduledTime).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<TaskTimer?> getTaskTimer(int taskId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _timerTable,
      where: '$_timerColumnTaskId = ?',
      whereArgs: [taskId],
    );

    if (maps.isEmpty) return null;
    return TaskTimer.fromMap(maps.first);
  }

  Future<void> deleteTaskTimer(int taskId) async {
    final db = await database;
    await db.delete(
      _timerTable,
      where: '$_timerColumnTaskId = ?',
      whereArgs: [taskId],
    );
  }
}
