import '../models/node.dart';
import '../models/edge.dart';
import 'base_algorithm.dart';

class DFSAlgorithm extends BaseAlgorithm {
  @override
  AlgorithmResult run(Map<Node, List<Edge>> adjacencyList, Node start, Node end) {
    final stopwatch = Stopwatch()..start();
    final visited = <Node, Node?>{};
    final stack = <Node>[start];
    int nodesVisitedCount = 0;

    visited[start] = null;
    bool found = false;

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      nodesVisitedCount++;

      if (current == end) {
        found = true;
        break;
      }

      for (var edge in adjacencyList[current] ?? []) {
        final neighbor = edge.destination;
        if (!visited.containsKey(neighbor)) {
          visited[neighbor] = current;
          stack.add(neighbor);
        }
      }
    }

    final path = <Node>[];
    double totalWeight = 0;
    if (found) {
      Node? curr = end;
      while (curr != null) {
        path.insert(0, curr);
        Node? prev = visited[curr];
        if (prev != null) {
          final edge = adjacencyList[prev]?.firstWhere((e) => e.destination == curr);
          totalWeight += edge?.effectiveWeight ?? 0;
        }
        curr = prev;
      }
    }

    stopwatch.stop();
    return AlgorithmResult(
      algorithmName: 'DFS',
      path: path,
      totalWeight: totalWeight,
      nodesVisited: nodesVisitedCount,
      executionTime: stopwatch.elapsed,
    );
  }
}
