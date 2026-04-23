import 'node.dart';

enum HospitalType {
  cardiac,
  general,
  trauma,
}

class Hospital extends Node {
  final HospitalType type;

  Hospital({
    required String id,
    required String name,
    required dynamic position, // LatLng
    required this.type,
  }) : super(id: id, name: name, position: position);
}
