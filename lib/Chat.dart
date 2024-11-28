import 'dart:async'; // 非同期処理用
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatScene extends StatefulWidget {
  final String roomId;
  final String roomName;
  const ChatScene({Key? key, required this.roomId, required this.roomName}) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatScene> {
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac'); // 自分のユーザーID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Group')
            .doc(widget.roomId)
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("まだメッセージがありません"));
          }

          // 非同期処理を解決するために Future を待つ
          return FutureBuilder<List<types.Message>>(
            future: _convertMessages(snapshot.data!.docs),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (futureSnapshot.hasError) {
                return const Center(child: Text("エラーが発生しました"));
              }

              final messages = futureSnapshot.data ?? [];

              return Chat(
                user: _user,
                messages: messages,
                onSendPressed: _handleSendPressed,
                showUserAvatars: true,
                showUserNames: true,
              );
            },
          );
        },
      ),
    );
  }

  Future<List<types.Message>> _convertMessages(List<QueryDocumentSnapshot> docs) async {
    // Firestoreのドキュメントを非同期的にTextMessageに変換
    final List<Future<types.Message>> futures = docs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;

      // Firestoreからユーザー情報を取得
      final authorData = await _fetchUserProfile(data['authorId']);

      return types.TextMessage(
        author: types.User(
          id: data['authorId'],
          firstName: authorData['nickname'] ?? 'Unknown',
          imageUrl: authorData['imageUrl'],
        ),
        createdAt: data['createdAt'],
        id: doc.id,
        text: data['text'],
      );
    }).toList();

    // Future のリストを解決して List<Message> に変換
    return await Future.wait(futures);
  }

  Future<Map<String, dynamic>> _fetchUserProfile(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    return doc.data() ?? {};
  }

  void _handleSendPressed(types.PartialText message) {
    FirebaseFirestore.instance
        .collection('Group')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'text': message.text,
      'authorId': _user.id,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}


