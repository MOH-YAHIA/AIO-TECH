import 'package:flutter/material.dart';

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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          maxLines: obscure ? 1 : null,
          textAlign: TextAlign.left,
          obscureText: obscure,
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
            filled: true,
            fillColor: Colors.white,
            hintText: label,
            hintStyle: const TextStyle(
              color: Color(0x8E424040),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(width: 3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(width: 3, color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(width: 3, color: Colors.black),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      );
  }
}