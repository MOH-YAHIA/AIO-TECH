import 'package:flutter/material.dart';

class HomeSearch extends StatelessWidget {
  const HomeSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Container(
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
          maxLines: null,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 40,),
            filled: true,
            fillColor: Colors.white,
            hintText: "Describe What you need...",
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
            suffixIcon:  IconButton(
                onPressed: () {},
                icon: const Icon(Icons.send),
                iconSize: 40,
                color: const Color(0xFF3E5966),
              ),
          ),
        ),
      ),
    );
  }
}