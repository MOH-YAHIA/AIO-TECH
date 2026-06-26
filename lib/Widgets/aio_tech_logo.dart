import 'package:aio_tech/utils/app_colors.dart';
import 'package:flutter/material.dart';

// A customizable logo widget for AIOTech
class AIOTechLogo extends StatelessWidget {
  final double fontSize;

  const AIOTechLogo({super.key, this.fontSize = 32.0});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // AI Sparkle Icon Container
        Container(
          padding: EdgeInsets.all(fontSize * 0.25),
          decoration: BoxDecoration(
            color: AppColors.secondarySurface, // Dark charcoal from your palette
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF19A1E6).withOpacity(0.4), // Glowing electric blue
                blurRadius: 8,
                spreadRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [

              // Text Typography
              Text.rich(

                TextSpan(
                  children: [
                    TextSpan(
                      text: 'AIO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900, // Heavy weight for stable foundation
                        fontSize: fontSize,
                        letterSpacing: 3,
                      ),
                    ),
                    TextSpan(
                      text: 'Tech',
                      style: TextStyle(
                        color: const Color(0xFF19A1E6), // Electric Blue
                        fontWeight: FontWeight.w300, // Light weight for modern tech feel
                        fontSize: fontSize,
                        letterSpacing: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(width: fontSize * 0.4),

      ],
    );
  }
}