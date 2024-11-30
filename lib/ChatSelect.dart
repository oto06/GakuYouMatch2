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
          // クエリで自分が登録したグループと参加したチャットルームを取得
          stream: FirebaseFirestore.instance
              .collection('Group')
              .where('userId', isEqualTo: currentUser.uid) // 自分が登録したグループ
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                  child: Text('データの取得中にエラーが発生しました'));
            }

            final groups = snapshot.data?.docs ?? [];

            // 参加しているグループも取得
            final participatingGroupsStream = FirebaseFirestore.instance
                .collection('ChatRooms')
                .where('participants',
                arrayContains: currentUser.uid) // 参加者に自分のuidが含まれているグループ
                .snapshots();

            return StreamBuilder<QuerySnapshot>(
              stream: participatingGroupsStream,
              builder: (context, participatingSnapshot) {
                if (participatingSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (participatingSnapshot.hasError) {
                  return const Center(child: Text('エラーが発生しました'));
                }

                final participatingGroups = participatingSnapshot.data?.docs ??
                    [];
                final allGroups = [...groups, ...participatingGroups];

                if (allGroups.isEmpty) {
                  return const Center(
                      child: Text('登録または参加したチャットがありません'));
                }

                return ListView.builder(
                  itemCount: allGroups.length,
                  itemBuilder: (context, index) {
                    final groupData = allGroups[index].data() as Map<
                        String,
                        dynamic>;
                    final groupName = groupData['name'] ??
                        '未設定'; // 名前がnullならデフォルトを表示
                    final eventType = groupData['eventType'] ?? '不明';

                    return ListTile(
                      title: Text(groupName),
                      subtitle: Text(eventType),
                      onTap: () {
                        // チャットルームに移動する処理
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatScene(
                                  roomId: allGroups[index].id,
                                  roomName: groupName,
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        )
    );
  }
}