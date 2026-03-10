import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import 'database_service.dart';
import 'native_service.dart';
import 'supabase_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  User? _user;
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  User? get user => _user;
  bool get isLoading => _isLoading;

  final DatabaseService _db = DatabaseService();

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _db.getTasks();
    _user = await _db.getUser();

    _syncBlockingState(); // Heal blocking state on load

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncBlockingState() async {
    // Find if there is any active strict task
    final activeStrictTask = _tasks.firstWhere(
      (t) => t.isStrict && _isTaskActive(t),
      orElse: () => Task(
        title: '', 
        startTime: DateTime(2000), 
        endTime: DateTime(2000), 
        category: '', 
        allowedApps: [], 
        xpReward: 0, 
        isStrict: false
      )
    );

    if (activeStrictTask.isStrict && activeStrictTask.title.isNotEmpty) {
      // Found one -> Ensure blocking is ON
      await NativeService.startBlocking(activeStrictTask.allowedApps);
    } else {
      // None found -> Ensure blocking is OFF
      await NativeService.stopBlocking();
    }
  }
  
  Future<void> _checkAndSyncUninstallProtection() async {
    final now = DateTime.now();
    final todayTasks = _tasks.where((t) => 
        t.startTime.year == now.year && 
        t.startTime.month == now.month && 
        t.startTime.day == now.day
    ).toList();
    
    if (todayTasks.isEmpty) {
      // No tasks -> Protection ON? User prompt says "Prevent ... unless all tasks completed".
      // If no tasks, technically "0/0" is completed? Or "You must create tasks".
      // Let's assume protection is active until at least one task is done?
      // "Have all today's tasks been completed?"
      // If 0 tasks, let's say NO (false). The user MUST work to earn freedom.
      await NativeService.updateUninstallProtection(false);
      return;
    }
    
    final allDone = todayTasks.every((t) => t.isCompleted);
    await NativeService.updateUninstallProtection(allDone);
  }

  Future<void> addTask(Task task) async {
    await _db.insertTask(task);
    
    // Check if task is active now and Strict Mode is enabled
    if (_isTaskActive(task) && task.isStrict) {
      await NativeService.startBlocking(task.allowedApps);
    }
    
    await loadData();
    await _checkAndSyncUninstallProtection();
  }

  Future<void> completeTask(Task task) async {
    if (task.isCompleted) return;
    
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      startTime: task.startTime,
      endTime: task.endTime,
      category: task.category,
      allowedApps: task.allowedApps,
      xpReward: task.xpReward,
      isStrict: task.isStrict,
      status: TaskStatus.completed,
      isCompleted: true,
    );

    await _db.updateTask(updatedTask);
    await _db.updateUserXp(task.xpReward);
    
    // Stop blocking if strict mode was enabled (or just stop safely)
    if (task.isStrict) {
      await NativeService.stopBlocking();
    }
    
    // Sync to Supabase
    if (_user != null) {
      await SupabaseService().syncUser(_user!.level, _user!.currentXp);
    }

    await loadData();
    await _checkAndSyncUninstallProtection();
  }

  Future<void> deleteTask(int id) async {
      await _db.deleteTask(id);
      await loadData();
  }

  bool _isTaskActive(Task task) {
    final now = DateTime.now();
    // Simple check: start time is before/equal equal now, end time after now
    // Since start time is usually 'now' for immediate tasks
    return task.startTime.isBefore(now.add(Duration(minutes: 1))) && task.endTime.isAfter(now) && !task.isCompleted;
  }
}
