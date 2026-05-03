import 'dart:collection';
import '../models/node.dart';
import '../models/edge.dart';
import 'base_algorithm.dart';

class BidirectionalSearchAlgorithm extends BaseAlgorithm {
  @override
  AlgorithmResult run(Map<Node, List<Edge>> adjacencyList, Node start, Node end) {
    final stopwatch = Stopwatch()..start();
    
    if (start == end) {
      stopwatch.stop();
      return AlgorithmResult(
        algorithmName: 'Bidirectional Search',
        path: [start],
        totalWeight: 0,
        nodesVisited: 1,
        executionTime: stopwatch.elapsed,
      );
    }

    final forwardQueue = Queue<Node>();
    final backwardQueue = Queue<Node>();
    
    final forwardVisited = <Node, Node?>{start: null};
    final backwardVisited = <Node, Node?>{end: null};
    
    forwardQueue.add(start);
    backwardQueue.add(end);
    
    Node? meetingNode;
    int nodesVisitedCount = 0;

    // Build reverse adjacency list for backward search
    final reverseAdjacency = <Node, List<Node>>{};
    final weights = <String, double>{}; // Store weights for total weight calculation "u_v" -> weight

    for (var u in adjacencyList.keys) {
      for (var edge in adjacencyList[u] ?? []) {
        final v = edge.destination;
        if (!edge.isBlocked) {
          reverseAdjacency.putIfAbsent(v, () => []).add(u);
          weights['${u.id}_${v.id}'] = edge.effectiveWeight;
        }
      }
    }

    while (forwardQueue.isNotEmpty && backwardQueue.isNotEmpty) {
      // Forward step
      final fNode = forwardQueue.removeFirst();
      nodesVisitedCount++;
      for (var edge in adjacencyList[fNode] ?? []) {
        if (edge.isBlocked) continue;
        final neighbor = edge.destination;
        if (!forwardVisited.containsKey(neighbor)) {
          forwardVisited[neighbor] = fNode;
          forwardQueue.add(neighbor);
          if (backwardVisited.containsKey(neighbor)) {
            meetingNode = neighbor;
            break;
          }
        }
      }
      if (meetingNode != null) break;

      // Backward step
      final bNode = backwardQueue.removeFirst();
      nodesVisitedCount++;
      for (var neighbor in reverseAdjacency[bNode] ?? []) {
        if (!backwardVisited.containsKey(neighbor)) {
          backwardVisited[neighbor] = bNode;
          backwardQueue.add(neighbor);
          if (forwardVisited.containsKey(neighbor)) {
            meetingNode = neighbor;
            break;
          }
        }
      }
      if (meetingNode != null) break;
    }

    final path = <Node>[];
    double totalWeight = 0;

    if (meetingNode != null) {
      // Reconstruct forward path (start -> ... -> meetingNode)
      final fPath = <Node>[];
      Node? curr = meetingNode;
      while (curr != null) {
        fPath.insert(0, curr);
        curr = forwardVisited[curr];
      }
      
      // Reconstruct backward path (meetingNode -> ... -> end)
      final bPath = <Node>[];
      curr = backwardVisited[meetingNode];
      while (curr != null) {
        bPath.add(curr);
        curr = backwardVisited[curr];
      }
      
      path.addAll(fPath);
      path.addAll(bPath);
      
      // Calculate total weight
      for (int i = 0; i < path.length - 1; i++) {
        final u = path[i];
        final v = path[i + 1];
        totalWeight += weights['${u.id}_${v.id}'] ?? 0;
      }
    }

    stopwatch.stop();
    return AlgorithmResult(
      algorithmName: 'Bidirectional Search',
      path: path,
      totalWeight: totalWeight,
      nodesVisited: nodesVisitedCount,
      executionTime: stopwatch.elapsed,
    );
  }
}
