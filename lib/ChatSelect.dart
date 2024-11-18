import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:gakuyoumatch2/map%20search.dart';
import 'Chat.dart'; // メッセージ画面をインポート

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('部屋一覧')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Group').orderBy('createdAt').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data!.docs;

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              // Firestoreから日付を取得
              final eventDate = group['eventDate']?.toDate(); // FirebaseのTimestampをDateTimeに変換
              final formattedDate = eventDate != null ? "${eventDate.year}-${eventDate.month}-${eventDate.day}" : "日付未設定";

              return ListTile(
                title: Text(group['name']),
                subtitle: Text('${group['eventType']} - ${group['eventDetails']} - $formattedDate'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScene(
                        roomId: group.id,
                        roomName: group['name'],
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
