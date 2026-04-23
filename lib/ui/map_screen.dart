import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/graph_service.dart';
import '../services/routing_engine.dart';
import '../algorithms/base_algorithm.dart';
import '../models/hospital.dart';
import 'bottom_sheet.dart';
import 'algorithm_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final GraphService _graphService = GraphService();
  final RoutingEngine _routingEngine = RoutingEngine();

  String _selectedEmergency = 'General';
  bool _trafficEnabled = false;
  
  List<AlgorithmResult> _allResults = [];
  AlgorithmResult? _bestResult;
  Hospital? _targetHospital;
  
  final MapController _mapController = MapController();
  bool _isLoading = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initial target based on default selection
    _targetHospital = _graphService.getPriorityHospital(_selectedEmergency);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _calculateRoute() async {
    setState(() {
      _isLoading = true;
      _targetHospital = _graphService.getPriorityHospital(_selectedEmergency);
    });

    // Simulate network/computation delay for loading animation effect
    await Future.delayed(const Duration(milliseconds: 600));

    final results = _routingEngine.runAll(
      _graphService.adjacencyList,
      _graphService.ambulanceLocation,
      _targetHospital!,
    );

    setState(() {
      _allResults = results;
      _bestResult = _routingEngine.selectBest(results);
      _isLoading = false;
    });

    if (_bestResult != null && _bestResult!.path.isNotEmpty) {
      // Fit map to route
      final points = _bestResult!.path.map((n) => n.position).toList();
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }
  }

  void _onEmergencyChanged(String? val) {
    if (val != null) {
      setState(() {
        _selectedEmergency = val;
        _targetHospital = _graphService.getPriorityHospital(val);
        // Clear previous results when emergency type changes
        _allResults = [];
        _bestResult = null;
      });
    }
  }

  void _onTrafficToggled(bool val) {
    setState(() {
      _trafficEnabled = val;
      _graphService.toggleTraffic(val);
      // Clear previous results as traffic changed
      _allResults = [];
      _bestResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Fullscreen Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _graphService.ambulanceLocation.position,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.emergency_route_optimizer',
              ),
              PolylineLayer(
                polylines: [
                  // Alternate routes (Thin grey lines)
                  ..._allResults.where((r) => r != _bestResult).map((res) => Polyline(
                    points: res.path.map((n) => n.position).toList(),
                    color: Colors.grey.withOpacity(0.6),
                    strokeWidth: 3.0,
                  )),
                  // Best route (Thick blue line)
                  if (_bestResult != null)
                    Polyline(
                      points: _bestResult!.path.map((n) => n.position).toList(),
                      color: const Color(0xFF3B82F6),
                      strokeWidth: 6.0,
                      strokeJoin: StrokeJoin.round,
                      strokeCap: StrokeCap.round,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Other hospitals (small, faded)
                  ..._graphService.hospitals.where((h) => h != _targetHospital).map((h) => Marker(
                    point: h.position,
                    width: 30,
                    height: 30,
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: Icon(
                          _getHospitalIcon(h.type),
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  )),
                  
                  // Target Hospital (Highlighted, larger)
                  if (_targetHospital != null)
                    Marker(
                      point: _targetHospital!.position,
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Icon(
                          _getHospitalIcon(_targetHospital!.type),
                          color: const Color(0xFF10B981),
                          size: 40,
                        ),
                      ),
                    ),

                  // Ambulance (Pulsing blue icon)
                  Marker(
                    point: _graphService.ambulanceLocation.position,
                    width: 60,
                    height: 60,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                            ),
                            child: const Center(
                              child: Icon(Icons.emergency, color: Color(0xFF3B82F6), size: 30),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Custom Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 15,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_hospital, color: Color(0xFFEF4444)),
                      SizedBox(width: 10),
                      Text(
                        'Emergency Route Optimizer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Floating Legend
          if (_allResults.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(Colors.blue, 'Best Route'),
                    const SizedBox(height: 4),
                    _buildLegendItem(Colors.grey, 'Alternate'),
                  ],
                ),
              ),
            ),

          // 4. Algorithm Panel (Draggable)
          if (_allResults.isNotEmpty)
            AlgorithmPanel(
              results: _allResults,
              bestResult: _bestResult,
            ),

          // 5. Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF3B82F6)),
                        SizedBox(height: 16),
                        Text('Computing routes...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 6. Bottom Sheet Controls
          CustomBottomSheet(
            selectedEmergency: _selectedEmergency,
            trafficEnabled: _trafficEnabled,
            onEmergencyChanged: _onEmergencyChanged,
            onTrafficToggled: _onTrafficToggled,
            onFindRoute: _calculateRoute,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  IconData _getHospitalIcon(HospitalType type) {
    switch (type) {
      case HospitalType.cardiac:
        return Icons.favorite;
      case HospitalType.trauma:
        return Icons.accessible;
      case HospitalType.general:
      default:
        return Icons.local_hospital;
    }
  }
}
