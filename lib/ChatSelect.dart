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
        child: Text('ログインが必要です', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.brown[200],
      appBar: AppBar(
        title: const Text('ChatRoom', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
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
            return const Center(child: Text('エラーが発生しました', style: TextStyle(fontSize: 16)));
          }

          final chatRooms = snapshot.data?.docs ?? [];
          if (chatRooms.isEmpty) {
            return const Center(child: Text('登録または参加したチャットがありません', style: TextStyle(fontSize: 16)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(10),
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.brown[300],
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final chatRoomData = chatRooms[index].data() as Map<String, dynamic>;
              final chatRoomName = chatRoomData['name'] ?? '未設定';
              final participantCount = chatRoomData['participants']?.length ?? 0;

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  title: Text(
                    chatRoomName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  subtitle: Text(
                    '参加者: $participantCount人',
                    style: TextStyle(
                      color: Colors.brown[600],
                      fontSize: 14,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.brown[400],
                    size: 18.0,
                  ),
                  onTap: () {
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}