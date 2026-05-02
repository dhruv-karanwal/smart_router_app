import 'package:flutter/material.dart';
import '../services/traffic_manager.dart';
import '../controllers/simulation_controller.dart';

class SimulationControls extends StatelessWidget {
  final SimulationController controller;

  const SimulationControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Simulation Controls',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Traffic Slider
          Row(
            children: [
              const Icon(Icons.traffic, color: Colors.orange),
              const SizedBox(width: 12),
              const Text('Traffic Intensity', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${(controller.trafficIntensity * 100).toInt()}%'),
            ],
          ),
          Slider(
            value: controller.trafficIntensity,
            onChanged: (val) => controller.setTrafficIntensity(val),
            activeColor: Colors.orange,
          ),
          
          const SizedBox(height: 16),
          const Text('Scenario Modes', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildScenarioChip(
                  context, 
                  'Normal', 
                  TrafficScenario.normal, 
                  Icons.check_circle_outline
                ),
                const SizedBox(width: 8),
                _buildScenarioChip(
                  context, 
                  'Heavy Traffic', 
                  TrafficScenario.heavy, 
                  Icons.bolt
                ),
                const SizedBox(width: 8),
                _buildScenarioChip(
                  context, 
                  'Emergency', 
                  TrafficScenario.emergency, 
                  Icons.warning_amber_rounded
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.resetMap(),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset System'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('View Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildScenarioChip(BuildContext context, String label, TrafficScenario scenario, IconData icon) {
    final isSelected = controller.currentScenario == scenario;
    return ChoiceChip(
      label: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black54),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) controller.setScenario(scenario);
      },
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
