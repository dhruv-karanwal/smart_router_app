import 'node.dart';

class Edge {
  final Node source;
  final Node destination;
  final double weight; // Base distance or time
  double trafficMultiplier;
  bool isBlocked;

  Edge({
    required this.source,
    required this.destination,
    required this.weight,
    this.trafficMultiplier = 1.0,
    this.isBlocked = false,
  });

  double get effectiveWeight => isBlocked ? double.infinity : weight * trafficMultiplier;

  @override
  String toString() => 'Edge(${source.name} -> ${destination.name}, weight: $effectiveWeight, blocked: $isBlocked)';
}
