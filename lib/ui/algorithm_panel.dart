import 'dart:ui';
import 'package:flutter/material.dart';
import '../algorithms/base_algorithm.dart';

class AlgorithmPanel extends StatefulWidget {
  final List<AlgorithmResult> results;
  final AlgorithmResult? bestResult;

  const AlgorithmPanel({
    Key? key,
    required this.results,
    this.bestResult,
  }) : super(key: key);

  @override
  State<AlgorithmPanel> createState() => _AlgorithmPanelState();
}

class _AlgorithmPanelState extends State<AlgorithmPanel> {
  Offset _position = const Offset(16, 100);

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics, size: 16, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 8),
                      const Text(
                        'Algorithm Performance',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.drag_indicator, size: 16, color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...widget.results.map((r) {
                    final isBest = r == widget.bestResult;
                    return _buildAlgorithmRow(
                      name: r.algorithmName,
                      weight: r.totalWeight,
                      nodes: r.nodesVisited,
                      isBest: isBest,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlgorithmRow({
    required String name,
    required double weight,
    required int nodes,
    required bool isBest,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isBest ? const Color(0xFFE0F2FE) : Colors.transparent, // Light blue for best
        borderRadius: BorderRadius.circular(8),
        border: isBest ? Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isBest ? FontWeight.bold : FontWeight.w500,
                        color: isBest ? const Color(0xFF1E3A8A) : Colors.black87,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Green badge
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BEST',
                          style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Dist: ${weight.toStringAsFixed(1)} • Nodes: $nodes',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isBest)
            const Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
        ],
      ),
    );
  }
}
