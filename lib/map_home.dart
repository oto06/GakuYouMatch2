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

  // // Firestoreから登録した場所のデータを取得
  // Future<void> _fetchLocations() async {
  //   FirebaseFirestore.instance.collection('Group').snapshots().listen(
  //         (snapshot) {
  //       setState(() {
  //         _markers.clear();
  //         for (var doc in snapshot.docs) {
  //           try {
  //             final data = doc.data();
  //             if (data.containsKey('location') &&
  //                 data['location'] is Map &&
  //                 data['location']['lat'] != null &&
  //                 data['location']['lng'] != null) {
  //               final position = LatLng(data['location']['lat'], data['location']['lng']);
  //               final marker = Marker(
  //                 markerId: MarkerId(doc.id),
  //                 position: position,
  //                 infoWindow: InfoWindow(
  //                   title: data['name'] ?? '未設定',
  //                   snippet: data['eventType'],
  //                   onTap: () {
  //                     setState(() {
  //                       _selectedLocation = {...data, 'id': doc.id};
  //                     });
  //                   },
  //                 ),
  //               );
  //               _markers.add(marker);
  //             } else {
  //               print("Invalid location data: $data");
  //             }
  //           } catch (e) {
  //             print("Error processing document ${doc.id}: $e");
  //           }
  //         }
  //       });
  //     },
  //     onError: (error) {
  //       print("Error fetching locations: $error");
  //     },
  //   );
  // }
  Future<void> _fetchLocations() async {
    FirebaseFirestore.instance.collection('Group').snapshots().listen(
          (snapshot) {
        setState(() {
          _markers.clear();
          for (var doc in snapshot.docs) {
            try {
              final data = doc.data();
              if (data.containsKey('location') &&
                  data['location'] is Map &&
                  data['location']['lat'] != null &&
                  data['location']['lng'] != null) {
                final position = LatLng(data['location']['lat'], data['location']['lng']);
                final isCurrentUserLocation = data['isCurrentUserLocation'] ?? false;
                final isCurrentLocation = data['isCurrentLocation'] ?? false; // 参加中の場所を判定

                // ピンの色を決定
                BitmapDescriptor markerIcon;
                if (isCurrentUserLocation) {
                  // 自分が登録した場所（黄色）
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
                } else if (isCurrentLocation) {
                  // 現在参加している場所（青色）
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
                } else {
                  // デフォルトのピン（赤）
                  markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
                }

                final marker = Marker(
                  markerId: MarkerId(doc.id),
                  position: position,
                  icon: markerIcon,  // アイコン（ピンの色）を設定
                  infoWindow: InfoWindow(
                    title: data['name'] ?? '未設定',
                    snippet: data['eventType'],
                    onTap: () {
                      setState(() {
                        _selectedLocation = {...data, 'id': doc.id};
                      });
                    },
                  ),
                );
                _markers.add(marker);
              } else {
                print("Invalid location data: $data");
              }
            } catch (e) {
              print("Error processing document ${doc.id}: $e");
            }
          }
        });
      },
      onError: (error) {
        print("Error fetching locations: $error");
      },
    );
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
      final locationId = _selectedLocation!['id'];

      // locationId で既存のチャットルームを検索
      final chatRoomQuery = await FirebaseFirestore.instance
          .collection('ChatRooms')
          .where('locationId', isEqualTo: locationId)
          .limit(1)
          .get();

      if (chatRoomQuery.docs.isNotEmpty) {
        // 既存のチャットルームを取得
        final chatRoom = chatRoomQuery.docs.first;
        final chatRoomId = chatRoom.id;

        // Firestoreに参加者を追加
        await FirebaseFirestore.instance.collection('ChatRooms').doc(chatRoomId).update({
          'participants': FieldValue.arrayUnion([currentUser.uid]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('既存のチャットルームに参加しました')),
        );
      } else {
        // チャットルームが存在しない場合、新規作成
        final groupData = await FirebaseFirestore.instance
            .collection('Group')
            .doc(locationId)
            .get();

        if (groupData.exists) {
          final newChatRoom = {
            'locationId': locationId,
            'name': groupData['name'] ?? '未設定',
            'eventType': groupData['eventType'],
            'eventDetails': groupData['eventDetails'],
            'participants': [currentUser.uid],
            'createdAt': FieldValue.serverTimestamp(),
          };

          await FirebaseFirestore.instance.collection('ChatRooms').add(newChatRoom);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('新しいチャットルームを作成しました')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('選択されたグループデータが見つかりません')),
          );
        }
      }

      // チャットリスト画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatListScreen(),
        ),
      );
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
      backgroundColor: Colors.brown[200],
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
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
          ),
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '場所: ${_selectedLocation!['name']}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'イベント種目: ${_selectedLocation!['eventType']}',
                        style: TextStyle(fontSize: 16, color: Colors.brown[600]),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _joinChatRoom,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('参加する', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

