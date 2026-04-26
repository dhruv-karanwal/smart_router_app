import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/graph_model.dart';
import '../services/traffic_manager.dart';
import '../services/routing_engine.dart';
import '../services/routing_service.dart';
import '../controllers/simulation_controller.dart';
import '../algorithms/base_algorithm.dart';
import '../models/hospital.dart';
import 'bottom_sheet.dart';
import 'hospital_selection_card.dart';
import 'eta_distance_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final GraphModel _graphModel;
  late final TrafficManager _trafficManager;
  late final RoutingEngine _routingEngine;
  late final SimulationController _simulationController;
  final RoutingService _osrmRoutingService = RoutingService();

  String _selectedEmergency = 'General Emergency';
  Hospital? _targetHospital;
  List<LatLng>? _roadPath;
  
  final MapController _mapController = MapController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize services
    _graphModel = GraphModel();
    _trafficManager = TrafficManager(_graphModel);
    _routingEngine = RoutingEngine();
    _simulationController = SimulationController(
      graph: _graphModel,
      trafficManager: _trafficManager,
      routingEngine: _routingEngine,
    );

    // Listen for simulation changes
    _simulationController.addListener(_onSimulationChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _targetHospital = _graphModel.hospitals.firstWhere((h) => h.name == 'Premchand Oswal Hospital', orElse: () => _graphModel.hospitals.first);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateRoute();
    });
  }

  @override
  void dispose() {
    _simulationController.removeListener(_onSimulationChanged);
    _simulationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onSimulationChanged() {
    _calculateRoute();
  }

  void _calculateRoute() async {
    if (_targetHospital == null) return;
    
    _simulationController.updateRoute(
      _graphModel.ambulanceLocation,
      _targetHospital!,
    );

    final best = _simulationController.bestRoute;
    List<LatLng>? roadPath;

    if (best != null && best.path.isNotEmpty) {
      final points = best.path.map((n) => n.position).toList();
      final routeWaypoints = [points.first, points.last];
      
      roadPath = await _osrmRoutingService.fetchRoute(routeWaypoints);

      // Smooth camera transition
      if (roadPath != null || points.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(roadPath ?? points);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
        );
      }
    }

    if (mounted) {
      setState(() {
        _roadPath = roadPath;
      });
    }
  }

  void _onHospitalSelected(Hospital hospital) {
    setState(() {
      _targetHospital = hospital;
    });
    _calculateRoute();
  }

  void _onEmergencyChanged(String? val) {
    if (val != null) {
      setState(() {
        _selectedEmergency = val;
        _targetHospital = _graphModel.getPriorityHospital(val);
      });
      _calculateRoute();
    }
  }

  void _onTrafficToggled(bool val) {
    _simulationController.toggleTrafficSimulation(val);
  }

  void _onBlockRandomRoad() {
    _simulationController.blockRandomRoad();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Road blocked! Rerouting...'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onResetMap() {
    _simulationController.resetMap();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map reset to default state.'),
        backgroundColor: Colors.blueGrey,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bestResult = _simulationController.bestRoute;
    
    // Generate ETA/Distance based on the selected hospital or best result
    final distanceStr = bestResult != null ? bestResult.totalWeight.toStringAsFixed(1) : '0.0';
    final etaStr = bestResult != null ? (bestResult.totalWeight * 3.5).toStringAsFixed(0) : '0';
    
    final trafficEnabled = _simulationController.isTrafficSimulationEnabled;
    final trafficStatus = trafficEnabled ? 'Heavy Traffic' : 'Light Traffic';
    final trafficColor = trafficEnabled ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Fullscreen Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _graphModel.ambulanceLocation.position,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.emergency_route_optimizer',
              ),
              // Blocked Roads Layer
              PolylineLayer(
                polylines: _graphModel.adjacencyList.values
                    .expand((e) => e)
                    .where((e) => e.isBlocked)
                    .map((e) => Polyline(
                          points: [e.source.position, e.destination.position],
                          color: Colors.orange.withOpacity(0.8),
                          strokeWidth: 8.0,
                          pattern: StrokePattern.dashed(segments: [10, 5]),
                        ))
                    .toList(),
              ),
              PolylineLayer(
                polylines: [
                  // Soft Glow Effect (Highly transparent, thick blue)
                  if (_roadPath != null)
                    Polyline(
                      points: _roadPath!,
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      strokeWidth: 16.0,
                      strokeJoin: StrokeJoin.round,
                      strokeCap: StrokeCap.round,
                    )
                  else if (bestResult != null)
                    Polyline(
                      points: bestResult.path.map((n) => n.position).toList(),
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      strokeWidth: 16.0,
                      strokeJoin: StrokeJoin.round,
                      strokeCap: StrokeCap.round,
                    ),
                  // Best route Outline (Thick White)
                  if (_roadPath != null)
                    Polyline(
                      points: _roadPath!,
                      color: Colors.white,
                      strokeWidth: 10.0,
                      strokeJoin: StrokeJoin.round,
                      strokeCap: StrokeCap.round,
                    )
                  else if (bestResult != null)
                    Polyline(
                      points: bestResult.path.map((n) => n.position).toList(),
                      color: Colors.white,
                      strokeWidth: 10.0,
                      strokeJoin: StrokeJoin.round,
                      strokeCap: StrokeCap.round,
                    ),
                  // Best route Core (Thin Blue)
                  if (_roadPath != null)
                    Polyline(
                      points: _roadPath!,
                      color: const Color(0xFF3B82F6),
                      strokeWidth: 6.0,
                      strokeJoin: StrokeJoin.round,
                      strokeCap: StrokeCap.round,
                    )
                  else if (bestResult != null)
                    Polyline(
                      points: bestResult.path.map((n) => n.position).toList(),
                      color: const Color(0xFF3B82F6),
                      strokeWidth: 6.0,
                      strokeJoin: StrokeJoin.round,
                      strokeCap: StrokeCap.round,
                    ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Other hospitals (small red pins)
                  ..._graphModel.hospitals.where((h) => h != _targetHospital).map((h) => Marker(
                    point: h.position,
                    width: 30,
                    height: 30,
                    child: Opacity(
                      opacity: 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  )),
                  
                  // Route path nodes (white circles at bends)
                  if (bestResult != null)
                    ...bestResult.path.skip(1).take(bestResult.path.length - 2).map((n) => Marker(
                      point: n.position,
                      width: 12,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF3B82F6), width: 2),
                        ),
                      ),
                    )),

                  // Target Hospital (Large red pin with text)
                  if (_targetHospital != null)
                    Marker(
                      point: _targetHospital!.position,
                      width: 100,
                      height: 80,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                              ],
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
                              ],
                            ),
                            child: Text(
                              _targetHospital!.name.split(' ').take(2).join('\n'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Ambulance (Blue dot with white ring and pulsing halo)
                  Marker(
                    point: _graphModel.ambulanceLocation.position,
                    width: 60,
                    height: 60,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                                ),
                              ),
                            ),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3B82F6),
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                ],
                              ),
                            ),
                          ],
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
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 15,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Emergency Route Optimizer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Right Action Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 16,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _mapController.move(_graphModel.ambulanceLocation.position, 14.0);
                  },
                  child: _buildFloatingActionButton(Icons.my_location),
                ),
                const SizedBox(height: 12),
                
                // Emergency Type Selector
                PopupMenuButton<String>(
                  onSelected: _onEmergencyChanged,
                  initialValue: _selectedEmergency,
                  offset: const Offset(-160, 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  itemBuilder: (context) => ['General Emergency', 'Heart Attack', 'Accident']
                      .map((e) => PopupMenuItem(value: e, child: Text(e)))
                      .toList(),
                  child: _buildFloatingActionButton(
                    Icons.medical_services_outlined,
                    color: _selectedEmergency != 'General Emergency' ? const Color(0xFFEF4444) : Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Traffic Toggle
                GestureDetector(
                  onTap: () => _onTrafficToggled(!_simulationController.isTrafficSimulationEnabled),
                  child: _buildFloatingActionButton(
                    Icons.traffic_outlined,
                    color: _simulationController.isTrafficSimulationEnabled ? const Color(0xFFEF4444) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // 4. Hospital Selection Card
          HospitalSelectionCard(
            hospitals: _graphModel.hospitals,
            selectedHospital: _targetHospital,
            onHospitalSelected: _onHospitalSelected,
          ),

          // 5. ETA & Distance Card
          EtaDistanceCard(
            eta: '$etaStr min',
            distance: '$distanceStr km',
            trafficStatus: trafficStatus,
            trafficColor: trafficColor,
          ),

          // 6. Bottom Sheet Controls
          CustomBottomSheet(
            selectedEmergency: _selectedEmergency,
            trafficEnabled: _simulationController.isTrafficSimulationEnabled,
            onEmergencyChanged: _onEmergencyChanged,
            onTrafficToggled: _onTrafficToggled,
            onBlockRandomRoad: _onBlockRandomRoad,
            onResetMap: _onResetMap,
            onStartNavigation: _calculateRoute,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(IconData? icon, {String? text, Color color = Colors.black87}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: icon != null 
            ? Icon(icon, color: color)
            : Text(text ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
