import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/graph_model.dart';
import '../services/traffic_manager.dart';
import '../services/routing_engine.dart';
import '../services/routing_service.dart';
import '../controllers/simulation_controller.dart';
import '../models/hospital.dart';
import '../models/incident.dart';
import '../utils/geo_utils.dart';
import '../algorithms/base_algorithm.dart';
import '../models/edge.dart';
import 'info_card.dart';
import 'hospital_bottom_sheet.dart';
import 'simulation_controls.dart';

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

  List<LatLng>? _roadPath;
  bool _isNavigating = false;
  LatLng? _currentAmbulancePos;
  
  final MapController _mapController = MapController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  AnimationController? _navigationController;
  Animation<int>? _pathStepAnimation;

  @override
  void initState() {
    super.initState();
    
    _graphModel = GraphModel();
    _currentAmbulancePos = _graphModel.ambulanceLocation.position;
    _trafficManager = TrafficManager(_graphModel);
    _routingEngine = RoutingEngine();
    _simulationController = SimulationController(
      graph: _graphModel,
      trafficManager: _trafficManager,
      routingEngine: _routingEngine,
    );

    _simulationController.addListener(_onSimulationChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateRoute();
    });
  }

  @override
  void dispose() {
    _simulationController.removeListener(_onSimulationChanged);
    _simulationController.dispose();
    _pulseController.dispose();
    _navigationController?.dispose();
    super.dispose();
  }

  void _onSimulationChanged() {
    _calculateRoute();
  }

  void _calculateRoute() async {
    final target = _simulationController.selectedHospital;
    if (target == null) return;
    
    _simulationController.updateRoute(
      _graphModel.ambulanceLocation,
      target,
    );

    final best = _simulationController.bestRoute;
    List<LatLng>? roadPath;

    if (best != null && best.path.isNotEmpty) {
      // Logic vs Visual Separation:
      // Use only start and end for the visual OSRM route to follow real roads
      final points = [best.path.first.position, best.path.last.position];
      roadPath = await _osrmRoutingService.fetchRoute(points);

      if (roadPath != null && _roadPath == null) {
        // Fit camera only on first route load
        final bounds = LatLngBounds.fromPoints(roadPath);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(120)),
        );
      }
    }

    if (mounted) {
      setState(() {
        _roadPath = roadPath;
      });
    }
  }

  void _showHospitalSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ListenableBuilder(
        listenable: _simulationController,
        builder: (context, _) => HospitalBottomSheet(controller: _simulationController),
      ),
    );
  }

  void _startNavigation() {
    if (_roadPath == null || _roadPath!.isEmpty) return;

    _navigationController?.dispose();
    _navigationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: (_roadPath!.length / 5).clamp(5, 30).toInt()),
    );

    _pathStepAnimation = IntTween(begin: 0, end: _roadPath!.length - 1).animate(_navigationController!)
      ..addListener(() {
        if (_pathStepAnimation != null) {
          setState(() {
            _currentAmbulancePos = _roadPath![_pathStepAnimation!.value];
          });
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isNavigating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arrived at Hospital!'), backgroundColor: Colors.green),
          );
        }
      });

    _navigationController!.forward();
    setState(() => _isNavigating = true);
  }

  void _stopNavigation() {
    _navigationController?.stop();
    setState(() {
      _isNavigating = false;
      _currentAmbulancePos = _graphModel.ambulanceLocation.position;
    });
  }

  void _showSimulationControls() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ListenableBuilder(
        listenable: _simulationController,
        builder: (context, _) => SimulationControls(controller: _simulationController),
      ),
    );
  }

  IconData _getEmergencyIcon(String type) {
    switch (type) {
      case 'Heart Attack': return Icons.favorite;
      case 'Cardiac Arrest': return Icons.bolt;
      case 'Stroke': return Icons.psychology;
      case 'Accident': return Icons.warning;
      case 'Severe Bleeding': return Icons.bloodtype;
      case 'Burns': return Icons.whatshot;
      case 'Poisoning': return Icons.science;
      default: return Icons.emergency;
    }
  }

  Color _getTrafficColor(double level) {
    if (level < 0.3) return Colors.green;
    if (level < 0.7) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final bestResult = _simulationController.bestRoute;
    final selectedHospital = _simulationController.selectedHospital;
    final hospitalName = selectedHospital?.name ?? 'Searching...';
    final distanceStr = bestResult != null ? bestResult.totalWeight.toStringAsFixed(1) : '0.0';
    final etaStr = bestResult != null ? (bestResult.totalWeight * 2.5).toStringAsFixed(0) : '0';
    final reliability = bestResult != null ? 0.95 - (_simulationController.trafficIntensity * 0.4) : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _graphModel.ambulanceLocation.position,
              initialZoom: 14.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              
              // Incident Markers
            MarkerLayer(
              markers: _simulationController.incidents.map((incident) => Marker(
                point: incident.location,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      incident.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              )).toList(),
            ),
              // Best Route Layer (Smooth Road-Following)
              if (_roadPath != null) ...[
                // Glow
                PolylineLayer(
                  polylines: [
                    // Outer Glow / Shadow
                    Polyline(
                      points: _roadPath!,
                      color: Colors.blue.withOpacity(0.2),
                      strokeWidth: 12.0,
                      strokeJoin: StrokeJoin.round,
                      strokeCap: StrokeCap.round,
                    ),
                    // Main Route Line
                    Polyline(
                      points: _roadPath!,
                      color: const Color(0xFF2563EB), // Premium Blue
                      strokeWidth: 6.0,
                      strokeJoin: StrokeJoin.round,
                      strokeCap: StrokeCap.round,
                    ),
                  ],
                ),
              ],

              MarkerLayer(
                markers: [

                  // Hospitals
                  ..._graphModel.hospitals.map((h) {
                    final isSelected = selectedHospital?.id == h.id;
                    final distance = GeoUtils.haversineDistance(_graphModel.ambulanceLocation.position, h.position);
                    
                    // Visual styling based on distance
                    double size = 40.0;
                    double opacity = 1.0;
                    
                    if (distance > 6.0) {
                      size = 32.0;
                      opacity = 0.6;
                    } else if (distance > 3.0) {
                      size = 36.0;
                      opacity = 0.85;
                    }

                    if (isSelected) {
                      size = 50.0;
                      opacity = 1.0;
                    }

                    return Marker(
                      point: h.position,
                      width: size + 10,
                      height: size + 10,
                      child: GestureDetector(
                        onTap: () => _simulationController.selectHospital(h, manual: true),
                        child: Opacity(
                          opacity: opacity,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.red : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.red, 
                                width: isSelected ? 3 : 2
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.local_hospital, 
                              color: isSelected ? Colors.white : Colors.red, 
                              size: size * 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Ambulance
                  Marker(
                    point: _currentAmbulancePos ?? _graphModel.ambulanceLocation.position,
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withOpacity(0.2),
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                ],
                              ),
                              child: const Icon(Icons.navigation, color: Colors.white, size: 12),
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

          // Top Navigation Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getEmergencyIcon(_simulationController.emergencyType),
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _simulationController.emergencyType,
                            style: const TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const VerticalDivider(width: 20),
                      const Expanded(
                        child: Text(
                          'Route Optimizer',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: Colors.blue),
                        onPressed: _showSimulationControls,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Info Card & Actions
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RouteInfoCard(
                  hospitalName: hospitalName,
                  eta: '$etaStr min',
                  distance: '$distanceStr km',
                  trafficStatus: _simulationController.trafficIntensity > 0.7 ? 'Heavy' : 'Moderate',
                  trafficColor: _getTrafficColor(_simulationController.trafficIntensity),
                  reliability: reliability,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showHospitalSelection,
                        icon: const Icon(Icons.list),
                        label: const Text('Hospitals'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_isNavigating) {
                            _stopNavigation();
                          } else {
                            _startNavigation();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isNavigating ? Colors.red : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                        ),
                        child: Text(
                          _isNavigating ? 'STOP' : 'NAVIGATE',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Side Controls
          Positioned(
            right: 20,
            top: MediaQuery.of(context).padding.top + 90,
            child: Column(
              children: [
                _buildMapAction(Icons.my_location, () {
                   _mapController.move(_graphModel.ambulanceLocation.position, 15.0);
                }),
                const SizedBox(height: 12),
                _buildMapAction(Icons.explore_outlined, () {
                   _mapController.rotate(0);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapAction(IconData icon, VoidCallback onTap) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onTap,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      child: Icon(icon),
    );
  }
}
