import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapSearch extends StatefulWidget {
  const MapSearch({Key? key}) : super(key: key);

  @override
  _MapSearchState createState() => _MapSearchState();
}

class _MapSearchState extends State<MapSearch> {
  late GoogleMapController _controller;
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(33.5214, 130.4689),
    zoom: 16,
  );
  String? errorTxt;
  CameraPosition? currentPosition;
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId("1"),
      position: LatLng(33.5214, 130.4689),
      infoWindow: InfoWindow(title: '福岡大学', snippet: '福岡大学はこちらです'),
    ),
  };

  Future<void> getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("現在地の取得はできません");
      }
    }
    final Position position = await Geolocator.getCurrentPosition();
    currentPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 16,
    );
  }

  Future<CameraPosition> searchLatLng(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isEmpty) {
      throw Exception('住所が見つかりませんでした');
    }
    return CameraPosition(
      target: LatLng(locations[0].latitude, locations[0].longitude),
      zoom: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onSubmitted: (value) async {
                setState(() {
                  errorTxt = null;
                });
                if (_controller == null) {
                  print('GoogleMapController is not initialized yet.');
                  return;
                }
                try {
                  CameraPosition result = await searchLatLng(value);
                  _controller.animateCamera(
                    CameraUpdate.newCameraPosition(result),
                  );
                  _markers.add(Marker(
                    markerId: const MarkerId('2'),
                    position: result.target,
                    infoWindow: const InfoWindow(title: '検索結果'),
                  ));
                  setState(() {});
                } catch (e) {
                  print(e);
                  setState(() {
                    errorTxt = '正しい住所を入力してください';
                  });
                }
              },
            ),
            errorTxt == null ? Container() : Text(errorTxt!),
            Expanded(
              child: GoogleMap(
                markers: _markers,
                initialCameraPosition: _initialPosition,
                onMapCreated: (GoogleMapController controller) async {
                  _controller = controller;
                  await getCurrentPosition();
                  if (currentPosition != null) {
                    setState(() {
                      _markers.add(Marker(
                        markerId: const MarkerId('3'),
                        position: currentPosition!.target,
                        infoWindow: const InfoWindow(title: '現在地'),
                      ));
                    });
                    _controller.animateCamera(
                      CameraUpdate.newCameraPosition(currentPosition!),
                    );
                  }
                },
                myLocationEnabled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}








