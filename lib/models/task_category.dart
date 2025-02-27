class TaskCategory {
  final int id;
  final String name;
  final String icon;
  final String color;

  TaskCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Predefined categories
final List<TaskCategory> categories = [
  TaskCategory(id: 1, name: 'Personal', icon: '👤', color: '#FF4B4B'),
  TaskCategory(id: 2, name: 'Work', icon: '💼', color: '#2196F3'),
  TaskCategory(id: 3, name: 'Shopping', icon: '🛒', color: '#4CAF50'),
  TaskCategory(id: 4, name: 'Health', icon: '💪', color: '#FF9800'),
  TaskCategory(id: 5, name: 'Others', icon: '📝', color: '#9C27B0'),
];
