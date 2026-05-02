import 'package:flutter/foundation.dart';
import '../services/graph_model.dart';
import '../services/traffic_manager.dart';
import '../services/routing_engine.dart';
import '../models/node.dart';
import '../models/edge.dart';
import '../services/hospital_selector.dart';
import '../models/hospital.dart';
import '../algorithms/base_algorithm.dart';

class SimulationController extends ChangeNotifier {
  final GraphModel graph;
  final TrafficManager trafficManager;
  final RoutingEngine routingEngine;
  late final HospitalSelector _hospitalSelector;
  
  double _trafficIntensity = 0.5;
  TrafficScenario _currentScenario = TrafficScenario.normal;
  String _emergencyType = 'General';
  Hospital? _selectedHospital;
  bool _isAutoSelect = true;
  List<HospitalRank> _hospitalRanks = [];
  AlgorithmResult? _bestRoute;

  SimulationController({
    required this.graph,
    required this.trafficManager,
    required this.routingEngine,
  }) {
    _hospitalSelector = HospitalSelector(graph: graph, routingEngine: routingEngine);
    _selectedHospital = graph.hospitals.first;
    refreshHospitals();
  }

  double get trafficIntensity => _trafficIntensity;
  TrafficScenario get currentScenario => _currentScenario;
  String get emergencyType => _emergencyType;
  Hospital? get selectedHospital => _selectedHospital;
  bool get isAutoSelect => _isAutoSelect;
  List<HospitalRank> get hospitalRanks => _hospitalRanks;
  AlgorithmResult? get bestRoute => _bestRoute;

  void setEmergencyType(String type) {
    _emergencyType = type;
    if (_isAutoSelect) {
      refreshHospitals();
      _selectedHospital = _hospitalRanks.first.hospital;
    }
    notifyListeners();
  }

  void selectHospital(Hospital hospital, {bool manual = true}) {
    _selectedHospital = hospital;
    if (manual) _isAutoSelect = false;
    notifyListeners();
  }

  void toggleAutoSelect(bool value) {
    _isAutoSelect = value;
    if (value) {
      refreshHospitals();
      _selectedHospital = _hospitalRanks.first.hospital;
    }
    notifyListeners();
  }

  void refreshHospitals() {
    _hospitalRanks = _hospitalSelector.rankHospitals(
      hospitals: graph.hospitals,
      emergencyType: _emergencyType,
      trafficIntensity: _trafficIntensity,
    );
  }

  void setTrafficIntensity(double intensity) {
    _trafficIntensity = intensity;
    _currentScenario = TrafficScenario.custom;
    trafficManager.setManualIntensity(intensity);
    if (_isAutoSelect) refreshHospitals();
    notifyListeners();
  }


  void setScenario(TrafficScenario scenario) {
    _currentScenario = scenario;
    trafficManager.setScenario(scenario);
    if (_isAutoSelect) refreshHospitals();
    notifyListeners();
  }

  void toggleRoadBlock(Edge edge) {
    edge.isBlocked = !edge.isBlocked;
    final reverseEdges = graph.adjacencyList[edge.destination] ?? [];
    for (var e in reverseEdges) {
      if (e.destination == edge.source) {
        e.isBlocked = edge.isBlocked;
      }
    }
    notifyListeners();
  }

  void resetMap() {
    graph.resetGraph();
    trafficManager.reset();
    _trafficIntensity = 0.5;
    _currentScenario = TrafficScenario.normal;
    _isAutoSelect = true;
    _selectedHospital = graph.hospitals.first;
    refreshHospitals();
    notifyListeners();
  }

  void updateRoute(Node start, Node end) {
    final results = routingEngine.runAll(graph.adjacencyList, start, end);
    _bestRoute = routingEngine.selectBest(results);
  }
}
