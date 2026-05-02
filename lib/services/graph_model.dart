import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/node.dart';
import '../models/edge.dart';
import '../models/hospital.dart';

class GraphModel {
  final Map<Node, List<Edge>> adjacencyList = {};
  final List<Node> nodes = [];
  final List<Hospital> hospitals = [];
  late Node ambulanceLocation;

  GraphModel() {
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
      name: 'Premchand Oswal Hospital',
      position: LatLng(18.4700, 73.8700),
      type: HospitalType.cardiac,
    );

    final hB = Hospital(
      id: 'hosp_b',
      name: 'Mahesh Hospital',
      position: LatLng(18.4550, 73.8800),
      type: HospitalType.general,
    );

    final hC = Hospital(
      id: 'hosp_c',
      name: 'City Care Hospital',
      position: LatLng(18.4600, 73.8600),
      type: HospitalType.trauma,
    );

    final hD = Hospital(
      id: 'hosp_d',
      name: 'Sukhsagar Hospital',
      position: LatLng(18.4620, 73.8690),
      type: HospitalType.general,
    );

    hospitals.addAll([hA, hB, hC, hD]);

    final i1 = Node(id: 'i1', name: 'Intersection 1', position: LatLng(18.4650, 73.8650));
    final i2 = Node(id: 'i2', name: 'Intersection 2', position: LatLng(18.4680, 73.8680));
    final i3 = Node(id: 'i3', name: 'Intersection 3', position: LatLng(18.4580, 73.8700));
    final i4 = Node(id: 'i4', name: 'Intersection 4', position: LatLng(18.4600, 73.8750));

    nodes.addAll([ambulanceLocation, hA, hB, hC, hD, i1, i2, i3, i4]);

    _addEdge(ambulanceLocation, i1);
    _addEdge(ambulanceLocation, i3);
    _addEdge(i1, hC);
    _addEdge(i1, i2);
    _addEdge(i2, hA);
    _addEdge(i3, i4);
    _addEdge(i4, hB);
    _addEdge(i2, i4);
    _addEdge(i3, hC);
    _addEdge(hD, i2);
    _addEdge(hD, i4);
  }

  void _addEdge(Node u, Node v, [double? weight]) {
    final dist = weight ?? _calculateDistance(u.position, v.position) * 111;
    adjacencyList.putIfAbsent(u, () => []).add(Edge(source: u, destination: v, weight: dist));
    adjacencyList.putIfAbsent(v, () => []).add(Edge(source: v, destination: u, weight: dist));
  }

  void resetGraph() {
    for (var edges in adjacencyList.values) {
      for (var edge in edges) {
        edge.trafficLevel = 0.0;
        edge.riskFactor = 0.0;
        edge.isBlocked = false;
      }
    }
  }

  Hospital getPriorityHospital(String emergencyType) {
    if (emergencyType == 'Heart Attack') {
      return hospitals.firstWhere((h) => h.type == HospitalType.cardiac);
    } else if (emergencyType == 'Accident') {
      return hospitals.firstWhere((h) => h.type == HospitalType.trauma);
    } else {
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
