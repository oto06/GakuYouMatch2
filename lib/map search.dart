import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapSearch extends StatefulWidget {
  final Map<String, dynamic>? initialData; // 初期データを受け取る
  const MapSearch({Key? key, this.initialData}) : super(key: key);

  @override
  _MapSearchState createState() => _MapSearchState();
}

class _MapSearchState extends State<MapSearch> {
  late GoogleMapController _controller;
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(33.5214, 130.4689),
    zoom: 16,
  );

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _eventDetailsController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  LatLng _selectedPosition = const LatLng(33.5214, 130.4689); // デフォルト位置
  DateTime? _selectedDate;
  final Set<Marker> _markers = {};
  String? errorTxt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('イベント登録'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 場所検索フィールド
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '場所を検索',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) async {
                    setState(() {
                      errorTxt = null;
                    });
                    if (_controller == null) {
                      print('GoogleMapController is not initialized yet.');
                      return;
                    }
                    try {
                      await _searchLocation(value);
                    } catch (e) {
                      print(e);
                      setState(() {
                        errorTxt = '正しい住所を入力してください';
                      });
                    }
                  },
                ),
              ),
              if (errorTxt != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorTxt!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Googleマップの表示
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: GoogleMap(
                  markers: _markers,
                  initialCameraPosition: _initialPosition,
                  onMapCreated: (GoogleMapController controller) async {
                    _controller = controller;
                    await _setCurrentLocation();
                  },
                  myLocationEnabled: true,
                ),
              ),
              const SizedBox(height: 8),

              // 種目フィールド
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _eventTypeController,
                  decoration: const InputDecoration(
                    labelText: '種目',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 内容フィールド
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _eventDetailsController,
                  decoration: const InputDecoration(
                    labelText: '内容',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 日付フィールド
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _eventDateController,
                  decoration: const InputDecoration(
                    labelText: '予定日',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () => _selectDate(context),
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 16),

              // 登録ボタン
              Center(
                child: ElevatedButton(
                  onPressed: _registerEvent,
                  child: const Text('登録する'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 現在地を取得してマップに反映
  Future<void> _setCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("現在地の取得はできません");
      }
    }
    final Position position = await Geolocator.getCurrentPosition();
    final currentPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      _selectedPosition = currentPosition;
      _markers.add(Marker(
        markerId: const MarkerId('current'),
        position: currentPosition,
        infoWindow: const InfoWindow(title: '現在地'),
      ));
    });

    _controller.animateCamera(CameraUpdate.newLatLngZoom(currentPosition, 16));
  }

  // 入力された場所を検索してマップを移動
  Future<void> _searchLocation(String query) async {
    List<Location> locations = await locationFromAddress(query);
    if (locations.isEmpty) {
      throw Exception('住所が見つかりませんでした');
    }
    final position = LatLng(locations[0].latitude, locations[0].longitude);

    setState(() {
      _selectedPosition = position;
      _markers.add(Marker(
        markerId: const MarkerId('searchResult'),
        position: position,
        infoWindow: const InfoWindow(title: '検索結果'),
      ));
    });

    _controller.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
  }

  // 日付選択
  void _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _eventDateController.text =
        '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
      });
    }
  }

  // イベント登録
  Future<void> _registerEvent() async {
    final eventType = _eventTypeController.text;
    final eventDetails = _eventDetailsController.text;

    if (eventType.isEmpty || eventDetails.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('種目、内容、予定日を入力してください')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Group').add({
        'name': _searchController.text,
        'eventType': eventType,
        'eventDetails': eventDetails,
        'eventDate': _selectedDate,
        'location': {
          'lat': _selectedPosition.latitude,
          'lng': _selectedPosition.longitude,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベントが登録されました')),
      );
    } catch (e) {
      print('登録エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登録に失敗しました')),
      );
    }
  }
}








