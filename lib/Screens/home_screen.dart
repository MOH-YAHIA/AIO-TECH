import 'dart:async';
import 'package:aio_tech/Widgets/home_search.dart';
import 'package:aio_tech/Widgets/product_search_result.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_services.dart';
import '../Widgets/star_logo.dart';
import '../services/product_service.dart';
import '../Widgets/new_chat.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final String? initialQuery;
  final int searchTriggerId;

  const HomeScreen({
    super.key,
    this.initialQuery,
    this.searchTriggerId = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _device1Controller = TextEditingController();
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  bool _hasSearched = false;
  bool _isLoading = false;
  String _lastQuery = "";

  dynamic _apiResult;
  String _errorMessage = "";

  // --- Loading state feedback ---
  int _elapsedSeconds = 0;
  Timer? _loadingTimer;

  static const List<String> _loadingMessages = [
    "Connecting to server...",
    "Waking up the AI engine...",
    "Routing your query...",
    "Scanning the market...",
    "Analyzing products...",
    "Almost there, hang tight...",
    "Still working, the server is busy...",
    "Fetching the best results for you...",
  ];

  String get _currentLoadingMessage {
    final index = (_elapsedSeconds ~/ 5).clamp(0, _loadingMessages.length - 1);
    return _loadingMessages[index];
  }

  @override
  void initState() {
    super.initState();
    _device1Controller.addListener(_updateButtonState);
    // Check for query passed immediately on creation
    if (widget.initialQuery != null && widget.searchTriggerId > 0) {
      _checkInitialQuery();
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Listen for incoming searches when this screen is already mounted (from Drawer)
    if (widget.searchTriggerId != oldWidget.searchTriggerId && widget.initialQuery != null) {
      _checkInitialQuery();
    }
  }

  void _checkInitialQuery() {
    if (widget.initialQuery!.isNotEmpty) {
      _device1Controller.text = widget.initialQuery!;
      // Wait for the UI frame to build, then perform the search automatically
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _performSearch();
        }
      });
    }
  }

  void _updateButtonState() {
    setState(() {});
  }

  @override
  void dispose() {
    _device1Controller.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _startLoadingTimer() {
    _elapsedSeconds = 0;
    _loadingTimer?.cancel();
    _loadingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
    _elapsedSeconds = 0;
  }

  Future<void> _performSearch() async {
    final int userId = await _authService.getUserId();

    setState(() {
      _hasSearched = true;
      _isLoading = true;
      _errorMessage = "";
      _lastQuery = _device1Controller.text;
      _device1Controller.clear();
    });

    _startLoadingTimer();

    final result = await _productService.dispatchSearch(
      query: _lastQuery,
      userId: userId,
    );

    _stopLoadingTimer();

    setState(() {
      _isLoading = false;
      if (result['success']) {
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
          "Smart Market Radar",
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
                tr('welcome home'),
                textStyle: const TextStyle(fontSize: 18, color: AppColors.primaryText),
                textAlign: TextAlign.center,
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 3,
            displayFullTextOnTap: true,
            pause: const Duration(milliseconds: 0),
          ),
        ),
        const SizedBox(height: 60),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: HomeSearch(
              showSendButton: true,
              searchHint: tr('search home'),
              controller: _device1Controller,
              onSearch: _performSearch,
            ),
          ),
        ),
        const SizedBox(height: 40),
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
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // User query bubble
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
                    _buildLoadingState()
                  else if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_apiResult != null)
                      if (_apiResult is List)
                        ...(_apiResult as List).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ProductSearchResult(
                              data: item as Map<String, dynamic>),
                        ))
                      else if (_apiResult is Map<String, dynamic>)
                        ProductSearchResult(
                            data: _apiResult as Map<String, dynamic>),
                ],
              ),
            ),
          ),
        ),

        // Footer search bar
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: HomeSearch(
                showSendButton: true,
                searchHint: "Search again...",
                controller: _device1Controller,
                isCompact: true,
                onSearch: _performSearch,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _currentLoadingMessage,
              key: ValueKey(_currentLoadingMessage),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_elapsedSeconds}s",
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryText.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}