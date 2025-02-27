class TaskModel {
  final int id;
  final String content;
  final int status;
  final int categoryId;

  TaskModel({
    required this.id,
    required this.content,
    required this.status,
    required this.categoryId,
  });
}
