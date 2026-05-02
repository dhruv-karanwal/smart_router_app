class RouteCostWeights {
  final double distanceWeight;
  final double trafficWeight;
  final double riskWeight;

  const RouteCostWeights({
    this.distanceWeight = 0.5,
    this.trafficWeight = 0.3,
    this.riskWeight = 0.2,
  });
}

class CostFunction {
  static RouteCostWeights currentWeights = const RouteCostWeights();

  static double calculate(double distance, double trafficLevel, double riskFactor) {
    return (currentWeights.distanceWeight * distance) +
           (currentWeights.trafficWeight * trafficLevel * 5) +
           (currentWeights.riskWeight * riskFactor * 5);
  }
}
