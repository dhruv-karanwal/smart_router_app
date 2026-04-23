import 'dart:collection';
import '../models/node.dart';
import '../models/edge.dart';
import 'base_algorithm.dart';

class BFSAlgorithm extends BaseAlgorithm {
  @override
  AlgorithmResult run(Map<Node, List<Edge>> adjacencyList, Node start, Node end) {
    final stopwatch = Stopwatch()..start();
    final queue = Queue<Node>();
    final visited = <Node, Node?>{};
    int nodesVisitedCount = 0;

    queue.add(start);
    visited[start] = null;

    bool found = false;
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      nodesVisitedCount++;

      if (current == end) {
        found = true;
        break;
      }

      for (var edge in adjacencyList[current] ?? []) {
        final neighbor = edge.destination;
        if (!visited.containsKey(neighbor)) {
          visited[neighbor] = current;
          queue.add(neighbor);
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
      algorithmName: 'BFS',
      path: path,
      totalWeight: totalWeight,
      nodesVisited: nodesVisitedCount,
      executionTime: stopwatch.elapsed,
    );
  }
}
