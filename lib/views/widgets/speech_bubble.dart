import 'package:flutter/material.dart';

// SpeechBubble Widget
class SpeechBubble extends StatelessWidget {
  final String text; // Text to display
  final bool isGettingResponse; // Flag to determine response state

  const SpeechBubble({
    super.key,
    required this.text,
    required this.isGettingResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 100, // 固定高度
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center, // 確保內容水平置中
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7), // Background color
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
        ),
        child: Text(
          text, // Display the text
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center, // 文字水平置中
        ),
      ),
    );
  }
}
