import 'package:flutter/material.dart';
import 'speech_screen.dart';

void main() {
  runApp(MyApp()); //Runs MyApp
}

class MyApp extends StatelessWidget {
  //Extends a StatelessWidget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Ceviri', //Title
      debugShowCheckedModeBanner: false, //Removes debug mode banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpeechScreen(), //Opens SpeechScreen
    );
  }
}
