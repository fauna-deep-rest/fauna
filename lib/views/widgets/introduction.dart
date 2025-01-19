import 'package:flutter/material.dart';

class Introduction extends StatelessWidget {
  final String name;
  final String description;
  final TextStyle? nameStyle;
  final TextStyle? descriptionStyle;

  const Introduction({
    super.key,
    required this.name,
    required this.description,
    this.nameStyle,
    this.descriptionStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: nameStyle?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ) ??
              const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: descriptionStyle?.copyWith(
                fontSize: 16,
              ) ??
              const TextStyle(
                fontSize: 16,
              ),
        ),
      ],
    );
  }
}
