enum TaskStatus { pending, active, completed, failed, skipped }

class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final List<String> allowedApps;
  final int xpReward;
  final bool isStrict;
  final TaskStatus status;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.allowedApps,
    required this.xpReward,
    this.isStrict = false, 
    this.status = TaskStatus.pending,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'category': category,
      'allowed_apps': allowedApps.join(','), // Simple CSV for SQLite
      'xp_reward': xpReward,
      'is_strict': isStrict ? 1 : 0,
      'status': status.toString().split('.').last,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      category: map['category'],
      allowedApps: (map['allowed_apps'] as String).split(','),
      xpReward: map['xp_reward'],
      isStrict: map['is_strict'] == 1,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      isCompleted: map['is_completed'] == 1,
    );
  }
}
