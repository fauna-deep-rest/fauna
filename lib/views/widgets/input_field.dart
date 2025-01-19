import 'package:flutter/material.dart';

// InputField Widget
class InputField extends StatelessWidget {
  final TextEditingController controller; // Text editing controller
  final Function(String) onSubmitted; // Callback for text submission

  const InputField({
    Key? key,
    required this.controller,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Say something...",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
              controller: controller, // Use the provided controller
              onSubmitted: onSubmitted, // Use the provided callback
            ),
          ),
          SizedBox(width: 8.0),
          GestureDetector(
            onTap: () {
              // Handle send button tap
              if (controller.text.isNotEmpty) {
                onSubmitted(controller.text); // Call the onSubmitted callback
                controller.clear(); // Clear the text field
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
