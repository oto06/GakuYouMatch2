import 'package:flutter/material.dart';

class Footer extends StatefulWidget {
  final Function(int) onItemTapped;

  const Footer({Key? keyx, required this.onItemTapped}) : super(key: keyx);


  @override
  FooterState createState() => FooterState();
}

class FooterState extends State<Footer> {
  int _selectedIndex = 0; // 現在選択されているアイテムのインデックス

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        unselectedItemColor: Colors.white,  // 未選択のアイテムの色を白に設定
        selectedItemColor: Colors.cyan,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.brown, // 背景色を茶色に設定
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'マップ'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'メッセージ'),
          BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: '登録'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'その他'),
        ],
      currentIndex: _selectedIndex, // 現在選択されているアイテムを指定
      onTap: (index) { // タップされたときの処理
        setState(() {
          _selectedIndex = index;
        });
        widget.onItemTapped(index); // 親ウィジェットに選択されたインデックスを通知
      },
    );
  }
}