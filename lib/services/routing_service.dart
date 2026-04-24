import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const String _osrmBaseUrl = 'http://router.project-osrm.org/route/v1/driving';

  /// Fetches a realistic road-following route from OSRM using a list of waypoints.
  /// Returns a list of coordinates representing the smooth curved polyline.
  Future<List<LatLng>?> fetchRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return waypoints;

    try {
      // OSRM expects coordinates in lon,lat format separated by semicolons
      final String coordinatesString = waypoints
          .map((wp) => '${wp.longitude},${wp.latitude}')
          .join(';');

      final Uri url = Uri.parse(
          '$_osrmBaseUrl/$coordinatesString?overview=full&geometries=geojson');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          
          if (geometry['type'] == 'LineString') {
            final List<dynamic> coordinates = geometry['coordinates'];
            
            // OSRM GeoJSON returns [longitude, latitude]
            return coordinates.map((coord) {
              return LatLng(coord[1].toDouble(), coord[0].toDouble());
            }).toList();
          }
        }
      } else {
        print('OSRM Routing Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception fetching route: $e');
    }

    // Fallback to straight lines if API fails
    return null;
  }
}
