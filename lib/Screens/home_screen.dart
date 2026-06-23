import 'package:aio_tech/Widgets/home_search.dart';
import 'package:aio_tech/Widgets/product_search_result.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/product_service.dart';
import '../Widgets/new_chat.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _device1Controller = TextEditingController();
  final ProductService _productService = ProductService(); // Initialize service

  bool _hasSearched = false;
  bool _isLoading = false; // Track API loading state
  String _lastQuery = "";
  Map<String, dynamic>? _apiResult; // Store the JSON response
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _device1Controller.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  @override
  void dispose() {
    _device1Controller.dispose();
    super.dispose();
  }

  // Update this to accept the model from the HomeSearch dropdown
  Future<void> _performSearch(String modelType) async {
    setState(() {
      _hasSearched = true;
      _isLoading = true; // Start loading spinner
      _errorMessage = "";
      _lastQuery = _device1Controller.text;
      _device1Controller.clear();
    });

    // Call the FastAPI endpoint
    final result = await _productService.dispatchSearch(
      query: _lastQuery,
      serviceName: modelType,
    );

    setState(() {
      _isLoading = false; // Stop loading spinner
      if (result['success']) {
        // Handles both 'product' and 'detailed' modes, regardless of how
        // many payload/data wrapper levels the backend uses, and whether
        // the result comes back as a single object or a list of matches.
        _apiResult = ProductService.extractProductMap(result['data']);
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
        child: _hasSearched ? _buildResultsView() : _buildInitialView(),
      ),
    );
  }

  Widget _buildInitialView() {
    return ListView(
      padding: const EdgeInsetsDirectional.all(10),
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          backgroundColor: Color(0xFF2E373C),
          radius: 45,
          child: Icon(Icons.auto_awesome, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 25),
        Text(
          "Smart Market Radar".tr(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3133),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        const Text(
          "Find the best electronics deals across Egypt using our intelligent scanner.",
          style: TextStyle(fontSize: 18, color: Color(0xAA2C3133)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),

        HomeSearch(
          showSendButton: true,
          searchHint: "Describe what you want",
          controller: _device1Controller,
          onSearch: _performSearch, // This now passes the dropdown selection correctly
        ),

        const SizedBox(height: 40),
        const Row(
          spacing: 10,
          children: [
            Icon(Icons.trending_up, color: Colors.orange, size: 30),
            Text(
              "Recommendations",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: NewChat(
              onPressed: () {
                setState(() {
                  _hasSearched = false;
                  _apiResult = null; // Clear previous results
                  _device1Controller.clear();
                });
              },
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Query Chat Bubble
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
                    _lastQuery,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Conditional Rendering based on API status
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.red.shade50,
                  child: Text("Error: $_errorMessage", style: const TextStyle(color: Colors.red)),
                )
              else if (_apiResult != null)
                // Pass the real API data into your UI Widget!
                  ProductSearchResult(data: _apiResult!)
            ],
          ),
        ),

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
          child: HomeSearch(
            showSendButton: true,
            searchHint: "Search again...",
            controller: _device1Controller,
            isCompact: true,
            // Since there's no dropdown in compact mode, default it to 'detailed'
            onSearch: (model) => _performSearch('detailed'),
          ),
        ),
      ],
    );
  }
}