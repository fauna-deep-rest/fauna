import 'package:flutter/material.dart';

// BrunoImage Widget
class BrunoImage extends StatelessWidget {
  final String imagePath; // Path to the image
  final double size; // Size of the image

  const BrunoImage({
    super.key,
    required this.imagePath,
    this.size = 200.0, // Default size
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        imagePath, // Load the image
        width: size,
        height: size,
      ),
    );
  }
}
