import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:fauna/views/widgets/chat_widgets.dart';
import 'package:fauna/views/chat_page/bruno/bruno_chat_page.dart';

class NSDRPage extends StatefulWidget {
  const NSDRPage({super.key});

  @override
  _NSDRPageState createState() => _NSDRPageState();
}

class _NSDRPageState extends State<NSDRPage> {
  late Timer _timer;
  int _currentIndex = 0;

  final List<String> _messages = [
    "Start with your right foot, rooting it firmly into the ground like a tree.",
    // "Take a deep breath in... and slowly exhale.",
    "Shift your focus to your left foot, steady and secure.",
    // "Inhale... feel the calm, and then exhale slowly.",
    "Focus on your abdomen, sensing the flow of your breath.",
    // "Once more, take a deep breath in... and gently breathe out.",
    "Notice your chest, your heartbeat like the steady drumbeat of the forest.",
    // "Inhale... bring in relaxation, and exhale... release any tension.",
    "Focus on your head, feeling sunlight gently shining down.",
    // "One last time, breathe in deeply... and exhale, letting your mind and body settle into peace."
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentIndex < _messages.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/bg_bruno.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              ChatTopBar(
                title: "NSDR",
                titleColor: Colors.white,
                iconColor: Colors.white,
                onBackPressed: () {
                  Navigator.of(context).pop();
                },
                onHistoryPressed: () {
                  print('history pressed');
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentIndex < _messages.length)
                        SpeechBubble(
                          text: _messages[_currentIndex],
                          isGettingResponse: false,
                        ),
                      const SizedBox(height: 20),
                      const Expanded(
                          child: SizedBox(
                        width: 200,
                        height: 200,
                        child:
                            RiveAnimation.asset('assets/animations/bruno.riv'),
                      )),
                      const SizedBox(height: 20),
                      if (_currentIndex >= _messages.length - 1)
                        NavigationButton(
                            label: "Back to Bruno",
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BrunoChatPage(),
                                ),
                              );
                            })
                      else
                        const SizedBox(height: 40),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
