import 'package:flutter/material.dart';
import 'package:gakuyoumatch2/Chat.dart';
import 'package:gakuyoumatch2/map%20search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'calender.dart';
import 'profile.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  // 初期位置を福岡大学の座標に設定
  final LatLng _initialPosition = const LatLng(33.5214, 130.4689);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: Column(
        children: [
          // 必要に応じて他のウィジェットをここに追加できます
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}