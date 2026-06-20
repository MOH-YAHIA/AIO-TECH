import 'package:aio_tech/Widgets/home_search.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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

  // Track if the user has triggered a search
  bool _hasSearched = false;
  String _lastQuery = "";


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

  void _performSearch() {
    setState(() {
      _hasSearched = true;
      _lastQuery = _device1Controller.text;
      _device1Controller.clear();
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

  // Initial layout with big centered search bar
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
          onSearch: _performSearch,
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
        // 1. Add the New Chat button at the top of the results view
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: NewChat(
              onPressed: () {
                setState(() {
                  _hasSearched = false;
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
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.grey.shade200,
                child: const Text("Product Result UI Goes Here"),
              )
            ],
          ),
        ),

        // Footer Search Box
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
            isCompact: true, // Shrinks the height!
            onSearch: _performSearch,
          ),
        ),
      ],
    );
  }
}