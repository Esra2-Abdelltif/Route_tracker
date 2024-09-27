import 'package:flutter/material.dart';
import 'package:route_tracker/views/screen/google_map_view.dart';
void main() {
  runApp(const RouteTrackerApp());
}

class RouteTrackerApp extends StatelessWidget {
  const RouteTrackerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoogleMapView(),
    );
  }
}
