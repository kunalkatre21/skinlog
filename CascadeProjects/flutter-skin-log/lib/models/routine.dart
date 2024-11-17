enum RoutineTime { morning, evening }

class RoutineEntry {
  final String id;
  final String userId;
  final RoutineTime routineTime;
  final List<RoutineStep> steps;
  final String? notes;
  final String? skinCondition;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoutineEntry({
    required this.id,
    required this.userId,
    required this.routineTime,
    required this.steps,
    this.notes,
    this.skinCondition,
    required this.createdAt,
    required this.updatedAt,
  });

  RoutineEntry copyWith({
    String? id,
    String? userId,
    RoutineTime? routineTime,
    List<RoutineStep>? steps,
    String? notes,
    String? skinCondition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoutineEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routineTime: routineTime ?? this.routineTime,
      steps: steps ?? this.steps,
      notes: notes ?? this.notes,
      skinCondition: skinCondition ?? this.skinCondition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RoutineStep {
  final String id;
  final String name;
  final bool completed;
  final DateTime? completedAt;

  RoutineStep({
    required this.id,
    required this.name,
    this.completed = false,
    this.completedAt,
  });

  RoutineStep copyWith({
    String? id,
    String? name,
    bool? completed,
    DateTime? completedAt,
  }) {
    return RoutineStep(
      id: id ?? this.id,
      name: name ?? this.name,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
