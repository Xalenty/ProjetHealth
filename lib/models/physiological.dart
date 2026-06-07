class PhysiologicalData {
  final int id;
  final DateTime date;
  final double weight;
  final String patientId;

  const PhysiologicalData({
    required this.id,
    required this.date,
    required this.weight,
    required this.patientId,
  });

  factory PhysiologicalData.fromJson(Map<String, dynamic> json) {
    return PhysiologicalData(
      id: _toInt(json['id']),
      date:
          DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      weight: _toDouble(json['weight']),
      patientId: json['people_id']?.toString() ?? '',
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

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
