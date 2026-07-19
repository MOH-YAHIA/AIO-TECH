import 'package:aio_tech/utils/app_colors.dart';
import 'package:flutter/material.dart';

class HomeSearch extends StatefulWidget {
  final String searchHint;
  final TextEditingController controller;
  final bool showSendButton;
  final VoidCallback? onSearch;
  final bool isCompact;

  const HomeSearch({
    super.key,
    required this.searchHint,
    required this.controller,
    this.showSendButton = true,
    this.onSearch,
    this.isCompact = false,
  });

  @override
  State<HomeSearch> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = widget.controller.text.trim().isNotEmpty;

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: TextFormField(
              controller: widget.controller,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.isCompact ? 15 : 20,
                  horizontal: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: widget.searchHint,
                hintStyle: TextStyle(
                  color: const Color(0x8E424040),
                  fontWeight: FontWeight.bold,
                  fontSize: widget.isCompact ? 16 : 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(width: 3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(width: 3, color: AppColors.searchBarBackground),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(width: 3, color: Colors.black),
                ),
                suffixIcon: widget.showSendButton
                    ? IconButton(
                  onPressed: isButtonEnabled ? widget.onSearch : null,
                  icon: const Icon(Icons.send),
                  iconSize: widget.isCompact ? 30 : 40,
                  color: isButtonEnabled
                      ? const Color(0xFF3E5966)
                      : Colors.grey,
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}