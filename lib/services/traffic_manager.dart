import 'dart:math';
import '../models/edge.dart';
import 'graph_model.dart';

enum TrafficLevel { low, medium, high }

class TrafficManager {
  final GraphModel graph;
  final Random _random = Random();

  TrafficManager(this.graph);

  void updateTraffic(bool simulate) {
    for (var edges in graph.adjacencyList.values) {
      for (var edge in edges) {
        if (simulate) {
          final level = _getRandomTrafficLevel();
          edge.trafficMultiplier = _getMultiplier(level);
        } else {
          edge.trafficMultiplier = 1.0;
        }
      }
    }
  }

  TrafficLevel _getRandomTrafficLevel() {
    final rand = _random.nextDouble();
    if (rand < 0.6) return TrafficLevel.low;
    if (rand < 0.9) return TrafficLevel.medium;
    return TrafficLevel.high;
  }

  double _getMultiplier(TrafficLevel level) {
    switch (level) {
      case TrafficLevel.low:
        return 1.0;
      case TrafficLevel.medium:
        return 1.5;
      case TrafficLevel.high:
        return 2.0 + _random.nextDouble(); // 2.0x to 3.0x
    }
  }
}
