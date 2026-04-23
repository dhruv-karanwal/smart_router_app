import '../algorithms/base_algorithm.dart';
import '../algorithms/dijkstra.dart';
import '../algorithms/astar.dart';
import '../algorithms/bfs.dart';
import '../algorithms/dfs.dart';
import '../algorithms/greedy.dart';
import '../models/node.dart';
import '../models/edge.dart';

class RoutingEngine {
  final List<BaseAlgorithm> algorithms = [
    DijkstraAlgorithm(),
    AStarAlgorithm(),
    BFSAlgorithm(),
    DFSAlgorithm(),
    GreedyAlgorithm(),
  ];

  List<AlgorithmResult> runAll(Map<Node, List<Edge>> adjacencyList, Node start, Node end) {
    return algorithms.map((alg) => alg.run(adjacencyList, start, end)).toList();
  }

  AlgorithmResult selectBest(List<AlgorithmResult> results) {
    // Select best based on minimum total weight (which includes traffic)
    // Exclude algorithms that failed to find a path (weight = infinity)
    final validResults = results.where((r) => r.path.isNotEmpty && r.totalWeight < double.infinity).toList();
    
    if (validResults.isEmpty) {
      return results.first; // Fallback
    }

    validResults.sort((a, b) => a.totalWeight.compareTo(b.totalWeight));
    return validResults.first;
  }
}
