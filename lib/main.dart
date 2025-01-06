import 'package:flutter/material.dart';
import 'views/homepage.dart';
import 'views/chatPage/sparkyChatPage.dart';
import 'views/chatPage/bizy/bizyChatPage.dart';
import 'views/chatPage/bruno/brunoChatPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
