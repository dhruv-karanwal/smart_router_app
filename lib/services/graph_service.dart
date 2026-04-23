import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/node.dart';
import '../models/edge.dart';
import '../models/hospital.dart';

class GraphService {
  final Map<Node, List<Edge>> adjacencyList = {};
  final List<Node> nodes = [];
  final List<Hospital> hospitals = [];
  late Node ambulanceLocation;

  bool isTrafficEnabled = false;

  GraphService() {
    _initializeData();
  }

  void _initializeData() {
    ambulanceLocation = Node(
      id: 'vit_pune',
      name: 'VIT Pune, Bibewadi',
      position: LatLng(18.4635, 73.8682),
    );

    final hA = Hospital(
      id: 'hosp_a',
      name: 'Hospital A (Cardiac)',
      position: LatLng(18.4700, 73.8700),
      type: HospitalType.cardiac,
    );

    final hB = Hospital(
      id: 'hosp_b',
      name: 'Hospital B (General)',
      position: LatLng(18.4550, 73.8800),
      type: HospitalType.general,
    );

    final hC = Hospital(
      id: 'hosp_c',
      name: 'Hospital C (Trauma)',
      position: LatLng(18.4600, 73.8600),
      type: HospitalType.trauma,
    );

    hospitals.addAll([hA, hB, hC]);

    final i1 = Node(id: 'i1', name: 'Intersection 1', position: LatLng(18.4650, 73.8650));
    final i2 = Node(id: 'i2', name: 'Intersection 2', position: LatLng(18.4680, 73.8680));
    final i3 = Node(id: 'i3', name: 'Intersection 3', position: LatLng(18.4580, 73.8700));
    final i4 = Node(id: 'i4', name: 'Intersection 4', position: LatLng(18.4600, 73.8750));

    nodes.addAll([ambulanceLocation, hA, hB, hC, i1, i2, i3, i4]);

    _addEdge(ambulanceLocation, i1, 0.5);
    _addEdge(ambulanceLocation, i3, 0.7);
    _addEdge(i1, hC, 0.6);
    _addEdge(i1, i2, 0.4);
    _addEdge(i2, hA, 0.3);
    _addEdge(i3, i4, 0.5);
    _addEdge(i4, hB, 0.6);
    _addEdge(i2, i4, 0.8);
    _addEdge(i3, hC, 0.4);
    _addEdge(i4, i2, 0.8); // Bidirectional
    _addEdge(hC, i3, 0.4);
    _addEdge(hA, i2, 0.3);
  }

  void _addEdge(Node u, Node v, double weight) {
    adjacencyList.putIfAbsent(u, () => []).add(Edge(source: u, destination: v, weight: weight));
    adjacencyList.putIfAbsent(v, () => []).add(Edge(source: v, destination: u, weight: weight));
  }

  void toggleTraffic(bool enabled) {
    isTrafficEnabled = enabled;
    final random = Random();
    for (var edges in adjacencyList.values) {
      for (var edge in edges) {
        if (isTrafficEnabled) {
          // Increase weights randomly or simulate block
          edge.trafficMultiplier = 1.0 + random.nextDouble() * 5.0; // 1x to 6x
          if (random.nextDouble() < 0.1) {
            edge.trafficMultiplier = 1000.0; // Simulated block
          }
        } else {
          edge.trafficMultiplier = 1.0;
        }
      }
    }
  }

  Hospital getPriorityHospital(String emergencyType) {
    if (emergencyType == 'Heart Attack') {
      return hospitals.firstWhere((h) => h.type == HospitalType.cardiac);
    } else if (emergencyType == 'Accident') {
      return hospitals.firstWhere((h) => h.type == HospitalType.trauma);
    } else {
      // Find nearest
      Hospital nearest = hospitals[0];
      double minDist = double.infinity;
      for (var h in hospitals) {
        double d = _calculateDistance(ambulanceLocation.position, h.position);
        if (d < minDist) {
          minDist = d;
          nearest = h;
        }
      }
      return nearest;
    }
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    return sqrt(pow(p1.latitude - p2.latitude, 2) + pow(p1.longitude - p2.longitude, 2));
  }
}
