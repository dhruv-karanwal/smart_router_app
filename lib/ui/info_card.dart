import 'dart:ui';
import 'package:flutter/material.dart';

class RouteInfoCard extends StatelessWidget {
  final String hospitalName;
  final String eta;
  final String distance;
  final String trafficStatus;
  final Color trafficColor;
  final double reliability;

  const RouteInfoCard({
    super.key,
    required this.hospitalName,
    required this.eta,
    required this.distance,
    required this.trafficStatus,
    required this.trafficColor,
    required this.reliability,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hospitalName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(Icons.access_time_filled, eta, 'ETA', Colors.blue),
                  _buildStat(Icons.straighten_rounded, distance, 'Distance', Colors.orange),
                  _buildStat(Icons.traffic_rounded, trafficStatus, 'Traffic', trafficColor),
                ],
              ),
              const SizedBox(height: 20),
              _buildReliabilityIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildReliabilityIndicator() {
    return Row(
      children: [
        const Text(
          'Route Reliability',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: reliability,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                reliability > 0.8 ? Colors.green : (reliability > 0.5 ? Colors.orange : Colors.red),
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(reliability * 100).toInt()}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}
