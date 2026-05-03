import 'node.dart';

enum HospitalType {
  cardiac,
  general,
  trauma,
  neuro,
  burn,
  icu,
}

class Hospital extends Node {
  final HospitalType type;
  final bool isAvailable;
  final String specialty;
  final String address;
  final double rating;

  Hospital({
    required String id,
    required String name,
    required dynamic position,
    required this.type,
    this.isAvailable = true,
    this.specialty = 'Emergency Care',
    this.address = 'Pune, Maharashtra',
    this.rating = 4.5,
  }) : super(id: id, name: name, position: position);
}
