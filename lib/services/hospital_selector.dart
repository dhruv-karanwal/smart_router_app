import '../models/hospital.dart';
import '../models/incident.dart';
import '../algorithms/priority_queue.dart';
import '../services/routing_engine.dart';
import '../services/graph_model.dart';
import '../utils/geo_utils.dart';

class HospitalSelector {
  final GraphModel graph;
  final RoutingEngine routingEngine;

  HospitalSelector({required this.graph, required this.routingEngine});

  List<HospitalRank> rankHospitals({
    required List<Hospital> hospitals,
    required String emergencyType,
    required double trafficIntensity,
    required List<Incident> incidents,
  }) {
    final heap = MinHeap<HospitalRank>();

    for (var hospital in hospitals) {
      final dist = GeoUtils.haversineDistance(graph.ambulanceLocation.position, hospital.position);
      
      double score = dist * 10; // Base score from distance
      String reason = "Nearest available hospital.";

      // 1. Capability Bonus
      if ((emergencyType == 'Heart Attack' || emergencyType == 'Cardiac Arrest') && hospital.type == HospitalType.cardiac) {
        score -= 50;
        reason = "Specialized Cardiac facility.";
      } else if (emergencyType == 'Stroke' && hospital.type == HospitalType.neuro) {
        score -= 50;
        reason = "Specialized Neuro facility.";
      } else if (emergencyType == 'Burns' && hospital.type == HospitalType.burn) {
        score -= 50;
        reason = "Specialized Burn unit.";
      } else if (emergencyType == 'Poisoning' && hospital.type == HospitalType.icu) {
        score -= 50;
        reason = "Advanced ICU facilities.";
      } else if ((emergencyType == 'Accident' || emergencyType == 'Severe Bleeding') && hospital.type == HospitalType.trauma) {
        score -= 40;
        reason = "Specialized Trauma center.";
      }

      // 2. Traffic Penalty
      score += trafficIntensity * 30;
      if (trafficIntensity > 0.7) {
        reason += " (Accounting for heavy traffic)";
      }

      // 3. Availability Penalty
      if (!hospital.isAvailable) {
        score += 100;
        reason = "Currently busy - prioritizing alternatives.";
      }

      // 4. Incident Penalty
      for (var incident in incidents) {
        final distToIncident = GeoUtils.haversineDistance(hospital.position, incident.location);
        if (distToIncident < 1.0) {
          if (incident.type == IncidentType.roadBlock) {
            score += 100;
            reason = "Road blocks detected near hospital.";
          } else if (incident.type == IncidentType.traffic) {
            score += 30;
            reason += " Localized congestion nearby.";
          }
        }
      }

      heap.insert(
        HospitalRank(
          hospital: hospital, 
          score: score, 
          distance: dist,
          reason: reason,
        ),
        score,
      );
    }

    return heap.toSortedList();
  }
}

class HospitalRank {
  final Hospital hospital;
  final double score;
  final double distance;
  final String reason;

  HospitalRank({
    required this.hospital,
    required this.score,
    required this.distance,
    required this.reason,
  });
}
