import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
class ChatMessage extends StatelessWidget{
  ChatMessage({this.text,this.animationController});
  final DataSnapshot text;
  final Animation animationController;

  static const  String _name="Osama";

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent:animationController,
            curve: Curves.easeOut),
    axisAlignment: 0.0,
    child: new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: new GoogleUserCircleAvatar(text.value['senderPhotoUrl']),
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(text.value['senderName'],style: Theme.of(context).textTheme.subhead),
              new Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: new Text(text.value['text'])
              )
            ],
          )
        ],
      ),
    )
    );
  }
}