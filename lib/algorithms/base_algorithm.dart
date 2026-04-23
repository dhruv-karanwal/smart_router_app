import '../models/node.dart';
import '../models/edge.dart';

class AlgorithmResult {
  final String algorithmName;
  final List<Node> path;
  final double totalWeight;
  final int nodesVisited;
  final Duration executionTime;

  AlgorithmResult({
    required this.algorithmName,
    required this.path,
    required this.totalWeight,
    required this.nodesVisited,
    required this.executionTime,
  });

  @override
  String toString() {
    return '$algorithmName: pathLength=${path.length}, weight=$totalWeight, visited=$nodesVisited';
  }
}

abstract class BaseAlgorithm {
  AlgorithmResult run(Map<Node, List<Edge>> adjacencyList, Node start, Node end);
}
