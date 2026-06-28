import 'package:aio_tech/Widgets/home_search.dart';
import 'package:aio_tech/Widgets/product_search_result.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Widgets/star_logo.dart';
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
  final ProductService _productService = ProductService();

  bool _hasSearched = false;
  bool _isLoading = false;
  String _lastQuery = "";

  dynamic _apiResult;
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

  Future<void> _performSearch(String modelType) async {
    setState(() {
      _hasSearched = true;
      _isLoading = true;
      _errorMessage = "";
      _lastQuery = _device1Controller.text;
      _device1Controller.clear();
    });

    final result = await _productService.dispatchSearch(
      query: _lastQuery,
      serviceName: modelType,
    );

    setState(() {
      _isLoading = false;
      if (result['success']) {
        // The backend always wraps responses as:
        // { status, routing, payload: { source, data: <actual content> } }
        // 'detailed' mode: data is a List  → renders multiple cards
        // 'product'  mode: data is a Map   → renders one card
        // Walk payload → data to reach the real content in both cases.
        dynamic unwrapped = result['data'];
        for (final key in ['payload', 'data']) {
          if (unwrapped is Map && unwrapped.containsKey(key)) {
            unwrapped = unwrapped[key];
          }
        }
        _apiResult = unwrapped;
      } else {
        _errorMessage = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _hasSearched ? _buildResultsView() : _buildInitialView(),
      ),
    );
  }

  Widget _buildInitialView() {
    return ListView(
      padding: const EdgeInsetsDirectional.all(10),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 350,
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 400,
              height: 280,
              child: const StarLogo(),
            ),
          ),
        ),
        Text(
          "Smart Market Radar".tr(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                "Find the best electronics deals across Egypt using our intelligent scanner.",
                textStyle: const TextStyle(fontSize: 18, color: AppColors.primaryText),
                textAlign: TextAlign.center,
                // English Comment: You can adjust the typing speed here
                speed: const Duration(milliseconds: 100),
              ),
            ],
            // English Comment: Set to 1 so the animation only plays once and stops
            totalRepeatCount: 3,
            // English Comment: If the user taps the text, it will instantly finish typing
            displayFullTextOnTap: true,
            // English Comment: Ensures it doesn't pause before starting
            pause: const Duration(milliseconds: 0),
          ),
        ),
        const SizedBox(height: 60),

        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: HomeSearch(
              showSendButton: true,
              searchHint: "Describe what you want",
              controller: _device1Controller,
              onSearch: _performSearch,
            ),
          ),
        ),

        const SizedBox(height: 40),

        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.orange, size: 30),
                const SizedBox(width: 10),
                const Text(
                  "Recommendations",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: AppColors.primaryText),
                ),
              ],
            ),
          ),
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
                  _apiResult = null;
                  _device1Controller.clear();
                });
              },
            ),
          ),
        ),

        // Wrap the list items in a Center+ConstrainedBox to keep the chat view centered on laptops
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
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

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.red.shade50,
                      child: Text("Error: $_errorMessage", style: const TextStyle(color: Colors.red)),
                    )
                  else if (_apiResult != null)
                      if (_apiResult is List)
                        ...(_apiResult as List).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ProductSearchResult(data: item as Map<String, dynamic>),
                        ))
                      else if (_apiResult is Map<String, dynamic>)
                        ProductSearchResult(data: _apiResult as Map<String, dynamic>)
                ],
              ),
            ),
          ),
        ),

        // Footer Search Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface.withOpacity(0.2),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                blurRadius: 3,
                offset: const Offset(0, -5),
              )
            ],
          ),
          // RESPONSIVE FIX: Center and constrain the footer search bar too
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: HomeSearch(
                showSendButton: true,
                searchHint: "Search again...",
                controller: _device1Controller,
                isCompact: true,
                onSearch: (model) => _performSearch('detailed'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}