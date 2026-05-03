import 'package:latlong2/latlong.dart';

enum IncidentType { heartAttack, accident, traffic, roadBlock, stroke, cardiacArrest, severeBleeding, burns, poisoning, general }

class Incident {
  final String id;
  final IncidentType type;
  final LatLng location;
  final double severity;
  final String description;

  Incident({
    required this.id,
    required this.type,
    required this.location,
    this.severity = 1.0,
    required this.description,
  });

  String get icon {
    switch (type) {
      case IncidentType.heartAttack: return '❤️';
      case IncidentType.cardiacArrest: return '⚡';
      case IncidentType.stroke: return '🧠';
      case IncidentType.accident: return '🚑';
      case IncidentType.severeBleeding: return '🩸';
      case IncidentType.burns: return '🔥';
      case IncidentType.poisoning: return '🧪';
      case IncidentType.traffic: return '🚗';
      case IncidentType.roadBlock: return '🚧';
      case IncidentType.general: return '🏥';
    }
  }
}
