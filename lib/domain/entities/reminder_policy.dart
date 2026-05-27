class ReminderPolicy {
  const ReminderPolicy({
    this.daysBefore = const {30, 14, 7, 1},
    this.dayOf = false,
  });

  final Set<int> daysBefore;
  final bool dayOf;

  static const ReminderPolicy defaults = ReminderPolicy();

  List<int> get sortedOffsets {
    final offsets = daysBefore.toList()..sort((a, b) => b.compareTo(a));
    if (dayOf) offsets.add(0);
    return offsets;
  }

  ReminderPolicy copyWith({
    Set<int>? daysBefore,
    bool? dayOf,
  }) {
    return ReminderPolicy(
      daysBefore: daysBefore ?? this.daysBefore,
      dayOf: dayOf ?? this.dayOf,
    );
  }

  bool get isValid => daysBefore.isNotEmpty || dayOf;
}
