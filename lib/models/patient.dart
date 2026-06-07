class Patient {
  final String id;
  final String firstname;
  final String lastname;
  final int birthyear;
  final int height;
  final int weightStart;
  final int weightGoal;
  final String bmiStart;
  final String bmiGoal;
  final String activityProfile;
  final int sex;

  final List<int> physicalActivities;
  final List<int> physiologicalData;
  final List<int> neuronalActivities;

  const Patient({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.birthyear,
    required this.height,
    required this.weightStart,
    required this.weightGoal,
    required this.bmiStart,
    required this.bmiGoal,
    required this.activityProfile,
    required this.sex,
    required this.physicalActivities,
    required this.physiologicalData,
    required this.neuronalActivities,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: _toText(json['id']),
      firstname: _toText(json['firstname'], fallback: 'Prénom inconnu'),
      lastname: _toText(json['lastname'], fallback: 'Nom inconnu'),
      birthyear: _toInt(json['birthyear']),
      height: _toInt(json['height']),
      weightStart: _toInt(json['weightStart']),
      weightGoal: _toInt(json['weightGoal']),
      bmiStart: _toText(json['bmiStart'], fallback: 'Non renseigné'),
      bmiGoal: _toText(json['bmiGoal'], fallback: 'Non renseigné'),
      activityProfile: _toText(
        json['activityProfile'],
        fallback: 'Non renseigné',
      ),
      sex: _toInt(json['sex']),
      physicalActivities: _toIntList(json['physicalActivities']),
      physiologicalData: _toIntList(json['physiologicalData']),
      neuronalActivities: _toIntList(json['neuronalActivities']),
    );
  }

  String get fullName => '$firstname $lastname';

  int get age {
    if (birthyear == 0) {
      return 0;
    }

    return DateTime.now().year - birthyear;
  }

  int get weightDifference => weightGoal - weightStart;
  bool get hasValidIdentity {
    return firstname != 'Prénom inconnu' && lastname != 'Nom inconnu';
  }

  bool get isIncomplete {
    return !hasValidIdentity ||
        birthyear <= 0 ||
        height <= 0 ||
        weightStart <= 0 ||
        weightGoal <= 0;
  }

  static String _toText(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    final text = value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static List<int> _toIntList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value.map(_toInt).toList();
  }
}
