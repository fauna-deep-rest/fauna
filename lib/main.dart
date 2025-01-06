import 'package:flutter/material.dart';
import 'views/homepage.dart';
import 'views/chatPage/sparkyChatPage.dart';
import 'views/chatPage/bizy/bizyChatPage.dart';
import 'views/chatPage/bruno/brunoChatPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SparkyChatPage(),
    );
  }
}
