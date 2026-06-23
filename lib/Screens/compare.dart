import 'package:aio_tech/Widgets/home_search.dart';
import 'package:aio_tech/Widgets/result_comparison_format.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/product_service.dart';
import '../Widgets/new_chat.dart';
import '../utils/app_colors.dart';

class Compare extends StatefulWidget {
  const Compare({super.key});

  @override
  State<Compare> createState() => _CompareState();
}

class _CompareState extends State<Compare> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _device1Controller = TextEditingController();
  final TextEditingController _device2Controller = TextEditingController();
  final ProductService _productService = ProductService();

  bool _hasCompared = false;
  bool _isLoading = false;
  String _queryA = "";
  String _queryB = "";
  Map<String, dynamic>? _compareResult;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _device1Controller.addListener(_updateButtonState);
    _device2Controller.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  @override
  void dispose() {
    _device1Controller.dispose();
    _device2Controller.dispose();
    super.dispose();
  }

  // Make this async and call the FastAPI
  Future<void> _performComparison() async {
    setState(() {
      _hasCompared = true;
      _isLoading = true;
      _errorMessage = "";
      _queryA = _device1Controller.text;
      _queryB = _device2Controller.text;
    });

    final result = await _productService.compareDevices(
      productA: _queryA,
      productB: _queryB,
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        // Finds the map containing 'ai_comparison' regardless of how many
        // payload/data wrapper levels the backend uses.
        _compareResult = ProductService.extractCompareMap(result['data']);
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _hasCompared ? _buildResultsView() : _buildInitialView(),
      ),
    );
  }

  Widget _buildInitialView() {
    final bool isButtonEnabled = _device1Controller.text.trim().isNotEmpty &&
        _device2Controller.text.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsetsDirectional.all(10),
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          backgroundColor: Color(0xFF2E373C),
          radius: 45,
          child: Icon(Icons.compare_arrows, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 25),
        const Text(
          "Device Comparison",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3133),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),

        HomeSearch(
          showSendButton: false,
          searchHint: "Device 1",
          controller: _device1Controller,
        ),
        const SizedBox(height: 40),
        HomeSearch(
          showSendButton: false,
          searchHint: "Device 2",
          controller: _device2Controller,
        ),
        const SizedBox(height: 60),

        SizedBox(
          width: 100,
          height: 50,
          child: ElevatedButton(
            onPressed: isButtonEnabled ? _performComparison : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isButtonEnabled
                  ? AppColors.buttonBackground
                  : Colors.grey.shade400,
            ),
            child: const Text("Compare", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    final bool isButtonEnabled = _device1Controller.text.trim().isNotEmpty &&
        _device2Controller.text.trim().isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: NewChat(
              onPressed: () {
                setState(() {
                  _hasCompared = false;
                  _compareResult = null;
                  _device1Controller.clear();
                  _device2Controller.clear();
                });
              },
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.buttonBackground,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Compare: $_queryA vs $_queryB",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Handle API States
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.red.shade50,
                  child: Text("Error: $_errorMessage", style: const TextStyle(color: Colors.red)),
                )
              else if (_compareResult != null)
                  ResultComparisonFormat(data: _compareResult!)
            ],
          ),
        ),

        // Footer Comparison Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: HomeSearch(
                      showSendButton: false,
                      searchHint: "Device 1",
                      controller: _device1Controller,
                      isCompact: true,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("VS", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: HomeSearch(
                      showSendButton: false,
                      searchHint: "Device 2",
                      controller: _device2Controller,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? _performComparison : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? AppColors.buttonBackground
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Update Comparison", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}