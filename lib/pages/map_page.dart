import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/components/top_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final int currentIndex = 3;
  final GeoPoint centerPoint = GeoPoint(latitude: 17.59498, longitude: 78.12196);
  final BoundingBox boundingBox = const BoundingBox(
    east: 78.12910,
    west: 78.11713,
    north: 17.60328,
    south: 17.57993,
  );

  late MapController controller;
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    controller = MapController(
      areaLimit: boundingBox,
      useExternalTracking: true,
      initMapWithUserPosition: const UserTrackingOption(
        enableTracking: true,
      ),
    );
  }

  void onItemTapped(int index) {
    if (index != currentIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/chats');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/map');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: Stack(
        children: [
          OSMFlutter(
            osmOption: const OSMOption(
              zoomOption: ZoomOption(
                minZoomLevel: 15,
                maxZoomLevel: 18,
                initZoom: 15,
              ),
              enableRotationByGesture: false,
              showContributorBadgeForOSM: true,
            ),
            controller: controller,
            onMapIsReady: (isReady) {
              if (isReady) {
                setState(() {
                  isMapReady = true;
                });
              }
            },
          ),
          if (!isMapReady)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: BottomBar(currentIndex: currentIndex, onItemTapped: onItemTapped),
    );
  }
}