import 'package:flutter/material.dart';

class HomeSearch extends StatefulWidget {
  final String searchHint;
  final TextEditingController controller;
  final bool showSendButton;

  // CHANGED: The callback now passes a String so the parent screen knows the selected model
  final Function(String)? onSearch;

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
  String? selectedModel = 'detailed';

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = widget.controller.text.trim().isNotEmpty;

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
              maxLines: selectedModel == 'product' ? 1 : null,
              maxLength: selectedModel == 'product' ? 15 : null,
              controller: widget.controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
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
                  // CHANGED: Call the function and pass the selected model
                  onPressed: isButtonEnabled
                      ? () => widget.onSearch?.call(selectedModel ?? 'detailed')
                      : null,
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

          // Show the dropdown ONLY if showSendButton is true AND it is not compact (footer)
          if (widget.showSendButton && !widget.isCompact) ...[
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