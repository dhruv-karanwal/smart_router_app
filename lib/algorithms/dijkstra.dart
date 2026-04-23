import 'package:collection/collection.dart';
import '../models/node.dart';
import '../models/edge.dart';
import 'base_algorithm.dart';

class DijkstraNode implements Comparable<DijkstraNode> {
  final Node node;
  final double distance;

  DijkstraNode(this.node, this.distance);

  @override
  int compareTo(DijkstraNode other) => distance.compareTo(other.distance);
}

class DijkstraAlgorithm extends BaseAlgorithm {
  @override
  AlgorithmResult run(Map<Node, List<Edge>> adjacencyList, Node start, Node end) {
    final stopwatch = Stopwatch()..start();
    final distances = <Node, double>{};
    final previous = <Node, Node?>{};
    final pq = PriorityQueue<DijkstraNode>();
    final visited = <Node>{};
    int nodesVisitedCount = 0;

    for (var node in adjacencyList.keys) {
      distances[node] = double.infinity;
    }
    distances[start] = 0;
    pq.add(DijkstraNode(start, 0));

    while (pq.isNotEmpty) {
      final current = pq.removeFirst();
      final currentNode = current.node;

      if (visited.contains(currentNode)) continue;
      visited.add(currentNode);
      nodesVisitedCount++;

      if (currentNode == end) break;

      for (var edge in adjacencyList[currentNode] ?? []) {
        final neighbor = edge.destination;
        final newDist = distances[currentNode]! + edge.effectiveWeight;

        if (newDist < (distances[neighbor] ?? double.infinity)) {
          distances[neighbor] = newDist;
          previous[neighbor] = currentNode;
          pq.add(DijkstraNode(neighbor, newDist));
        }
      }
    }

    final path = <Node>[];
    Node? curr = end;
    while (curr != null) {
      path.insert(0, curr);
      curr = previous[curr];
    }

    // If no path found, ensure path is empty if start != end
    if (path.length == 1 && path[0] != start) {
      path.clear();
    }

    stopwatch.stop();
    return AlgorithmResult(
      algorithmName: 'Dijkstra',
      path: path,
      totalWeight: distances[end] ?? double.infinity,
      nodesVisited: nodesVisitedCount,
      executionTime: stopwatch.elapsed,
    );
  }
}
