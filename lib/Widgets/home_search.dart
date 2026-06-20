import 'package:flutter/material.dart';

class HomeSearch extends StatefulWidget {
  final String searchHint;
  final TextEditingController controller;
  final bool showSendButton;
  final VoidCallback? onSearch;

  // Flag to shrink the text field when it moves to the footer
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
  // Default to 'details' so it is open by default
  String? selectedModel = 'detailed';

  @override
  Widget build(BuildContext context) {
    // Check if the text field has text to enable/disable the button
    bool isButtonEnabled = widget.controller.text.trim().isNotEmpty;

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // Aligns the dropdown to the right
        children: [


          // 2. The Text Field Container
          Container(
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
              // 3. Dynamic constraints based on the selected model
              maxLines: selectedModel == 'product' ? 1 : null,
              maxLength: selectedModel == 'product' ? 15 : null,
              controller: widget.controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                // Hide the character counter (e.g., "0/15") to keep the UI clean
                counterText: "",
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.isCompact ? 15 : 40,
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
                  borderSide: const BorderSide(width: 3, color: Colors.black),
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
          // 1. Show the dropdown ONLY if showSendButton is true
          if (widget.showSendButton) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: DropdownButton<String>(
                  value: selectedModel,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  hint: const Text(
                    "Model",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0x8E424040),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "product", child: Text("Product")),
                    DropdownMenuItem(value: "detailed", child: Text("Detailed")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedModel = value;
                      if (value == 'product' && widget.controller.text.length > 20) {
                        widget.controller.text = widget.controller.text.substring(0, 20);
                      }
                    });
                  },
                ),

            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}