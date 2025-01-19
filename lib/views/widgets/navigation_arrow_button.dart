import 'package:flutter/material.dart';

class NavigationArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  const NavigationArrowButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: 32,
        color: iconColor,
      ),
      onPressed: onPressed,
    );
  }
}
