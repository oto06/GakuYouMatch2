import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatScene extends StatefulWidget {
  final String roomId;
  final String roomName;
  const ChatScene({Key? key,required this.roomId,required this.roomName}) : super(key: key);

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatScene> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.roomName),
      backgroundColor: Colors.blue,
    ),
    body: Chat(
      user: _user,
      messages: _messages,
      onSendPressed: _handleSendPressed,
    ),
  );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
// Firestore にメッセージを保存
    FirebaseFirestore.instance
        .collection('Group')
        .doc(widget.roomId) // 部屋のIDに基づいてメッセージを保存
        .collection('messages')
        .add({
      'text': message.text,
      'authorId': _user.id,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
    _addMessage(textMessage);
  }
}
