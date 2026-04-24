import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/graph_model.dart';
import '../services/traffic_manager.dart';
import '../services/routing_engine.dart';
import '../algorithms/base_algorithm.dart';
import '../models/node.dart';
import '../models/edge.dart';

class SimulationController extends ChangeNotifier {
  final GraphModel graph;
  final TrafficManager trafficManager;
  final RoutingEngine routingEngine;
  final Random _random = Random();

  bool _isTrafficSimulationEnabled = false;
  AlgorithmResult? _bestRoute;

  SimulationController({
    required this.graph,
    required this.trafficManager,
    required this.routingEngine,
  });

  bool get isTrafficSimulationEnabled => _isTrafficSimulationEnabled;
  AlgorithmResult? get bestRoute => _bestRoute;

  void toggleTrafficSimulation(bool enabled) {
    _isTrafficSimulationEnabled = enabled;
    trafficManager.updateTraffic(enabled);
    notifyListeners();
  }

  void blockRandomRoad() {
    final allEdges = graph.adjacencyList.values.expand((e) => e).toList();
    if (allEdges.isEmpty) return;

    final randomEdge = allEdges[_random.nextInt(allEdges.length)];
    randomEdge.isBlocked = true;
    
    // Also block the reverse edge to be consistent (as the graph is bidirectional)
    final reverseEdge = graph.adjacencyList[randomEdge.destination]?.firstWhere(
      (e) => e.destination == randomEdge.source,
      orElse: () => randomEdge,
    );
    if (reverseEdge != null) reverseEdge.isBlocked = true;

    notifyListeners();
  }

  void resetMap() {
    graph.resetGraph();
    _isTrafficSimulationEnabled = false;
    notifyListeners();
  }

  void updateRoute(Node start, Node end) {
    final results = routingEngine.runAll(graph.adjacencyList, start, end);
    _bestRoute = routingEngine.selectBest(results);
    // Note: We don't notifyListeners here if this is called during a build or from map screen to avoid loops,
    // but if it's called from simulation actions, we should.
    // However, the map screen will call this when it detects a change.
  }
}
