import 'package:flutter/material.dart';

// NavigationButton Widget
class NavigationButton extends StatelessWidget {
  final String label; // Button label
  final VoidCallback onPressed; // Callback for button press
  final Color backgroundColor; // Background color of the button

  const NavigationButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.blue, // Default background color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Handle button press
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
      ),
      child: Text(
        label, // Display the button label
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
