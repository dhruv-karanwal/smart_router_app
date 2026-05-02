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
    // ONLY allow Dijkstra and A* for final routing as per requirements
    final optimalResults = results.where((r) => 
      (r.algorithmName == 'Dijkstra' || r.algorithmName == 'A*') && 
      r.path.isNotEmpty && 
      r.totalWeight < double.infinity
    ).toList();
    
    if (optimalResults.isEmpty) {
      // Fallback only if optimal ones fail
      return results.firstWhere((r) => r.path.isNotEmpty, orElse: () => results.first);
    }

    // Sort by total distance (weight)
    optimalResults.sort((a, b) => a.totalWeight.compareTo(b.totalWeight));
    final best = optimalResults.first;

    // Debug Verification (as requested)
    print('--- ROUTING DEBUG ---');
    print('Algorithm: ${best.algorithmName}');
    print('Total Distance: ${best.totalWeight.toStringAsFixed(3)} km');
    print('Path Nodes: ${best.path.map((n) => n.id).join(' -> ')}');
    print('Visited Nodes: ${best.nodesVisited}');
    print('No loops detected: ${best.path.toSet().length == best.path.length}');
    print('---------------------');

    return best;
  }
}
