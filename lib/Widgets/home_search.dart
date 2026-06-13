import 'package:flutter/material.dart';

class HomeSearch extends StatelessWidget {
  final String searchHint;
  const HomeSearch({super.key, required this.searchHint});

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
            contentPadding: const EdgeInsets.symmetric(vertical: 20,),
            filled: true,
            fillColor: Colors.white,
            hintText: searchHint,
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
          ),
        ),
      ),
    );
  }
}