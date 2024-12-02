import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gakuyoumatch2/Chat.dart';
import 'package:gakuyoumatch2/Chat.dart'; // チャット画面への遷移

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('ログインが必要です'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ChatRooms')
            .where('participants', arrayContains: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('エラーが発生しました'));
          }

          final chatRooms = snapshot.data?.docs ?? [];
          if (chatRooms.isEmpty) {
            return const Center(child: Text('登録または参加したチャットがありません'));
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoomData = chatRooms[index].data() as Map<String, dynamic>;
              final chatRoomName = chatRoomData['name'] ?? '未設定';

              return ListTile(
                title: Text(chatRoomName),
                subtitle: Text('参加者: ${chatRoomData['participants']?.length ?? 0}人'),
                onTap: () {
                  // チャット画面に移動
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScene(
                        roomId: chatRooms[index].id,
                        roomName: chatRoomName,
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