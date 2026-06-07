class PsychicData {
  final int id;
  final String peopleId;
  final String feeling;
  final DateTime date;

  PsychicData({
    required this.id,
    required this.peopleId,
    required this.feeling,
    required this.date,
  });

  factory PsychicData.fromJson(Map<String, dynamic> json) {
    return PsychicData(
      id: json['id'],
      peopleId: json['people_id'],
      feeling: json['feeling'],
      date: DateTime.parse(json['date']),
    );
  }
}