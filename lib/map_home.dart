import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gakuyoumatch2/ChatSelect.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gakuyoumatch2/ChatSelect.dart'; // チャットリスト画面に遷移

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final LatLng _initialPosition = const LatLng(33.5214, 130.4689); // 初期位置
  final Set<Marker> _markers = {}; // マーカーを保持するセット
  Map<String, dynamic>? _selectedLocation; // 選択されたピンのデータ

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
              title: data['name']?? '未設定',
              snippet: data['eventType'],
              onTap: () {
                setState(() {
                  _selectedLocation = {...data, 'id': doc.id};
                });
              },
            ),
          );
          _markers.add(marker);
        }
      });
    });
  }

  // 登録ボタンの動作
  Future<void> _joinChatRoom() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログインが必要です')),
      );
      return;
    }

    try {
      final chatRoomQuery = await FirebaseFirestore.instance
          .collection('ChatRooms')
          .where('locationId', isEqualTo: _selectedLocation!['id'])
          .limit(1)
          .get();

      if (chatRoomQuery.docs.isNotEmpty) {
        // 既存のチャットルームに参加
        final chatRoomId = chatRoomQuery.docs.first.id;
        await FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).update({
          'participants': FieldValue.arrayUnion([currentUser.uid]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('チャットルームに参加しました')),
        );

        // チャットリスト画面に遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatListScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('チャットルームが見つかりません')),
        );
      }
    } catch (e) {
      print('エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('参加に失敗しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12.0,
              ),
              markers: _markers, // Firestoreから取得したピンを表示
            ),
          ),
          if (_selectedLocation != null) // 詳細情報と参加ボタンを表示
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('場所: ${_selectedLocation!['name']}'),
                  Text('イベント種目: ${_selectedLocation!['eventType']}'),
                  ElevatedButton(
                    onPressed: _joinChatRoom,
                    child: const Text('参加する'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

