import 'package:flutter/material.dart';

// ChatTopBar Widget
class ChatTopBar extends StatelessWidget {
  final String title; // Title text
  final Color titleColor; // Title text color
  final Color iconColor; // Icon color
  final VoidCallback onBackPressed; // Callback for back button
  final VoidCallback onHistoryPressed; // Callback for history button

  const ChatTopBar({
    Key? key,
    required this.title,
    required this.titleColor,
    required this.iconColor,
    required this.onBackPressed,
    required this.onHistoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: iconColor), // Back button
            onPressed: onBackPressed, // Back button callback
          ),
          Text(
            title, // Title text
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.access_time,
                color: iconColor), // History button (clock icon)
            onPressed: onHistoryPressed, // History button callback
          ),
        ],
      ),
    );
  }
}
