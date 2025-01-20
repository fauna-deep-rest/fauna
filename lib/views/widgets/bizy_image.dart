import 'package:flutter/material.dart';

// SparkyImage Widget
class BizyImage extends StatelessWidget {
  final String imagePath; // Path to the image
  final double size; // Size of the circular image

  const BizyImage({
    Key? key,
    required this.imagePath,
    this.size = 200.0, // Default size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[800], // Background color
      ),
      child: Center(
        child: Image.asset(
          imagePath, // Load the image
          width: size * 0.5, // Image width (50% of the circular size)
          height: size * 0.5, // Image height (50% of the circular size)
        ),
      ),
    );
  }
}
