import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScene extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatScene({
    Key? key,
    required this.roomId,
    required this.roomName,
  }) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatScene> {
  late types.User _user; // ログインユーザー情報を保持

  @override
  void initState() {
    super.initState();

    // ログイン中のユーザー情報を取得
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      _user = types.User(id: currentUser.uid); // Firebase Authenticationのuidを使用
    } else {
      // ログインしていない場合のエラー処理
      throw Exception("ユーザーがログインしていません");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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

          if (snapshot.hasError) {
            return const Center(child: Text("エラーが発生しました"));
          }

          final docs = snapshot.data?.docs ?? [];

          return Chat(
            user: _user, // ログインユーザーの情報を設定
            messages: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return types.TextMessage(
                author: types.User(id: data['authorId']), // FirestoreのauthorIdを使用
                createdAt: data['createdAt'],
                id: doc.id,
                text: data['text'],
              );
            }).toList(),
            onSendPressed: _handleSendPressed,
            showUserAvatars: true,
            showUserNames: true,
          );
        },
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    FirebaseFirestore.instance
        .collection('Group')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'text': message.text,
      'authorId': _user.id, // ログイン中のユーザーIDを保存
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

