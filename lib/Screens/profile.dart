import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class Profile extends StatefulWidget {
  const Profile({super.key,required this.onBackPressed});
  final VoidCallback onBackPressed;
  @override
  State<Profile> createState() => _ProfileState();
}

final AuthService _authService = AuthService();

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            widget.onBackPressed();
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
      ),
      body: Center(
        child: FutureBuilder<String?>(
          future: _authService.getFullName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                "Loading...",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey,
                ),
              );
            }
            return Text(
              snapshot.data ?? "Guest",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 70,
                color: Colors.black,
              ),
            );
          },
        ),
      ),
    );
  }
}
