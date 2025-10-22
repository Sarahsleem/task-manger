import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../database/database.dart';
import '../../logic/providers/task_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _currentFilter = 'all';
  late AnimationController _animationController;
  DateTime? _selectedDueDate;
  int _selectedPriority = 2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Column(
        children: [
          // Filter Chips
          _buildFilterSection(taskProvider),

          // Tasks List
          Expanded(
            child: isLargeScreen
                ? _buildAnimatedGridView(taskProvider)
                : _buildAnimatedListView(taskProvider),
          ),
        ],
      ),

      // Add Task FAB with animation
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFilterSection(TaskProvider taskProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _currentFilter == 'all',
            onSelected: (_) => _setFilter('all', taskProvider),
          ),
          FilterChip(
            label: const Text('Pending'),
            selected: _currentFilter == 'pending',
            onSelected: (_) => _setFilter('pending', taskProvider),
          ),
          FilterChip(
            label: const Text('Completed'),
            selected: _currentFilter == 'completed',
            onSelected: (_) => _setFilter('completed', taskProvider),
          ),
          FilterChip(
            label: const Text('High Priority'),
            selected: _currentFilter == 'high',
            onSelected: (_) => _setFilter('high', taskProvider),
          ),
          FilterChip(
            label: const Text('Overdue'),
            selected: _currentFilter == 'overdue',
            onSelected: (_) => _setFilter('overdue', taskProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedListView(TaskProvider taskProvider) {
    return AnimatedList(
      key: Key(_currentFilter),
      padding: const EdgeInsets.all(16.0),
      initialItemCount: taskProvider.tasks.length,
      itemBuilder: (context, index, animation) {
        final task = taskProvider.tasks[index];
        return _buildAnimatedTaskItem(task, taskProvider, animation, index);
      },
    );
  }

  Widget _buildAnimatedGridView(TaskProvider taskProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 2.0,
      ),
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return _buildTaskItemWithAnimation(task, taskProvider, index);
      },
    );
  }

  Widget _buildAnimatedTaskItem(Task task, TaskProvider taskProvider, Animation<double> animation, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          )),
          child: _buildTaskItem(task, taskProvider, index),
        ),
      ),
    );
  }

  Widget _buildTaskItemWithAnimation(Task task, TaskProvider taskProvider, int index) {
    return Dismissible(
      key: Key('task_${task.id}_$index'),
      direction: DismissDirection.endToStart,
      background: _buildDismissibleBackground(),
      secondaryBackground: _buildDismissibleSecondaryBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context, task, taskProvider);
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteTaskWithUndo(task, taskProvider, index);
        }
      },
      child: _buildTaskItem(task, taskProvider, index),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      color: Colors.green,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Icon(Icons.check, color: Colors.white, size: 30),
    );
  }

  Widget _buildDismissibleSecondaryBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.white, size: 30),
    );
  }

  void _deleteTaskWithUndo(Task task, TaskProvider taskProvider, int index) {
    final deletedTask = task;

    taskProvider.deleteTask(task);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task.title}" deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            taskProvider.restoreTask(
              deletedTask.title,
              deletedTask.description,
              dueDate: deletedTask.dueDate,
              priority: deletedTask.priority,
            );
          },
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTaskItem(Task task, TaskProvider taskProvider, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: task.isOverdue ? Border.all(color: Colors.red, width: 2) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: _buildPriorityIndicator(task),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              if (task.isOverdue)
                const Icon(Icons.warning, color: Colors.red, size: 16),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    task.description!,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              if (task.dueDate != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      task.formattedDueDate,
                      style: TextStyle(
                        color: task.isOverdue ? Colors.red : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          trailing: _buildTaskActions(task, taskProvider),
          onTap: () => _showTaskDetails(context, task, taskProvider),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(Task task) {
    Color priorityColor;
    switch (task.priority) {
      case 1:
        priorityColor = Colors.red;
        break;
      case 2:
        priorityColor = Colors.orange;
        break;
      case 3:
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Stack(
      children: [
        CircularProgressIndicator(
          value: task.isCompleted ? 1.0 : 0.0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(priorityColor),
          strokeWidth: 3,
        ),
        Positioned.fill(
          child: Center(
            child: Icon(
              task.isCompleted ? Icons.check : Icons.flag,
              color: task.isCompleted ? priorityColor : Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskActions(Task task, TaskProvider taskProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            task.isCompleted ? Icons.undo : Icons.check_circle,
            color: task.isCompleted ? Colors.grey : Colors.green,
          ),
          onPressed: () => _toggleTaskCompletion(task, taskProvider),
          tooltip: task.isCompleted ? 'Mark as pending' : 'Mark as completed',
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => _showEditTaskDialog(context, task),
          tooltip: 'Edit task',
        ),
      ],
    );
  }

  void _toggleTaskCompletion(Task task, TaskProvider taskProvider) {
    taskProvider.toggleTaskCompletion(task);
  }

  void _setFilter(String filter, TaskProvider taskProvider) {
    setState(() {
      _currentFilter = filter;
    });
    taskProvider.setFilter(filter);
  }

  void _showAddTaskDialog(BuildContext context) {
    _titleController.clear();
    _descriptionController.clear();
    _selectedDueDate = null;
    _selectedPriority = 2;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Task', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Due Date'),
                    subtitle: Text(
                        _selectedDueDate == null
                            ? 'No due date'
                            : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _selectedDueDate = date);
                      }
                    },
                    trailing: _selectedDueDate != null
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedDueDate = null),
                    )
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Priority'),
                    trailing: DropdownButton<int>(
                      value: _selectedPriority,
                      onChanged: (value) => setState(() => _selectedPriority = value!),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('High', style: TextStyle(color: Colors.red))),
                        DropdownMenuItem(value: 2, child: Text('Medium', style: TextStyle(color: Colors.orange))),
                        DropdownMenuItem(value: 3, child: Text('Low', style: TextStyle(color: Colors.green))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    Provider.of<TaskProvider>(context, listen: false).addTask(
                      _titleController.text,
                      _descriptionController.text.isEmpty ? null : _descriptionController.text,
                      dueDate: _selectedDueDate,
                      priority: _selectedPriority,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Add Task'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _selectedDueDate = task.dueDate;
    _selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Task', style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Due Date'),
                    subtitle: Text(
                        _selectedDueDate == null
                            ? 'No due date'
                            : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _selectedDueDate = date);
                      }
                    },
                    trailing: _selectedDueDate != null
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedDueDate = null),
                    )
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Priority'),
                    trailing: DropdownButton<int>(
                      value: _selectedPriority,
                      onChanged: (value) => setState(() => _selectedPriority = value!),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('High', style: TextStyle(color: Colors.red))),
                        DropdownMenuItem(value: 2, child: Text('Medium', style: TextStyle(color: Colors.orange))),
                        DropdownMenuItem(value: 3, child: Text('Low', style: TextStyle(color: Colors.green))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    // Use updateTaskFields instead of copyWith to avoid type issues
                    Provider.of<TaskProvider>(context, listen: false).updateTaskFields(
                      task.id!,
                      title: _titleController.text,
                      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                      dueDate: _selectedDueDate,
                      priority: _selectedPriority,
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(task.description!),
                ),
              _buildDetailItem('Status', task.isCompleted ? 'Completed' : 'Pending'),
              _buildDetailItem('Priority', task.priorityText),
              _buildDetailItem('Due Date', task.formattedDueDate),
              if (task.isOverdue)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '⚠️ This task is overdue!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              _buildDetailItem('Created', '${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}'),
              _buildDetailItem('Last Updated', '${task.updatedAt.day}/${task.updatedAt.month}/${task.updatedAt.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditTaskDialog(context, task);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, Task task, TaskProvider taskProvider) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}