class PhysicalActivity {
  final int id;
  final String type;
  final int duration;
  final int numberOfSteps;
  final int consumedCalories;
  final String patientId;
  final DateTime date;

  const PhysicalActivity({
    required this.id,
    required this.type,
    required this.duration,
    required this.numberOfSteps,
    required this.consumedCalories,
    required this.patientId,
    required this.date,
  });

  factory PhysicalActivity.fromJson(Map<String, dynamic> json) {
    return PhysicalActivity(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? 'unknown',
      duration: _toInt(json['duration']),
      numberOfSteps: _toInt(json['numberOfSteps']),
      consumedCalories: _toInt(json['consumedCalories']),
      patientId: json['people_id']?.toString() ?? '',
      date:
          DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
