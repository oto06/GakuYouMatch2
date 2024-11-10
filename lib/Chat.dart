import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gakuyoumatch2/calender.dart';
import 'package:gakuyoumatch2/map%20search.dart';
import 'package:gakuyoumatch2/map_home.dart';
import 'package:gakuyoumatch2/profile.dart';



class ChatScreen extends StatefulWidget {
  @override
  //final String chatId; // チャットのID
  //final String chatTitle; // チャットのタイトル（グループ名や個人名）
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 1; // 1: メッセージタブ

  // メッセージの送信
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': _controller.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }
  // タブが選択されたときの処理
  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
        break;
      case 1:
      // すでにメッセージ画面なので何もしない
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapSearch()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalendarScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chat')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index]['text'];
                    return ListTile(
                      title: Text(message),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
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
        onTap: _onItemTapped, // タップ時の処理を指定
      ),
    );
  }
}
