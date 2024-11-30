import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:gakuyoumatch2/map%20search.dart';
import 'Chat.dart'; // メッセージ画面をインポート
import 'package:firebase_auth/firebase_auth.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('部屋一覧')),
        body: const Center(
          child: Text('ログインが必要です'),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Group')
            .where('userId', isEqualTo: currentUser.uid) // 自分のデータのみ取得
            .orderBy('createdAt') // 作成日時順に並べる
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data!.docs;

          if (groups.isEmpty) {
            return const Center(child: Text('登録された部屋がありません'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final eventDate = group['eventDate']?.toDate(); // FirebaseのTimestampをDateTimeに変換
              final formattedDate = eventDate != null
                  ? "${eventDate.year}-${eventDate.month}-${eventDate.day}"
                  : "日付未設定";

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
