import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class NewChat extends StatelessWidget {
  final VoidCallback onPressed;

  const NewChat({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBackground,
      ),
      child: const Text(
        "+ New chat",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}