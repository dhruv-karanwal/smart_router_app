import 'dart:math';
import 'package:collection/collection.dart';
import '../models/node.dart';
import '../models/edge.dart';
import 'base_algorithm.dart';

class AStarNode implements Comparable<AStarNode> {
  final Node node;
  final double gScore;
  final double fScore;

  AStarNode(this.node, this.gScore, this.fScore);

  @override
  int compareTo(AStarNode other) => fScore.compareTo(other.fScore);
}

class AStarAlgorithm extends BaseAlgorithm {
  double _heuristic(Node a, Node b) {
    // Euclidean distance in degrees converted to km (approx)
    return sqrt(pow(a.position.latitude - b.position.latitude, 2) +
        pow(a.position.longitude - b.position.longitude, 2)) * 111;
  }

  @override
  AlgorithmResult run(Map<Node, List<Edge>> adjacencyList, Node start, Node end) {
    final stopwatch = Stopwatch()..start();
    final gScore = <Node, double>{};
    final fScore = <Node, double>{};
    final previous = <Node, Node?>{};
    final pq = PriorityQueue<AStarNode>();
    final visited = <Node>{};
    int nodesVisitedCount = 0;

    for (var node in adjacencyList.keys) {
      gScore[node] = double.infinity;
      fScore[node] = double.infinity;
    }

    gScore[start] = 0;
    fScore[start] = _heuristic(start, end);
    pq.add(AStarNode(start, 0, fScore[start]!));

    while (pq.isNotEmpty) {
      final current = pq.removeFirst();
      final currentNode = current.node;

      if (visited.contains(currentNode)) continue;
      visited.add(currentNode);
      nodesVisitedCount++;

      if (currentNode == end) break;

      for (var edge in adjacencyList[currentNode] ?? []) {
        final neighbor = edge.destination;
        final tentativeGScore = gScore[currentNode]! + edge.effectiveWeight;

        if (tentativeGScore < (gScore[neighbor] ?? double.infinity)) {
          previous[neighbor] = currentNode;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = tentativeGScore + _heuristic(neighbor, end);
          pq.add(AStarNode(neighbor, tentativeGScore, fScore[neighbor]!));
        }
      }
    }

    final path = <Node>[];
    Node? curr = end;
    while (curr != null) {
      path.insert(0, curr);
      curr = previous[curr];
    }

    if (path.length == 1 && path[0] != start) {
      path.clear();
    }

    stopwatch.stop();
    return AlgorithmResult(
      algorithmName: 'A*',
      path: path,
      totalWeight: gScore[end] ?? double.infinity,
      nodesVisited: nodesVisitedCount,
      executionTime: stopwatch.elapsed,
    );
  }
}
