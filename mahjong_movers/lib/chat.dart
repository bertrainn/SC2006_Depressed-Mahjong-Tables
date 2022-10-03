import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  String message = '';

  static Future uploadMessage(String? idUser, String message) async {
    final refMessages =
        FirebaseFirestore.instance.collection('chats/$idUser/messages');

    final newMessage = {
      "userID": idUser,
      "message": message,
      "createdAt": DateTime.now()
    };
    await refMessages.add(newMessage);
  }

  void sendMessage() async {
    FocusScope.of(context).unfocus();

    await uploadMessage(FirebaseAuth.instance.currentUser?.uid, message);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
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
        body: Column(children: [
          Expanded(
              child: Container(
                
            padding: EdgeInsets.all(10),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/Mahjong Movers-logos_black.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats/$idUser/messages')
                    .orderBy("createAt", descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  final messages = snapshot.data;

                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    reverse: true,
                    itemCount: messages?.size,
                    itemBuilder: ((context, index) {
                      //final message = messages[index];

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.all(16),
                            constraints: BoxConstraints(maxWidth: 140),
                            decoration: BoxDecoration(
                                // color: isMe ? Colors.grey[100] : Theme.of(context).accentColor,
                                // borderRadius: isMe
                                //     ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                                //     : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
                                ),
                          )
                        ],
                      );
                    }),
                  );
                }),
          )),
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                  child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  labelText: 'Type your message',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(width: 0),
                      gapPadding: 10),
                ),
                onChanged: (value) => setState(() {
                  message = value;
                }),
              )),
              SizedBox(width: 20),
              GestureDetector(
                onTap: message.trim().isEmpty ? null : sendMessage,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.green),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ]),
          ),
        ]));
  }
}
