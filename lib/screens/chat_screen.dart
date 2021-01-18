import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = "Chat_Screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messagetextcontroller= TextEditingController();
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser LogginedInUser;
  String messagetext;
  DateTime mTime=DateTime.now();


  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser()async{
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        LogginedInUser = user;
      }
    }catch(e){
      print(e);
    }
  }

  void messagesstream()async{
     await for(var snapshot in _firestore.collection('masseges').snapshots()) {
       for (var message in snapshot.documents) {

       }
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
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
            StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('masseges').snapshots(),
               builder: (context,snapshot){
                  if(!snapshot.hasData){
                    return Center(
                      child: CircularProgressIndicator(
                       backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }
                    final messages = snapshot.data.documents.reversed;
                    List<MessageBubble> messageWidgets=[];
                    for(var message in messages){
                     String messageText = message.data['text'];
                     String messagesender=message.data['sender'];

                     final CurrentUser=LogginedInUser.email;

                     final messageWidget =
                         MessageBubble(sender: messagesender,text: messageText, isMe: CurrentUser==messagesender,);
                         messageWidgets.add(messageWidget);
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                      children: messageWidgets,
                    ),
                    );

               },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messagetextcontroller,
                      onChanged: (value) {
                        messagetext = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messagetextcontroller.clear();
                      _firestore.collection('masseges').add({
                        //'time': mTime,
                        'text':messagetext ,
                        'sender': LogginedInUser.email,
                      });
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


class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender,this.text,this.isMe});
  String sender;
  String text;
  bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              sender,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 10,
              ),
          ),
          Material(
            borderRadius:isMe? BorderRadius.only(topLeft: Radius.circular(30.0)
                                            ,bottomLeft: Radius.circular(30.0)
                                            ,bottomRight: Radius.circular(30.0))
                              :BorderRadius.only(topRight: Radius.circular(30.0)
                                                ,bottomLeft: Radius.circular(30.0)
                                                ,bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe==true?Colors.lightBlueAccent:Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isMe==true?Colors.white:Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
