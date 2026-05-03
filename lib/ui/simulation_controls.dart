import 'package:flutter/material.dart';
import '../services/traffic_manager.dart';
import '../controllers/simulation_controller.dart';
import '../models/incident.dart';

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
          const Text('Hospital Status', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: controller.selectedHospital?.isAvailable ?? false ? Colors.green[100] : Colors.red[100],
                  child: Icon(
                    controller.selectedHospital?.isAvailable ?? false ? Icons.check_circle : Icons.block,
                    color: controller.selectedHospital?.isAvailable ?? false ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedHospital?.name ?? 'No Hospital Selected',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        controller.selectedHospital?.isAvailable ?? false ? 'Currently Open' : 'Currently Busy',
                        style: TextStyle(color: controller.selectedHospital?.isAvailable ?? false ? Colors.green : Colors.red, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.selectedHospital?.isAvailable ?? false,
                  onChanged: (val) => controller.toggleHospitalAvailability(),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('Incident Simulation', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildIncidentButton(
                context, 
                'Heart Attack', 
                IncidentType.heartAttack, 
                Colors.red, 
                Icons.favorite
              ),
              _buildIncidentButton(
                context, 
                'Stroke', 
                IncidentType.stroke, 
                Colors.purple, 
                Icons.psychology
              ),
              _buildIncidentButton(
                context, 
                'Cardiac Arrest', 
                IncidentType.cardiacArrest, 
                Colors.redAccent, 
                Icons.bolt
              ),
              _buildIncidentButton(
                context, 
                'Accident', 
                IncidentType.accident, 
                Colors.orange, 
                Icons.warning
              ),
              _buildIncidentButton(
                context, 
                'Bleeding', 
                IncidentType.severeBleeding, 
                Colors.red.shade900, 
                Icons.bloodtype
              ),
              _buildIncidentButton(
                context, 
                'Burns', 
                IncidentType.burns, 
                Colors.deepOrange, 
                Icons.whatshot
              ),
              _buildIncidentButton(
                context, 
                'Poisoning', 
                IncidentType.poisoning, 
                Colors.green, 
                Icons.science
              ),
              _buildIncidentButton(
                context, 
                'Road Block', 
                IncidentType.roadBlock, 
                Colors.black87, 
                Icons.block
              ),
              _buildIncidentButton(
                context, 
                'High Traffic', 
                IncidentType.traffic, 
                Colors.brown, 
                Icons.traffic
              ),
              _buildIncidentButton(
                context, 
                'General', 
                IncidentType.general, 
                Colors.blueGrey, 
                Icons.emergency
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.clearIncidents(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear All'),
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
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
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

  Widget _buildIncidentButton(BuildContext context, String label, IncidentType type, Color color, IconData icon) {
    return InkWell(
      onTap: () => controller.triggerIncident(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
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
