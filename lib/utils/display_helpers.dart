String translateActivityType(String type) {
  switch (type.toLowerCase().trim()) {
    case 'bike':
    case 'cycling':
    case 'bicycle':
      return 'Vélo';
    case 'walk':
    case 'walking':
      return 'Marche';
    case 'run':
    case 'running':
      return 'Course';
    case 'swim':
    case 'swimming':
      return 'Natation';
    case 'hike':
    case 'hiking':
      return 'Randonnée';
    case 'fitness':
    case 'workout':
    case 'strength':
    case 'strength_training':
      return 'Renforcement';
    case 'unknown':
    case '':
      return 'Activité physique';
    default:
      return _humanize(type);
  }
}

String translateActivityProfile(String profile) {
  switch (profile.toLowerCase().trim()) {
    case 'sedentary':
      return 'Sédentaire';
    case 'active':
      return 'Actif';
    case 'moderate':
    case 'moderately_active':
      return 'Modéré';
    case 'very_active':
      return 'Très actif';
    case 'unknown':
    case '':
      return 'Non renseigné';
    default:
      return _humanize(profile);
  }
}

String translateBmiStatus(String status) {
  switch (status.toLowerCase().trim()) {
    case 'underweight':
      return 'Insuffisance pondérale';
    case 'normal':
      return 'Normal';
    case 'overweight':
      return 'Surpoids';
    case 'obesity':
    case 'obese':
      return 'Obésité';
    case 'unknown':
    case '':
      return 'Non renseigné';
    default:
      return _humanize(status);
  }
}

String formatDurationMinutes(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  }

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (remainingMinutes == 0) {
    return '$hours h';
  }

  return '$hours h $remainingMinutes min';
}

String _humanize(String value) {
  final normalized = value
      .trim()
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  if (normalized.isEmpty) {
    return 'Non renseigné';
  }

  return normalized
      .split(' ')
      .map((word) {
        if (word.isEmpty) {
          return word;
        }

        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      })
      .join(' ');
}
