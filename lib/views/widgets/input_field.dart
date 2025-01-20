import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final Function(String) onSubmitted; // Callback for text submission

  const InputField({
    Key? key,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController controller; // Declare the controller

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(); // Initialize the controller
  }

  @override
  void dispose() {
    controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

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
              controller: controller, // Use the controller
              onSubmitted: (String value) {
                if (controller.text.isNotEmpty) {
                  widget.onSubmitted(
                      controller.text); // Call the onSubmitted callback
                  controller.clear(); // Clear the text field
                }
              },
            ),
          ),
          SizedBox(width: 8.0),
          GestureDetector(
            onTap: () {
              // Handle send button tap
              if (controller.text.isNotEmpty) {
                widget.onSubmitted(
                    controller.text); // Call the onSubmitted callback
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
