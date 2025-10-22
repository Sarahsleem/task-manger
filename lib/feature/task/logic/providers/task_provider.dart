import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../../../database/database.dart';

class TaskProvider with ChangeNotifier {
  final AppDatabase _database;
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _filter = 'all';

  TaskProvider(this._database) {
    _loadTasks();
  }

  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  String get filter => _filter;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;
  int get overdueTasks => _tasks.where((task) => task.isOverdue).length;
  int get highPriorityTasks => _tasks.where((task) => task.priority == 1).length;

  Future<void> _loadTasks() async {
    _tasks = await _database.allTasks;
    _applyFilter();
    notifyListeners();
  }

  void setFilter(String newFilter) {
    _filter = newFilter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    switch (_filter) {
      case 'completed':
        _filteredTasks = _tasks.where((task) => task.isCompleted).toList();
        break;
      case 'pending':
        _filteredTasks = _tasks.where((task) => !task.isCompleted).toList();
        break;
      case 'high':
        _filteredTasks = _tasks.where((task) => task.priority == 1).toList();
        break;
      case 'overdue':
        _filteredTasks = _tasks.where((task) => task.isOverdue).toList();
        break;
      default:
        _filteredTasks = List.from(_tasks);
    }
  }

  // Updated addTask method with dueDate and priority
  Future<void> addTask(String title, String? description, {DateTime? dueDate, int priority = 2}) async {
    final now = DateTime.now();
    final task = TasksCompanion(
      title: Value(title),
      description: description == null ? const Value.absent() : Value(description),
      dueDate: dueDate == null ? const Value.absent() : Value(dueDate),
      priority: Value(priority),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _database.insertTask(task);
    await _loadTasks();
  }

  // Updated updateTask method
  Future<void> updateTask(Task task) async {
    await _database.updateTask(task);
    await _loadTasks();
  }

  // Alternative update method for partial updates
  Future<void> updateTaskFields(int taskId, {
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    int? priority,
  }) async {
    await _database.updateTaskFields(
      taskId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      dueDate: dueDate,
      priority: priority,
    );
    await _loadTasks();
  }

  Future<void> deleteTask(Task task) async {
    await _database.deleteTask(task);
    await _loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _database.updateTask(updatedTask);
    await _loadTasks();
  }

  // Method to restore a deleted task
  Future<void> restoreTask(String title, String? description, {DateTime? dueDate, int? priority}) async {
    await addTask(title, description, dueDate: dueDate, priority: priority ?? 2);
  }
}