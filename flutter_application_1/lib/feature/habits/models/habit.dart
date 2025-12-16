class Habit {
  int? id;
  String name;
  String icon; // simple string key for icon
  int color; // store as ARGB int or palette index
  bool reminderEnabled;
  String? reminderTime; // stored as HH:mm
  DateTime createdAt;

  Habit({
    this.id,
    required this.name,
    this.icon = 'book',
    this.color = 0xFF00BFA5,
    this.reminderEnabled = false,
    this.reminderTime,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
        id: m['id'] as int?,
        name: m['name'] as String,
        icon: m['icon'] as String? ?? 'book',
        color: m['color'] as int? ?? 0xFF00BFA5,
        reminderEnabled: (m['reminderEnabled'] as int? ?? 0) == 1,
        reminderTime: m['reminderTime'] as String?,
        createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt'] as String) : DateTime.now(),
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'reminderEnabled': reminderEnabled ? 1 : 0,
      'reminderTime': reminderTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Habit copyWith({
    int? id,
    String? name,
    String? icon,
    int? color,
    bool? reminderEnabled,
    String? reminderTime,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Habit(id: $id, name: $name)';
}
