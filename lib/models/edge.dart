import 'node.dart';

class Edge {
  final Node source;
  final Node destination;
  final double weight; // Physical distance in km
  double _trafficLevel = 0.0;
  double _riskFactor = 0.0;
  bool isBlocked = false;

  double get trafficLevel => _trafficLevel;
  set trafficLevel(double value) => _trafficLevel = value;

  double get riskFactor => _riskFactor;
  set riskFactor(double value) => _riskFactor = value;

  Edge({
    required this.source,
    required this.destination,
    required this.weight,
    double trafficLevel = 0.0,
    double riskFactor = 0.0,
    this.isBlocked = false,
  }) : _trafficLevel = trafficLevel,
       _riskFactor = riskFactor;

  /// Cost = α * Distance + β * Traffic + γ * Risk
  /// α = 0.5, β = 0.3, γ = 0.2
  double get hybridCost {
    if (isBlocked) return double.infinity;
    
    // Normalize traffic and risk impact to be comparable to distance
    // We assume a 'unit' of traffic/risk is equivalent to ~1km of delay for simplicity
    const alpha = 0.5;
    const beta = 0.3;
    const gamma = 0.2;
    
    return (alpha * weight) + 
           (beta * trafficLevel * 5) + // Scaling factor of 5 to make it impactful
           (gamma * riskFactor * 5);
  }

  /// Effective Weight for routing (strictly distance unless blocked)
  double get effectiveWeight {
    if (isBlocked) return double.infinity;
    return weight;
  }

  @override
  String toString() => 'Edge(${source.name} -> ${destination.name}, cost: ${hybridCost.toStringAsFixed(2)}, blocked: $isBlocked)';
}
