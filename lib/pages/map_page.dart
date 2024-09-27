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
      initPosition: centerPoint,
      areaLimit: boundingBox
    );
  }

  bool _isWithinBounds(GeoPoint point) {
    return point.latitude <= boundingBox.north && point.latitude >= boundingBox.south && point.longitude <= boundingBox.east && point.longitude >= boundingBox.west;
  }

  Future<void> _checkPosition(GeoPoint position) async {
    if (!_isWithinBounds(position)) {
      double latitude = position.latitude.clamp(boundingBox.south, boundingBox.north);
      double longitude = position.longitude.clamp(boundingBox.west, boundingBox.east);
      
      await controller.moveTo(GeoPoint(latitude: latitude, longitude: longitude));
    }
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
                minZoomLevel: 16,
                maxZoomLevel: 18,
                initZoom: 16,
              ),
              showZoomController: true,
              enableRotationByGesture: false,
            ),
            controller: MapController(
              initPosition: centerPoint,
              areaLimit: boundingBox,
            ),
            onMapIsReady: (isReady) {
              if (isReady) {
                setState(() {
                  isMapReady = true;
                });
              }
            },
            onLocationChanged: (GeoPoint newLocation) async {
              await _checkPosition(newLocation);
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
