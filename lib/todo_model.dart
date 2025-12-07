class Todo {
  final String id;
  final String title;
  final String category;
  final String deadline;
  final bool isUrgent;
  bool isCompleted;
  final String username;

  Todo({
    required this.id,
    required this.title,
    required this.category,
    required this.deadline,
    required this.isUrgent,
    required this.isCompleted,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline,
      'isUrgent': isUrgent ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'username': username,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      deadline: map['deadline'],
      isUrgent: map['isUrgent'] == 1,
      isCompleted: map['isCompleted'] == 1,
      username: map['username'],
    );
  }
}
