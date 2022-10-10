import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'dart:convert';
import 'dart:math';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late List<types.Message> _messages = [];

  final _user = types.User(id: FirebaseAuth.instance.currentUser?.uid ?? "");

  void RetrieveChatData(String jobID) {
    late List<types.Message> _tempMessages = [];
    FirebaseFirestore.instance
        .collection('chats')
        .doc(jobID)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .get()
        .then((snapshot) {
      for (int i = 0; i < snapshot.size; i++) {
        final textMessage = types.TextMessage(
          author: types.User(id: snapshot.docs[i]['author']),
          createdAt: snapshot.docs[i]['createdAt'],
          id: snapshot.docs[i].id,
          text: snapshot.docs[i]['text'],
        );
        _tempMessages.add(textMessage);
      }
      setState(() {
        _messages = _tempMessages;
      });
    });
  }

  String jobID = "";

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    jobID = arguments['jobID'];
    RetrieveChatData(jobID);

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            )),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 33, 126, 50),
            title: const Text(
              "Chat",
              style: TextStyle(color: Colors.white),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          )),
      body: Chat(
        theme: const DefaultChatTheme(
            inputBackgroundColor: Colors.grey, primaryColor: Colors.green),
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) async {
    Map<String, dynamic> textMessageJSON = {
      'author': FirebaseAuth.instance.currentUser?.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'text': message.text,
    };

    final newMessage = FirebaseFirestore.instance
        .collection('chats')
        .doc(jobID)
        .collection('messages');

    await newMessage.add(textMessageJSON);
  }
}
