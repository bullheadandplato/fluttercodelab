import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'ChatMessage.dart';

class ChatScreenWidget extends StatefulWidget {
  ChatScreenState _screenState=new ChatScreenState();

  @override
  createState() => _screenState;
  ChatScreenState get screenState => _screenState;
}

class ChatScreenState extends State<ChatScreenWidget> with TickerProviderStateMixin {
  List<ChatMessage> _messages=<ChatMessage>[];
  final googleSignIn=new GoogleSignIn();

  List<ChatMessage> get messages => _messages;
  bool _isComposing=false;

  final TextEditingController _textController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Friendly chat")),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new ListView.builder(
              padding: new EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_,int index)=>_messages[index],
              itemCount: _messages.length,
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
      }

    }
  }
  Future<Null>  _handleSubmitted(String text) async {
    _textController.clear();
    setState((){_isComposing=false;});
    await _ensureLoggedIn();
    _sendMessage(text);

  }
  void _sendMessage(String text){
     ChatMessage message=new ChatMessage(
        text: text,
        animationController: new AnimationController(
            vsync: this,
          duration: new Duration(milliseconds: 700  )
        ),);
    setState((){
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }
}
