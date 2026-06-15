import 'package:aio_tech/Widgets/home_search.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _device1Controller = TextEditingController();
  final TextEditingController _device2Controller = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final bool isButtonEnabled = _device1Controller.text.trim().isNotEmpty &&
        _device2Controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.all(10),
          children: [
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
              searchHint: "Device 1",
              controller: _device1Controller,
            ),
            const SizedBox(height: 40),
            HomeSearch(
              searchHint: "Device 2",
              controller: _device2Controller,
            ),
            const SizedBox(height: 60),

            SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                onPressed: isButtonEnabled
                    ? () {
                  debugPrint("Comparing ${_device1Controller.text} and ${_device2Controller.text}");
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled
                      ? AppColors.buttonBackground
                      : Colors.grey.shade400,
                ),
                child: const Text("Compare", style: TextStyle(color: Colors.white)),
              ),
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
        ),
      ),
    );
  }
}