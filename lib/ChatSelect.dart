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
      appBar: AppBar(title: const Text('ChatRoom')),
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

          return ListView.separated(
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.shade300,
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final chatRoomData = chatRooms[index].data() as Map<String, dynamic>;
              final chatRoomName = chatRoomData['name'] ?? '未設定';
              final participantCount = chatRoomData['participants']?.length ?? 0;

              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
              ),
                    child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      title: Text(
                      chatRoomName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                ),
              ),
                      subtitle: Text(
                          '参加者: $participantCount人',
                          style: TextStyle(
                          color: Colors.grey.shade600,
                ),
              ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 16.0,
              ),
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
              )
              )
              );
            },
          );
        },
      ),
    );
  }
}