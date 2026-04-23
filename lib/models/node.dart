import 'package:latlong2/latlong.dart';

class Node {
  final String id;
  final String name;
  final LatLng position;

  Node({
    required this.id,
    required this.name,
    required this.position,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Node($name)';
}
