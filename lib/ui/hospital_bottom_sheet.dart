import 'package:flutter/material.dart';
import '../models/hospital.dart';
import '../controllers/simulation_controller.dart';

class HospitalBottomSheet extends StatelessWidget {
  final SimulationController controller;

  const HospitalBottomSheet({super.key, required this.controller});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Hospital',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text('Auto-Select', style: TextStyle(color: Colors.grey)),
                  Switch(
                    value: controller.isAutoSelect,
                    onChanged: (val) => controller.toggleAutoSelect(val),
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controller.hospitalRanks.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final rank = controller.hospitalRanks[index];
                final hospital = rank.hospital;
                final isSelected = controller.selectedHospital?.id == hospital.id;

                return ListTile(
                  onTap: () => controller.selectHospital(hospital),
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? Colors.red : Colors.grey[200],
                    child: Icon(
                      hospital.type == HospitalType.cardiac 
                          ? Icons.favorite 
                          : hospital.type == HospitalType.trauma 
                              ? Icons.local_hospital 
                              : Icons.healing,
                      color: isSelected ? Colors.white : Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    hospital.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.red : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '${rank.distance.toStringAsFixed(1)} km • ${hospital.specialty} • ${hospital.isAvailable ? "Open" : "Busy"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isSelected 
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : Text(
                          'Score: ${rank.score.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Confirm Selection'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
