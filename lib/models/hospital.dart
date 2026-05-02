import 'node.dart';

enum HospitalType {
  cardiac,
  general,
  trauma,
}

class Hospital extends Node {
  final HospitalType type;
  final bool isAvailable;
  final String specialty;

  Hospital({
    required String id,
    required String name,
    required dynamic position,
    required this.type,
    this.isAvailable = true,
    this.specialty = 'Emergency Care',
  }) : super(id: id, name: name, position: position);
}
