import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.directional(start: 20, top: 20),
            child: Text(
              "Hello Username",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
          ),
        ],
      ),
    );
  }
}
