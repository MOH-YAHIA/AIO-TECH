import 'package:aio_tech/main.dart';
import 'package:aio_tech/utils/app_colors.dart';
import 'package:flutter/material.dart';

import '../Screens/home_screen.dart';

class EmptyWatchList extends StatelessWidget {
  const EmptyWatchList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(20),child:
    Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Center(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, color: Colors.grey, size: 40),
              Text(
                "Track prices and get notified of deals across Egypt.",
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xAA2C3133),
                ),
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainWrapper()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Text("Start Searching",),
              ),
            ],
          ),
        ),
      ),
    ),
    );

  }
}
