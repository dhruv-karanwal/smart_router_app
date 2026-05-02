import 'dart:math';
import '../models/hospital.dart';
import '../algorithms/priority_queue.dart';
import '../services/routing_engine.dart';
import '../services/graph_model.dart';

class HospitalSelector {
  final GraphModel graph;
  final RoutingEngine routingEngine;

  HospitalSelector({required this.graph, required this.routingEngine});

  /// Priority Score = α * Distance + β * Traffic + γ * EmergencyPriority
  double calculateScore({
    required Hospital hospital,
    required double routeDistance,
    required double trafficIntensity,
    required String emergencyType,
  }) {
    const alpha = 0.5;
    const beta = 0.3;
    const gamma = 0.2;

    // Emergency Priority Mapping (0.0 to 1.0, where 0 is better/higher priority)
    double emergencyWeight = 1.0;
    if (emergencyType == 'Heart Attack' && hospital.type == HospitalType.cardiac) {
      emergencyWeight = 0.0;
    } else if (emergencyType == 'Accident' && hospital.type == HospitalType.trauma) {
      emergencyWeight = 0.0;
    } else if (hospital.type == HospitalType.general) {
      emergencyWeight = 0.5;
    }

    // Normalized Score (lower is better)
    return (alpha * routeDistance) + 
           (beta * trafficIntensity * 10) + 
           (gamma * emergencyWeight * 5);
  }

  List<HospitalRank> rankHospitals({
    required List<Hospital> hospitals,
    required String emergencyType,
    required double trafficIntensity,
  }) {
    final heap = MinHeap<HospitalRank>();

    for (var hospital in hospitals) {
      // For ranking, we use a simpler distance estimate or pre-calculated path
      // In a real app, we might run Dijkstra for all, but here we'll use Euclidean for ranking speed
      final dist = _estimateDistance(graph.ambulanceLocation.position, hospital.position);
      final score = calculateScore(
        hospital: hospital,
        routeDistance: dist,
        trafficIntensity: trafficIntensity,
        emergencyType: emergencyType,
      );

      heap.insert(
        HospitalRank(hospital: hospital, score: score, distance: dist),
        score,
      );
    }

    return heap.toSortedList();
  }

  double _estimateDistance(dynamic p1, dynamic p2) {
    return sqrt(pow(p1.latitude - p2.latitude, 2) + pow(p1.longitude - p2.longitude, 2)) * 111;
  }
}

class HospitalRank {
  final Hospital hospital;
  final double score;
  final double distance;

  HospitalRank({
    required this.hospital,
    required this.score,
    required this.distance,
  });
}
