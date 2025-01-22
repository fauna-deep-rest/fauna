import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class NSDRPage extends StatefulWidget {
  const NSDRPage({super.key});

  @override
  _NSDRPageState createState() => _NSDRPageState();
}

class _NSDRPageState extends State<NSDRPage> {
  late Timer _timer;
  int _currentIndex = 0;

  final List<String> _messages = [
    "右腳",
    "左腳",
    "肚子",
    "胸",
    "頭",
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
      appBar: AppBar(title: const Text("NSDR 頁面")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(_messages[_currentIndex], style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Expanded(child: RiveAnimation.asset('assets/animations/bruno.riv')),
          ],
        ),
      ),
    );
  }
}
