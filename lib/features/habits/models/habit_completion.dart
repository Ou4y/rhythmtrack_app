class HabitCompletion {
  int? id;
  int habitId;
  String date; 
  bool completed;
  DateTime createdAt;

  HabitCompletion({
    this.id,
    required this.habitId,
    required this.date,
    this.completed = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory HabitCompletion.fromMap(Map<String, dynamic> m) => HabitCompletion(
        id: m['id'] as int?,
        habitId: m['habitId'] as int,
        date: m['date'] as String,
        completed: (m['completed'] as int? ?? 1) == 1,
        createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt'] as String) : DateTime.now(),
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
