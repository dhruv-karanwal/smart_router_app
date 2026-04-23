import 'package:flutter/material.dart';
import 'ui/map_screen.dart';

void main() {
  runApp(const EmergencyRouteApp());
}

class EmergencyRouteApp extends StatelessWidget {
  const EmergencyRouteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Route Optimizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}
