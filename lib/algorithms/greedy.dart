import 'dart:math';
import 'package:collection/collection.dart';
import '../models/node.dart';
import '../models/edge.dart';
import 'base_algorithm.dart';

class GreedyNode implements Comparable<GreedyNode> {
  final Node node;
  final double hScore;

  GreedyNode(this.node, this.hScore);

  @override
  int compareTo(GreedyNode other) => hScore.compareTo(other.hScore);
}

class GreedyAlgorithm extends BaseAlgorithm {
  double _heuristic(Node a, Node b) {
    // Euclidean distance in degrees converted to km (approx)
    return sqrt(pow(a.position.latitude - b.position.latitude, 2) +
        pow(a.position.longitude - b.position.longitude, 2)) * 111;
  }

  @override
  AlgorithmResult run(Map<Node, List<Edge>> adjacencyList, Node start, Node end) {
    final stopwatch = Stopwatch()..start();
    final previous = <Node, Node?>{};
    final pq = PriorityQueue<GreedyNode>();
    final visited = <Node>{};
    int nodesVisitedCount = 0;

    pq.add(GreedyNode(start, _heuristic(start, end)));
    visited.add(start);
    previous[start] = null;

    bool found = false;
    while (pq.isNotEmpty) {
      final current = pq.removeFirst();
      final currentNode = current.node;
      nodesVisitedCount++;

      if (currentNode == end) {
        found = true;
        break;
      }

      for (var edge in adjacencyList[currentNode] ?? []) {
        final neighbor = edge.destination;
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          previous[neighbor] = currentNode;
          pq.add(GreedyNode(neighbor, _heuristic(neighbor, end)));
        }
      }
    }

    final path = <Node>[];
    double totalWeight = 0;
    if (found) {
      Node? curr = end;
      while (curr != null) {
        path.insert(0, curr);
        Node? prev = previous[curr];
        if (prev != null) {
          final edge = adjacencyList[prev]?.firstWhere((e) => e.destination == curr);
          totalWeight += edge?.effectiveWeight ?? 0;
        }
        curr = prev;
      }
    }

    stopwatch.stop();
    return AlgorithmResult(
      algorithmName: 'Greedy',
      path: path,
      totalWeight: totalWeight,
      nodesVisited: nodesVisitedCount,
      executionTime: stopwatch.elapsed,
    );
  }
}
