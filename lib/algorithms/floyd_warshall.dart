import '../models/node.dart';
import '../models/edge.dart';
import 'base_algorithm.dart';

class FloydWarshallAlgorithm extends BaseAlgorithm {
  @override
  AlgorithmResult run(Map<Node, List<Edge>> adjacencyList, Node start, Node end) {
    final stopwatch = Stopwatch()..start();
    final nodes = adjacencyList.keys.toList();
    final n = nodes.length;
    
    // Distance matrix initialized to infinity
    final dist = List.generate(n, (_) => List.filled(n, double.infinity));
    // Path reconstruction matrix
    final next = List.generate(n, (_) => List<int?>.filled(n, null));

    final nodeToIndex = {for (int i = 0; i < n; i++) nodes[i]: i};

    // Initialize with edges
    for (int i = 0; i < n; i++) {
      dist[i][i] = 0;
      final u = nodes[i];
      for (var edge in adjacencyList[u] ?? []) {
        final v = edge.destination;
        final vIdx = nodeToIndex[v];
        if (vIdx != null) {
          final weight = edge.effectiveWeight;
          if (weight < dist[i][vIdx]) {
            dist[i][vIdx] = weight;
            next[i][vIdx] = vIdx;
          }
        }
      }
    }

    // Dynamic Programming steps
    for (int k = 0; k < n; k++) {
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          if (dist[i][k] != double.infinity && 
              dist[k][j] != double.infinity && 
              dist[i][k] + dist[k][j] < dist[i][j]) {
            dist[i][j] = dist[i][k] + dist[k][j];
            next[i][j] = next[i][k];
          }
        }
      }
    }

    // Reconstruct path from start to end
    final path = <Node>[];
    final startIdx = nodeToIndex[start];
    final endIdx = nodeToIndex[end];

    if (startIdx != null && endIdx != null && dist[startIdx][endIdx] != double.infinity) {
      int? curr = startIdx;
      path.add(nodes[curr]);
      while (curr != endIdx) {
        curr = next[curr!][endIdx];
        if (curr == null) break;
        path.add(nodes[curr]);
      }
    }

    stopwatch.stop();
    return AlgorithmResult(
      algorithmName: 'Floyd-Warshall',
      path: path,
      totalWeight: (startIdx != null && endIdx != null) ? dist[startIdx][endIdx] : double.infinity,
      nodesVisited: n * n * n,
      executionTime: stopwatch.elapsed,
    );
  }
}
