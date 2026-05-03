import 'dart:math';
import 'package:latlong2/latlong.dart';

class GeoUtils {
  /// Calculates the distance between two points using the Haversine formula in kilometers.
  static double haversineDistance(LatLng p1, LatLng p2) {
    const double r = 6371; // Earth's radius in kilometers
    final double dLat = _toRadians(p2.latitude - p1.latitude);
    final double dLon = _toRadians(p2.longitude - p1.longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(p1.latitude)) *
            cos(_toRadians(p2.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
