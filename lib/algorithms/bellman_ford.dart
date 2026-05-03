import '../models/node.dart';
import '../models/edge.dart';
import 'base_algorithm.dart';

class BellmanFordAlgorithm extends BaseAlgorithm {
  @override
  AlgorithmResult run(Map<Node, List<Edge>> adjacencyList, Node start, Node end) {
    final stopwatch = Stopwatch()..start();
    final distances = <Node, double>{};
    final previous = <Node, Node?>{};
    final nodes = adjacencyList.keys.toList();
    int nodesVisitedCount = 0;

    // Initialization
    for (var node in nodes) {
      distances[node] = double.infinity;
      previous[node] = null;
    }
    distances[start] = 0;

    // Relax edges |V| - 1 times
    for (int i = 0; i < nodes.length - 1; i++) {
      bool changed = false;
      for (var u in nodes) {
        for (var edge in adjacencyList[u] ?? []) {
          final v = edge.destination;
          final weight = edge.effectiveWeight;
          
          if (distances[u] != double.infinity && distances[u]! + weight < (distances[v] ?? double.infinity)) {
            distances[v] = distances[u]! + weight;
            previous[v] = u;
            changed = true;
          }
        }
      }
      nodesVisitedCount += nodes.length; // Count each iteration's node checks
      if (!changed) break; // Optimization
    }

    // Path reconstruction
    final path = <Node>[];
    if (distances[end] != null && distances[end] != double.infinity) {
      Node? curr = end;
      while (curr != null) {
        path.insert(0, curr);
        curr = previous[curr];
      }
    }

    // Handle case where path is just one node but it's not the start node
    if (path.length == 1 && path[0] != start) {
      path.clear();
    }

    stopwatch.stop();
    return AlgorithmResult(
      algorithmName: 'Bellman-Ford',
      path: path,
      totalWeight: distances[end] ?? double.infinity,
      nodesVisited: nodesVisitedCount,
      executionTime: stopwatch.elapsed,
    );
  }
}
