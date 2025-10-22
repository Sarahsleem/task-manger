import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(2))(); // 1: High, 2: Medium, 3: Low
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;
  Future<void> updateTaskFields(int taskId, {
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    int? priority,
  }) async {
    final companion = TasksCompanion(
      title: title != null ? Value(title) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      isCompleted: isCompleted != null ? Value(isCompleted) : const Value.absent(),
      dueDate: dueDate != null ? Value(dueDate) : const Value.absent(),
      priority: priority != null ? Value(priority) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    await (update(tasks)..where((t) => t.id.equals(taskId))).write(companion);
  }

  // Task methods
  Future<List<Task>> get allTasks => select(tasks).get();

  Future<List<Task>> get pendingTasks =>
      (select(tasks)..where((t) => t.isCompleted.equals(false))).get();

  Future<List<Task>> get completedTasks =>
      (select(tasks)..where((t) => t.isCompleted.equals(true))).get();

  Future<List<Task>> get highPriorityTasks =>
      (select(tasks)..where((t) => t.priority.equals(1))).get();

  Future<List<Task>> get overdueTasks =>
      (select(tasks)..where((t) {
        final now = DateTime.now();
        return t.isCompleted.equals(false) &
        t.dueDate.isNotNull() &
        t.dueDate.isSmallerThanValue(now); // Fixed: use isSmallerThanValue
      })).get();

  // Insert task
  Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);

  // Update task
  Future<bool> updateTask(Task task) => update(tasks).replace(task);

  // Delete task
  Future<int> deleteTask(Task task) => delete(tasks).delete(task);

  // Delete task by ID
  Future<int> deleteTaskById(int id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();

  // Streams for real-time updates
  Stream<List<Task>> watchAllTasks() => select(tasks).watch();

  Stream<List<Task>> watchPendingTasks() =>
      (select(tasks)..where((t) => t.isCompleted.equals(false))).watch();

  Stream<List<Task>> watchCompletedTasks() =>
      (select(tasks)..where((t) => t.isCompleted.equals(true))).watch();

  Stream<List<Task>> watchHighPriorityTasks() =>
      (select(tasks)..where((t) => t.priority.equals(1))).watch();

  Stream<List<Task>> watchOverdueTasks() =>
      (select(tasks)..where((t) {
        final now = DateTime.now();
        return t.isCompleted.equals(false) &
        t.dueDate.isNotNull() &
        t.dueDate.isSmallerThanValue(now); // Fixed: use isSmallerThanValue
      })).watch();

  // Get tasks by priority
  Future<List<Task>> getTasksByPriority(int priority) =>
      (select(tasks)..where((t) => t.priority.equals(priority))).get();

  // Get tasks with due date
  Future<List<Task>> getTasksWithDueDate() =>
      (select(tasks)..where((t) => t.dueDate.isNotNull())).get();

  // Search tasks
  Future<List<Task>> searchTasks(String query) =>
      (select(tasks)..where((t) => t.title.like('%$query%'))).get();

  // Toggle task completion
  Future<void> toggleTaskCompletion(int taskId, bool isCompleted) async {
    final task = await (select(tasks)..where((t) => t.id.equals(taskId))).getSingle();
    final updatedTask = task.copyWith(
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );
    await updateTask(updatedTask);
  }

  // Update task priority
  Future<void> updateTaskPriority(int taskId, int priority) async {
    final task = await (select(tasks)..where((t) => t.id.equals(taskId))).getSingle();
    final updatedTask = task.copyWith(
      priority: priority,
      updatedAt: DateTime.now(),
    );
    await updateTask(updatedTask);
  }

  // Update task due date
  // Future<void> updateTaskDueDate(int taskId, DateTime? dueDate) async {
  //   final task = await (select(tasks)..where((t) => t.id.equals(taskId))).getSingle();
  //   final updatedTask = task.copyWith(
  //     dueDate: dueDate,
  //     updatedAt: DateTime.now(),
  //   );
  //   await updateTask(updatedTask);
  // }

  // Update task due date
  Future<void> updateTaskDueDate(int taskId, DateTime? dueDate) async {
    final task = await (select(tasks)..where((t) => t.id.equals(taskId))).getSingle();

    // Use the copyWithCompanion method or create a proper companion
    final companion = TasksCompanion(
      id: Value(task.id),
      title: Value(task.title),
      description: Value(task.description),
      isCompleted: Value(task.isCompleted),
      dueDate: dueDate == null ? const Value.absent() : Value(dueDate), // Fixed
      priority: Value(task.priority),
      createdAt: Value(task.createdAt),
      updatedAt: Value(DateTime.now()),
    );

    await (update(tasks)..where((t) => t.id.equals(taskId))).write(companion);
  }
  // Get tasks due today
  Future<List<Task>> getTasksDueToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return (select(tasks)..where((t) {
      return t.dueDate.isNotNull() &
      t.dueDate.isBiggerOrEqualValue(today) & // Fixed: use isBiggerOrEqualValue
      t.dueDate.isSmallerThanValue(tomorrow); // Fixed: use isSmallerThanValue
    })).get();
  }

  // Get tasks due this week
  Future<List<Task>> getTasksDueThisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));

    return (select(tasks)..where((t) {
      return t.dueDate.isNotNull() &
      t.dueDate.isBiggerOrEqualValue(today) & // Fixed: use isBiggerOrEqualValue
      t.dueDate.isSmallerThanValue(nextWeek); // Fixed: use isSmallerThanValue
    })).get();
  }

  // Get task statistics
  Future<Map<String, int>> getTaskStatistics() async {
    final all = await allTasks;
    final completed = await completedTasks;
    final pending = await pendingTasks;
    final overdue = await overdueTasks;
    final highPriority = await highPriorityTasks;

    return {
      'total': all.length,
      'completed': completed.length,
      'pending': pending.length,
      'overdue': overdue.length,
      'highPriority': highPriority.length,
    };
  }

  // Migration to add new columns
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Add new columns in version 2
        await migrator.addColumn(tasks, tasks.dueDate);
        await migrator.addColumn(tasks, tasks.priority);
      }
    },

    // Optional: Create all tables (useful for development)
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

// Extension methods for easier task management
extension TaskExtensions on Task {
  // Convert to companion for updates
  TasksCompanion toCompanion() {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      isCompleted: Value(isCompleted),
      dueDate: dueDate == null ? const Value.absent() : Value(dueDate), // Fixed: use Value constructor
      priority: Value(priority),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  // Check if task is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    return !isCompleted && dueDate!.isBefore(DateTime.now());
  }

  // Get priority as text
  String get priorityText {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Medium';
    }
  }

  // Get priority color name
  String get priorityColorName {
    switch (priority) {
      case 1:
        return 'red';
      case 2:
        return 'orange';
      case 3:
        return 'green';
      default:
        return 'grey';
    }
  }

  // Get days until due
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inDays;
  }

  // Get formatted due date
  String get formattedDueDate {
    if (dueDate == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (dueDate!.isBefore(today)) {
      return 'Overdue';
    } else if (dueDate!.isBefore(tomorrow)) {
      return 'Today';
    } else {
      final difference = dueDate!.difference(today);
      if (difference.inDays == 1) {
        return 'Tomorrow';
      } else if (difference.inDays <= 7) {
        return 'In ${difference.inDays} days';
      } else {
        return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
      }
    }
  }
}

// Helper class for task filters
class TaskFilters {
  static const String all = 'all';
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String highPriority = 'highPriority';
  static const String overdue = 'overdue';
  static const String withDueDate = 'withDueDate';
}

// Data class for task statistics
class TaskStats {
  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final int highPriority;

  TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.highPriority,
  });

  double get completionRate => total > 0 ? completed / total : 0;

  factory TaskStats.fromMap(Map<String, int> map) {
    return TaskStats(
      total: map['total'] ?? 0,
      completed: map['completed'] ?? 0,
      pending: map['pending'] ?? 0,
      overdue: map['overdue'] ?? 0,
      highPriority: map['highPriority'] ?? 0,
    );
  }
}