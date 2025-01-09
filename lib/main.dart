import 'package:flutter/material.dart';
import 'views/homepage.dart';
import 'views/chat_page/sparky_chat_page.dart';
import 'views/chat_page/bizy/bizy_chat_page.dart';
import 'views/chat_page/bruno/bruno_chat_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fauna/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeData.light().copyWith(
          hintColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        routerConfig: routerConfig,
        restorationScopeId: 'app',
      ),
    );
  }
}
