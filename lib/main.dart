import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';


import 'ChatScreenWidget.dart';
void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
 ChatScreenWidget _widget=new ChatScreenWidget();
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Codelab chat',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _widget,
    );
  }

}

