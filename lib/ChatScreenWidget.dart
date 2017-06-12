import 'dart:io';
import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'ChatMessage.dart';

class ChatScreenWidget extends StatefulWidget {
  ChatScreenState _screenState=new ChatScreenState();

  @override
  createState() => _screenState;
  ChatScreenState get screenState => _screenState;
}

class ChatScreenState extends State<ChatScreenWidget> {

  final googleSignIn=new GoogleSignIn();
  final auth        =FirebaseAuth.instance;
  final analytics=new FirebaseAnalytics();
  final reference = FirebaseDatabase.instance.reference().child("messages");

  bool _isComposing=false;

  final TextEditingController _textController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Friendly chat")),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new FirebaseAnimatedList(
              query:reference,
              sort: (a,b)=>b.key.compareTo(a.key),
              padding: new EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_,DataSnapshot snapshot,Animation<double> animation){
                return new ChatMessage(text:snapshot,animationController:animation);
              }

            ),
          ),
          new Divider(height: 1.0,),
          new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).cardColor
            ),
            child: _buildTextView(),
          )
        ],
      ),
    );
  }

  Widget _buildTextView() {
    return new IconTheme(data: new IconThemeData(color: Theme.of(context).accentColor),
    child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 7.0),
        child: new Row(
          children: <Widget>[
            new Container(
          margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.camera),
                  onPressed: () async{
                    await _ensureLoggedIn();
                    File imageFile=await ImagePicker.pickImage();
                    int random=new Random().nextInt(10000);
                    StorageReference ref=
                        FirebaseStorage.instance.ref().child("image_$random.jpg");
                    StorageUploadTask task=ref.put(imageFile);
                    Uri downloadUri=(await task.future).downloadUrl;
                    _sendMessage(imageUrl:downloadUri.toString());
                  }
                  ),
        ),
            new Flexible(
                child: new TextField(
              controller: _textController,
              onChanged: (String text) {
                setState(() {
                  _isComposing=text.length>0;
                });
              },
              onSubmitted: _handleSubmitted,
              decoration:
                  new InputDecoration.collapsed(hintText: "Send a message"),
            )),
            new Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: new  IconButton(
                icon: new Icon(Icons.send),
                onPressed: _isComposing ? ()=>_handleSubmitted(_textController.text) : null,
              ),
            )
          ],
        )
    ));
  }
  Future<Null> _ensureLoggedIn() async{
    GoogleSignInAccount googleSignInAccount=googleSignIn.currentUser;
    if(googleSignInAccount==null){
      googleSignInAccount=await googleSignIn.signInSilently();
      if(googleSignInAccount==null){
        await googleSignIn.signIn();
        analytics.logLogin();
      }
      if(auth.currentUser==null){
        GoogleSignInAuthentication credentials=
            await googleSignIn.currentUser.authentication;
        await auth.signInWithGoogle(
          idToken: credentials.idToken,
          accessToken: credentials.accessToken,
        );
      }

    }
  }
  Future<Null>  _handleSubmitted(String text) async {
    _textController.clear();
    setState((){_isComposing=false;});
    await _ensureLoggedIn();
    _sendMessage(text:text);

  }
  void _sendMessage({String text,String imageUrl}){
    reference.push().set({
      'text':text,
      'image':imageUrl,
      'senderName':googleSignIn.currentUser.displayName,
      'senderPhotoUrl':googleSignIn.currentUser.photoUrl
    });
  }
}
