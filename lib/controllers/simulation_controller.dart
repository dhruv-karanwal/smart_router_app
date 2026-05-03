import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../services/graph_model.dart';
import '../services/traffic_manager.dart';
import '../services/routing_engine.dart';
import '../models/node.dart';
import '../models/edge.dart';
import '../services/hospital_selector.dart';
import '../models/hospital.dart';
import '../models/incident.dart';
import '../algorithms/base_algorithm.dart';
import '../utils/geo_utils.dart';

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
  bool _showAllHospitals = false;
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
  bool get showAllHospitals => _showAllHospitals;
  List<HospitalRank> get hospitalRanks => _hospitalRanks;
  AlgorithmResult? get bestRoute => _bestRoute;

  final List<Incident> _incidents = [];
  List<Incident> get incidents => _incidents;

  void triggerIncident(IncidentType type, [LatLng? location]) {
    final loc = location ?? graph.ambulanceLocation.position;
    final id = 'inc_${DateTime.now().millisecondsSinceEpoch}';
    
    String desc = '';
    switch (type) {
      case IncidentType.heartAttack: desc = 'Heart Attack reported'; break;
      case IncidentType.cardiacArrest: desc = 'Cardiac Arrest reported'; break;
      case IncidentType.stroke: desc = 'Stroke reported'; break;
      case IncidentType.accident: desc = 'Major Accident reported'; break;
      case IncidentType.severeBleeding: desc = 'Severe Bleeding reported'; break;
      case IncidentType.burns: desc = 'Severe Burns reported'; break;
      case IncidentType.poisoning: desc = 'Poisoning case reported'; break;
      case IncidentType.traffic: desc = 'Heavy Traffic detected'; break;
      case IncidentType.roadBlock: desc = 'Road Blocked ahead'; break;
      case IncidentType.general: desc = 'General Emergency reported'; break;
    }

    final incident = Incident(
      id: id,
      type: type,
      location: loc,
      description: desc,
      severity: type == IncidentType.roadBlock ? 1.0 : 0.7,
    );

    _incidents.add(incident);
    
    if (type == IncidentType.roadBlock) {
      // Find nearest edge and block it
      _blockNearestEdge(loc);
    }
    
    // Set emergency type based on incident
    if (type == IncidentType.heartAttack) _emergencyType = 'Heart Attack';
    if (type == IncidentType.cardiacArrest) _emergencyType = 'Cardiac Arrest';
    if (type == IncidentType.stroke) _emergencyType = 'Stroke';
    if (type == IncidentType.accident) _emergencyType = 'Accident';
    if (type == IncidentType.severeBleeding) _emergencyType = 'Severe Bleeding';
    if (type == IncidentType.burns) _emergencyType = 'Burns';
    if (type == IncidentType.poisoning) _emergencyType = 'Poisoning';
    if (type == IncidentType.general) _emergencyType = 'General Emergency';

    refreshHospitals();
    
    if (_isAutoSelect && _hospitalRanks.isNotEmpty) {
      _selectedHospital = _hospitalRanks.first.hospital;
    }
    
    notifyListeners();
  }

  void _blockNearestEdge(LatLng loc) {
    // Simplified: Block a random edge for simulation
    for (var edges in graph.adjacencyList.values) {
      for (var edge in edges) {
        if (GeoUtils.haversineDistance(edge.source.position, loc) < 0.5) {
          edge.isBlocked = true;
          return;
        }
      }
    }
  }

  void clearIncidents() {
    _incidents.clear();
    graph.resetGraph();
    refreshHospitals();
    notifyListeners();
  }

  void setEmergencyType(String type) {
    _emergencyType = type;
    if (_isAutoSelect) {
      refreshHospitals();
      _selectedHospital = _hospitalRanks.isNotEmpty ? _hospitalRanks.first.hospital : null;
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
      _selectedHospital = _hospitalRanks.isNotEmpty ? _hospitalRanks.first.hospital : null;
    }
    notifyListeners();
  }

  void toggleShowAllHospitals() {
    _showAllHospitals = !_showAllHospitals;
    refreshHospitals();
    notifyListeners();
  }

  void refreshHospitals() {
    final allRanks = _hospitalSelector.rankHospitals(
      hospitals: graph.hospitals,
      emergencyType: _emergencyType,
      trafficIntensity: _trafficIntensity,
      incidents: _incidents,
    );

    if (_showAllHospitals) {
      _hospitalRanks = allRanks;
    } else {
      _hospitalRanks = allRanks.take(5).toList();
    }
  }

  void toggleHospitalAvailability() {
    if (_selectedHospital != null) {
      final updatedHospital = Hospital(
        id: _selectedHospital!.id,
        name: _selectedHospital!.name,
        position: _selectedHospital!.position,
        type: _selectedHospital!.type,
        isAvailable: !_selectedHospital!.isAvailable,
        specialty: _selectedHospital!.specialty,
        address: _selectedHospital!.address,
        rating: _selectedHospital!.rating,
      );
      
      // Update in graph hospitals list
      final index = graph.hospitals.indexWhere((h) => h.id == _selectedHospital!.id);
      if (index != -1) {
        graph.hospitals[index] = updatedHospital;
      }
      
      _selectedHospital = updatedHospital;
      refreshHospitals();
      
      if (_isAutoSelect) {
        _selectedHospital = _hospitalRanks.isNotEmpty ? _hospitalRanks.first.hospital : null;
      }
      
      notifyListeners();
    }
  }

  void setTrafficIntensity(double intensity) {
    _trafficIntensity = intensity;
    _currentScenario = TrafficScenario.normal;
    refreshHospitals();
    if (_isAutoSelect) {
      _selectedHospital = _hospitalRanks.isNotEmpty ? _hospitalRanks.first.hospital : null;
    }
    notifyListeners();
  }

  void setScenario(TrafficScenario scenario) {
    _currentScenario = scenario;
    _trafficIntensity = trafficManager.getIntensityForScenario(scenario);
    trafficManager.applyScenario(scenario);
    refreshHospitals();
    if (_isAutoSelect) {
      _selectedHospital = _hospitalRanks.isNotEmpty ? _hospitalRanks.first.hospital : null;
    }
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
