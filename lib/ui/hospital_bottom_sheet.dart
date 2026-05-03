import 'package:flutter/material.dart';
import '../models/hospital.dart';
import '../controllers/simulation_controller.dart';
import '../services/hospital_selector.dart';

class HospitalBottomSheet extends StatelessWidget {
  final SimulationController controller;

  const HospitalBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final nearbyHospitals = controller.hospitalRanks.where((r) => r.distance <= 3.0).toList();
    final otherHospitals = controller.hospitalRanks.where((r) => r.distance > 3.0).toList();

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
                  const Text('Auto', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Switch(
                    value: controller.isAutoSelect,
                    onChanged: (val) => controller.toggleAutoSelect(val),
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.showAllHospitals ? 'Showing All' : 'Showing Top 5',
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              TextButton.icon(
                onPressed: () => controller.toggleShowAllHospitals(),
                icon: Icon(controller.showAllHospitals ? Icons.filter_list_off : Icons.filter_list, size: 16),
                label: Text(controller.showAllHospitals ? 'Hide Distant' : 'View All'),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
            ],
          ),

          const SizedBox(height: 8),
          
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (nearbyHospitals.isNotEmpty) ...[
                    _buildSectionHeader('Nearby Hospitals', Icons.near_me),
                    ...nearbyHospitals.asMap().entries.map((entry) {
                      final isTop = entry.key == 0 && controller.hospitalRanks.first.hospital.id == entry.value.hospital.id;
                      return _buildHospitalTile(entry.value, isTop);
                    }),
                  ],
                  if (otherHospitals.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionHeader('Other Hospitals', Icons.map),
                    ...otherHospitals.asMap().entries.map((entry) {
                      final isTop = controller.hospitalRanks.isNotEmpty && controller.hospitalRanks.first.hospital.id == entry.value.hospital.id;
                      return _buildHospitalTile(entry.value, isTop);
                    }),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: const Text('Confirm Selection', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalTile(HospitalRank rank, bool isTop) {
    final hospital = rank.hospital;
    final isSelected = controller.selectedHospital?.id == hospital.id;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => controller.selectHospital(hospital),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: isSelected ? Colors.red : Colors.blue.withOpacity(0.1),
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
          if (isTop)
            Positioned(
              top: -5,
              left: -5,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              hospital.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.red : Colors.black87,
              ),
            ),
          ),
          if (isTop)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: const Text(
                'RECOMMENDED',
                style: TextStyle(color: Colors.purple, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          if (hospital.rating > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 10),
                  const SizedBox(width: 2),
                  Text(
                    hospital.rating.toString(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ],
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hospital.address,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            '${rank.distance.toStringAsFixed(1)} km • ${hospital.specialty} • ${hospital.isAvailable ? "Open" : "Busy"}',
            style: TextStyle(fontSize: 12, color: hospital.isAvailable ? Colors.black54 : Colors.orange.shade700),
          ),
          if (rank.reason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                rank.reason,
                style: const TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
      trailing: isSelected 
          ? const Icon(Icons.check_circle, color: Colors.green)
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ETA: ${(rank.distance * 2.5).toStringAsFixed(0)}m',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
