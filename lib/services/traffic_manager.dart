import 'dart:math';
import '../models/edge.dart';
import 'graph_model.dart';

enum TrafficScenario { normal, heavy, emergency, custom }

class TrafficManager {
  final GraphModel graph;
  final Random _random = Random();
  
  double _manualIntensity = 0.5;
  TrafficScenario _currentScenario = TrafficScenario.normal;

  TrafficManager(this.graph);

  void setManualIntensity(double intensity) {
    _manualIntensity = intensity;
    _currentScenario = TrafficScenario.custom;
    applyTraffic();
  }

  void setScenario(TrafficScenario scenario) {
    _currentScenario = scenario;
    applyTraffic();
  }

  void applyTraffic() {
    for (var edges in graph.adjacencyList.values) {
      for (var edge in edges) {
        switch (_currentScenario) {
          case TrafficScenario.normal:
            edge.trafficLevel = _random.nextDouble() * 0.3;
            edge.riskFactor = 0.1;
            break;
          case TrafficScenario.heavy:
            edge.trafficLevel = 0.6 + (_random.nextDouble() * 0.4);
            edge.riskFactor = 0.2;
            break;
          case TrafficScenario.emergency:
            edge.trafficLevel = 0.4 + (_random.nextDouble() * 0.4);
            edge.riskFactor = 0.7; // Higher risk of blockages
            break;
          case TrafficScenario.custom:
            edge.trafficLevel = _manualIntensity;
            edge.riskFactor = _manualIntensity * 0.5;
            break;
        }
      }
    }
  }

  void reset() {
    _currentScenario = TrafficScenario.normal;
    _manualIntensity = 0.5;
    applyTraffic();
  }
}
