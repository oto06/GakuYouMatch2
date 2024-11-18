import 'package:flutter/material.dart';
import 'package:gakuyoumatch2/ChatSelect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_home.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapSearch extends StatefulWidget {
  const MapSearch({super.key});

  @override
  _MapSearchState createState() => _MapSearchState();
}

class _MapSearchState extends State<MapSearch> {
  late GoogleMapController _mapController;

  TextEditingController _searchController = TextEditingController();
  TextEditingController _eventTypeController = TextEditingController();
  TextEditingController _eventDetailsController = TextEditingController();
  TextEditingController _eventDateController = TextEditingController(); // 追加
  LatLng _initialPosition = LatLng(35.6895, 139.6917); // デフォルト位置（例: 東京）
  DateTime? _selectedDate; // 追加

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('イベント登録')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 場所検索フィールド
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '場所を検索',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                _searchLocation(value);
              },
            ),
            SizedBox(height: 16),

            // Googleマップ表示
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
              ),
            ),
            SizedBox(height: 16),

            // 種目入力フィールド
            TextField(
              controller: _eventTypeController,
              decoration: InputDecoration(
                labelText: '種目',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            SizedBox(height: 8),

            // 内容入力フィールド
            TextField(
              controller: _eventDetailsController,
              decoration: InputDecoration(
                labelText: '内容',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 8),

            // 日付選択フィールド
            TextField(
              controller: _eventDateController,
              decoration: InputDecoration(
                labelText: '予定日',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {
                _selectDate(context); // 日付選択を呼び出し
              },
              readOnly: true, // テキストフィールドを編集不可にする
            ),
            SizedBox(height: 16),

            // 登録ボタン
            ElevatedButton(
              onPressed: _registerEvent,
              child: Text('登録する'),
            ),
          ],
        ),
      ),
    );
  }

  // 日付選択ダイアログを表示
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _eventDateController.text = "${picked.year}-${picked.month}-${picked.day}"; // 日付を表示
      });
    }
  }

  // 位置を検索してマップを移動
  void _searchLocation(String query) async {
    try {
      // 住所から緯度経度を取得
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final position = LatLng(locations[0].latitude, locations[0].longitude);
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(position, 14),
        );
      }
    } catch (e) {
      print("場所が見つかりませんでした: $e");
    }
  }

  // イベントの登録処理
  void _registerEvent() {
    final eventType = _eventTypeController.text;
    final eventDetails = _eventDetailsController.text;
    final eventDate = _selectedDate;

    if (eventType.isEmpty || eventDetails.isEmpty || eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('種目、内容、予定日を入力してください')),
      );
      return;
    }
    try {
      // Firestoreに新しい部屋を作成
      final newGroup = FirebaseFirestore.instance.collection('Group').add({
        'name': _searchController.text, // 場所名
        'eventType': eventType,
        'eventDetails': eventDetails,
        'eventDate': eventDate, // 日付情報を追加
        'location': {
          'lat': _initialPosition.latitude,
          'lng': _initialPosition.longitude
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('イベントが登録されました')),
      );

      // 部屋一覧画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatListScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登録に失敗しました: $e')),
      );
    }
  }
}
