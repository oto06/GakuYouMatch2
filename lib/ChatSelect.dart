import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Chat.dart'; // メッセージ画面をインポート

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャットリスト'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var chatList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              var chatData = chatList[index];
              var chatTitle = chatData['title']; // グループ名や個人名

              return ListTile(
                title: Text(chatTitle),
                onTap: () {
                  // 選択されたチャットに基づいて次の画面に遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        //chatId: chatData.id, // 選択されたチャットのIDを渡す
                        //chatTitle: chatTitle,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}