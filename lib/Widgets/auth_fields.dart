import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class AuthFields extends StatelessWidget {
  final String label;
  final Widget suffixIcon;
  final bool obscure;
  final TextEditingController controller;
  final String? Function(String?) validator;
  const AuthFields({
    super.key,
    required this.label,
    required this.suffixIcon,
    required this.controller,
    required this.validator,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Slightly darker shadow for depth on gradient
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextFormField(
        maxLines: obscure ? 1 : null,
        textAlign: TextAlign.left,
        obscureText: obscure,
        controller: controller,
        validator: validator,
        style: const TextStyle(color: Colors.white), // Added for input text color
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15), // Glassmorphism translucent fill
          hintText: label,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.7), // Adjusted hint color for dark background
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none, // Removed harsh borders for a clean look
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(width: 1.5, color: Colors.white.withOpacity(0.3)), // Subtle white border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(width: 2, color: Colors.white), // Highlighted border on focus
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
