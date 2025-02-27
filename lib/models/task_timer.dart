class TaskTimer {
  final int taskId;
  final DateTime scheduledTime;
  final bool isNotified;

  TaskTimer({
    required this.taskId,
    required this.scheduledTime,
    this.isNotified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'scheduled_time': scheduledTime.toIso8601String(),
      'is_notified': isNotified ? 1 : 0,
    };
  }

  factory TaskTimer.fromMap(Map<String, dynamic> map) {
    return TaskTimer(
      taskId: map['task_id'],
      scheduledTime: DateTime.parse(map['scheduled_time']),
      isNotified: map['is_notified'] == 1,
    );
  }
}
