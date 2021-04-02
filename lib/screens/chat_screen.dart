import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'ChatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final fs = Firestore.instance;
FirebaseUser loggedInUser;

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth fu = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  String msgTxt;

  void sendMessage() async {
    try {
      await fs
          .collection('messages')
          .add({'text': msgTxt, 'sender': loggedInUser.email});
    } catch (e) {
      print(e);
    }
  }

  void currentUser() async {
    try {
      final user = await fu.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser();
  }

  void logout() async {
    try {
      await fu.signOut();
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                logout();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        msgTxt = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      sendMessage();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: fs.collection('messages').snapshots(),
        builder: (context, snapshot) {
          List<MessageBubble> messageBubbles = [];
          if (snapshot.hasData != null) {
            // snapshot is async snapshot from Flutter
            // Reversed is added to reverse the order of the list so new message goes
            // the bottom
            final messages = snapshot.data.documents.reversed;
            for (var message in messages) {
              // message is document snapshot from firebase
              // messageText is map that has key:value pair
              final messageText = message.data['text'];
              final messageSender = message.data['sender'];
              final currentUser = loggedInUser.email;

              final messageBubble = MessageBubble(
                text: messageText,
                sender: messageSender,
                isMe: currentUser == messageSender ? true : false,
              );
              messageBubbles.add(messageBubble);
            }
            return Expanded(
              child: ListView(
                // This makes listview sticky to bottom of listview
                reverse: true,
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                children: messageBubbles,
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  double topLeft;
  double topRight;
  Color colorDef;
  CrossAxisAlignment cal;

  MessageBubble({this.sender, this.text, this.isMe});
  @override
  Widget build(BuildContext context) {
    topLeft = isMe ? 30.0 : 0.0;
    topRight = isMe ? 0.0 : 30.0;
    colorDef = isMe ? Colors.white : Colors.blue;
    cal = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: cal,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(topLeft),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
              topRight: Radius.circular(topRight),
            ),
            color: colorDef,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text('$text'),
            ),
          ),
        ],
      ),
    );
  }
}
