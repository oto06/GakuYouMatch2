import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // GoogleMapControllerを保持するための変数
  GoogleMapController? mapController;

  // 地図の初期位置
  final LatLng _initialPosition = const LatLng(33.5214, 130.4689); // 福岡大学の座標

  // 地図の初期設定
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated, // 地図作成時に呼び出される
        initialCameraPosition: CameraPosition(
          target: _initialPosition, // 初期位置
          zoom: 12.0, // ズームレベル
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'メッセージ'),
          BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: '登録'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'その他'),
        ],
        selectedItemColor: Colors.blue, // 選択されたアイテムの色を青に設定
        unselectedItemColor: Colors.black, // 未選択のアイテムの色を黒に設定
        type: BottomNavigationBarType.fixed, // 固定型に設定
      ),
    );
  }
}

