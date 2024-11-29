import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gakuyoumatch2/map search.dart'; // 登録画面へのナビゲーション用

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LatLng _initialPosition = const LatLng(33.5214, 130.4689); // 初期位置
  final Set<Marker> _markers = {}; // マーカーを保持するセット

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Firestoreからデータを取得してピンを表示
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  // Firestoreから登録した場所のデータを取得
  Future<void> _fetchLocations() async {
    FirebaseFirestore.instance.collection('Group').snapshots().listen((snapshot) {
      setState(() {
        _markers.clear();
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final position = LatLng(data['location']['lat'], data['location']['lng']);
          final marker = Marker(
            markerId: MarkerId(doc.id),
            position: position,
            infoWindow: InfoWindow(
              title: data['name'], // 場所名
              snippet: data['eventType'], // イベント種目
              onTap: () {
                _navigateToDetails(data); // 詳細画面にナビゲート
              },
            ),
          );
          _markers.add(marker);
        }
      });
    });
  }

  // 詳細画面に遷移
  void _navigateToDetails(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSearch(initialData: data), // `MapSearch`で表示用に初期データを渡す
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 12.0,
        ),
        markers: _markers, // Firestoreから取得したピンを表示
      ),
    );
  }
}
