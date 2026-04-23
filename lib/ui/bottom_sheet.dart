import 'dart:ui';
import 'package:flutter/material.dart';

class CustomBottomSheet extends StatefulWidget {
  final String selectedEmergency;
  final bool trafficEnabled;
  final ValueChanged<String?> onEmergencyChanged;
  final ValueChanged<bool> onTrafficToggled;
  final VoidCallback onFindRoute;

  const CustomBottomSheet({
    Key? key,
    required this.selectedEmergency,
    required this.trafficEnabled,
    required this.onEmergencyChanged,
    required this.onTrafficToggled,
    required this.onFindRoute,
  }) : super(key: key);

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _isExpanded ? 0 : -200, // adjust based on height
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle / Toggle Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: widget.selectedEmergency,
                          decoration: InputDecoration(
                            labelText: 'Emergency Type',
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                          ),
                          items: ['General', 'Heart Attack', 'Accident']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: widget.onEmergencyChanged,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF3B82F6)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Icon(
                            widget.trafficEnabled ? Icons.traffic : Icons.traffic_outlined,
                            color: widget.trafficEnabled ? const Color(0xFFEF4444) : Colors.grey,
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 30,
                            child: Switch(
                              value: widget.trafficEnabled,
                              onChanged: widget.onTrafficToggled,
                              activeColor: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: widget.onFindRoute,
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text(
                        'Find Best Route',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        shadowColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ).wrapWithGradient(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to wrap the button in a gradient
extension GradientWrapper on Widget {
  Widget wrapWithGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: this,
    );
  }
}

// A widget to show the collapsed state if needed
class CollapsedBottomSheet extends StatelessWidget {
  final VoidCallback onTap;

  const CollapsedBottomSheet({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
