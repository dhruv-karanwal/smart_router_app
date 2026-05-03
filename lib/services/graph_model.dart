import 'package:latlong2/latlong.dart';
import '../models/node.dart';
import '../models/edge.dart';
import '../models/hospital.dart';
import '../utils/geo_utils.dart';

class GraphModel {
  final Map<Node, List<Edge>> adjacencyList = {};
  final List<Node> nodes = [];
  final List<Hospital> hospitals = [];
  late Node ambulanceLocation;

  GraphModel() {
    _initializeData();
  }

  void _initializeData() {
    // Current Location: VIT Pune, Bibewadi
    ambulanceLocation = Node(
      id: 'vit_pune',
      name: 'VIT Pune, Bibewadi',
      position: LatLng(18.4635, 73.8682),
    );

    // Nearby Hospitals (0-2 km)
    final h1 = Hospital(
      id: 'hosp_1',
      name: 'Premchand Oswal Hospital',
      position: LatLng(18.4700, 73.8700),
      type: HospitalType.cardiac,
      address: 'Bibwewadi, Pune',
      rating: 4.8,
    );
    final h2 = Hospital(
      id: 'hosp_2',
      name: 'Sukhsagar Hospital',
      position: LatLng(18.4620, 73.8690),
      type: HospitalType.general,
      address: 'Sukhsagar Nagar, Pune',
      rating: 4.2,
    );
    final h3 = Hospital(
      id: 'hosp_3',
      name: 'Chintamani Hospital',
      position: LatLng(18.4580, 73.8650),
      type: HospitalType.trauma,
      address: 'Kondhwa Road, Pune',
      rating: 4.5,
    );
    final h4 = Hospital(
      id: 'hosp_4',
      name: 'Mahesh Hospital',
      position: LatLng(18.4550, 73.8800),
      type: HospitalType.general,
      address: 'Upper Indiranagar, Pune',
      rating: 4.0,
    );

    // Mid-range Hospitals (2-5 km)
    final h5 = Hospital(
      id: 'hosp_5',
      name: 'City Care Hospital',
      position: LatLng(18.4600, 73.8600),
      type: HospitalType.trauma,
      address: 'Dhankawadi, Pune',
      rating: 4.3,
    );
    final h6 = Hospital(
      id: 'hosp_6',
      name: 'Sahyadri Hospital',
      position: LatLng(18.4750, 73.8600),
      type: HospitalType.cardiac,
      address: 'Bibwewadi-Kondhwa Rd',
      rating: 4.7,
      isAvailable: false,
    );
    final h7 = Hospital(
      id: 'hosp_7',
      name: 'Rao Nursing Home',
      position: LatLng(18.4800, 73.8750),
      type: HospitalType.general,
      address: 'Gultekdi, Pune',
      rating: 4.1,
    );
    final h13 = Hospital(
      id: 'hosp_13',
      name: 'Lifeline Hospital',
      position: LatLng(18.4850, 73.8550),
      type: HospitalType.trauma,
      address: 'Satara Road, Pune',
      rating: 4.4,
    );

    // Distant Hospitals (5-10 km)
    final h8 = Hospital(
      id: 'hosp_8',
      name: 'Ruby Hall Clinic',
      position: LatLng(18.4900, 73.9000),
      type: HospitalType.cardiac,
      address: 'Wanowrie, Pune',
      rating: 4.9,
    );
    final h9 = Hospital(
      id: 'hosp_9',
      name: 'Noble Hospital',
      position: LatLng(18.5100, 73.9100),
      type: HospitalType.trauma,
      address: 'Hadapsar, Pune',
      rating: 4.6,
    );
    final h10 = Hospital(
      id: 'hosp_10',
      name: 'Poona Hospital',
      position: LatLng(18.5100, 73.8450),
      type: HospitalType.neuro,
      address: 'Deccan Gymkhana, Pune',
      rating: 4.4,
    );
    final h11 = Hospital(
      id: 'hosp_11',
      name: 'Deenanath Mangeshkar',
      position: LatLng(18.5050, 73.8250),
      type: HospitalType.icu,
      address: 'Erandwane, Pune',
      rating: 4.8,
    );
    final h12 = Hospital(
      id: 'hosp_12',
      name: 'Jehangir Hospital',
      position: LatLng(18.5300, 73.8750),
      type: HospitalType.trauma,
      address: 'Bund Garden Road, Pune',
      rating: 4.7,
    );
    final h14 = Hospital(
      id: 'hosp_14',
      name: 'Apollo Spectra',
      position: LatLng(18.5350, 73.8300),
      type: HospitalType.burn,
      address: 'Shivajinagar, Pune',
      rating: 4.5,
    );
    final h15 = Hospital(
      id: 'hosp_15',
      name: 'Jupiter Hospital',
      position: LatLng(18.5600, 73.7900),
      type: HospitalType.trauma,
      address: 'Baner, Pune',
      rating: 4.9,
    );

    hospitals.addAll([h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11, h12, h13, h14, h15]);

    final i1 = Node(id: 'i1', name: 'Intersection 1', position: LatLng(18.4650, 73.8650));
    final i2 = Node(id: 'i2', name: 'Intersection 2', position: LatLng(18.4680, 73.8680));
    final i3 = Node(id: 'i3', name: 'Intersection 3', position: LatLng(18.4580, 73.8700));
    final i4 = Node(id: 'i4', name: 'Intersection 4', position: LatLng(18.4600, 73.8750));
    final i5 = Node(id: 'i5', name: 'Intersection 5', position: LatLng(18.4750, 73.8700));
    final i6 = Node(id: 'i6', name: 'Intersection 6', position: LatLng(18.4850, 73.8800));
    final i7 = Node(id: 'i7', name: 'Intersection 7', position: LatLng(18.4950, 73.8600));
    final i8 = Node(id: 'i8', name: 'Intersection 8', position: LatLng(18.5050, 73.8850));
    final i9 = Node(id: 'i9', name: 'Intersection 9', position: LatLng(18.5200, 73.8600));
    final i10 = Node(id: 'i10', name: 'Intersection 10', position: LatLng(18.5000, 73.8400));

    nodes.addAll([ambulanceLocation, ...hospitals, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10]);

    // Intersection Mesh (The "Roads")
    _addEdge(ambulanceLocation, i1);
    _addEdge(ambulanceLocation, i3);
    _addEdge(i1, i2);
    _addEdge(i1, i10);
    _addEdge(i2, i5);
    _addEdge(i3, i4);
    _addEdge(i4, i2);
    _addEdge(i5, i6);
    _addEdge(i5, i7);
    _addEdge(i6, i8);
    _addEdge(i7, i10);
    _addEdge(i7, i9);
    _addEdge(i8, i9);
    _addEdge(i8, h12); // Connect to Jehangir area
    _addEdge(i9, h14); // Connect to Apollo area
    _addEdge(i10, h11); // Connect to Deenanath area

    // Hospital Connections (Connect each hospital to at least one intersection)
    _addEdge(h1, i2);  // Oswal
    _addEdge(h2, i2);  // Sukhsagar
    _addEdge(h3, i1);  // Chintamani
    _addEdge(h4, i4);  // Mahesh
    _addEdge(h5, i3);  // City Care
    _addEdge(h6, i5);  // Sahyadri
    _addEdge(h7, i5);  // Rao
    _addEdge(h13, i7); // Lifeline
    
    _addEdge(h8, i6);  // Ruby Hall
    _addEdge(h9, i8);  // Noble
    _addEdge(h10, i10); // Poona
    _addEdge(h11, i10); // Deenanath
    _addEdge(h12, i9);  // Jehangir
    _addEdge(h14, i9);  // Apollo
    _addEdge(h15, i8);  // Jupiter (distant but connected)
  }

  void _addEdge(Node u, Node v, [double? weight]) {
    final dist = weight ?? GeoUtils.haversineDistance(u.position, v.position);
    adjacencyList.putIfAbsent(u, () => []).add(Edge(source: u, destination: v, weight: dist));
    adjacencyList.putIfAbsent(v, () => []).add(Edge(source: v, destination: u, weight: dist));
  }

  void resetGraph() {
    for (var edges in adjacencyList.values) {
      for (var edge in edges) {
        edge.trafficLevel = 0.0;
        edge.riskFactor = 0.0;
        edge.isBlocked = false;
      }
    }
  }

  Hospital getPriorityHospital(String emergencyType) {
    if (emergencyType == 'Heart Attack') {
      return hospitals.firstWhere((h) => h.type == HospitalType.cardiac && h.isAvailable, 
          orElse: () => hospitals.firstWhere((h) => h.type == HospitalType.cardiac));
    } else if (emergencyType == 'Accident') {
      return hospitals.firstWhere((h) => h.type == HospitalType.trauma && h.isAvailable,
          orElse: () => hospitals.firstWhere((h) => h.type == HospitalType.trauma));
    } else {
      Hospital nearest = hospitals[0];
      double minDist = double.infinity;
      for (var h in hospitals) {
        double d = GeoUtils.haversineDistance(ambulanceLocation.position, h.position);
        if (d < minDist && h.isAvailable) {
          minDist = d;
          nearest = h;
        }
      }
      return nearest;
    }
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    return GeoUtils.haversineDistance(p1, p2);
  }
}
