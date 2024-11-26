import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gakuyoumatch2/Chat.dart';
import 'package:gakuyoumatch2/ChatSelect.dart';
import 'package:gakuyoumatch2/ProfileProvider.dart';
import 'package:gakuyoumatch2/calender.dart';
import 'package:gakuyoumatch2/else.dart';
import 'package:gakuyoumatch2/footer.dart';
import 'package:gakuyoumatch2/header.dart';
import 'package:gakuyoumatch2/map%20search.dart';
import 'package:gakuyoumatch2/map_home.dart';
import 'firebase_options.dart';
import 'calender.dart';
import 'package:gakuyoumatch2/else.dart';
import 'package:gakuyoumatch2/profile.dart';
import 'profile.dart';
import 'package:gakuyoumatch2/ProfileProvider.dart';
import 'package:provider/provider.dart';
import 'package:gakuyoumatch2/ProfileProvider.dart';
import 'package:gakuyoumatch2/main.dart';
import 'dart:io';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? keyx}) : super(key: keyx);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int _selectedIndex = 0; // 現在選択されているページのインデックス
  void _onItemTapped(int index) {
    // タップされたときに呼び出される関数
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    final pageOptions = [ // ページのウィジェットをリストで管理
      const MapScreen(),
      ChatListScreen(),
      MapSearch(),
      CalendarScreen(),
      ElsePage(),
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chateraise Sample',

      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          cardColor: Colors.white,
          scaffoldBackgroundColor: Colors.brown[200]
      ),
      home: Scaffold(
        //appBar: const Header(),
        body:pageOptions[_selectedIndex],
        bottomNavigationBar: Footer(onItemTapped: _onItemTapped), // コールバック関数を渡す
      ),
    );
  }
}


// ProfileProviderの定義例
