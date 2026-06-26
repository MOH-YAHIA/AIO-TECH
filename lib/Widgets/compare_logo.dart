import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

// This is the animated compare logo widget to be used in your Search home.
class CompareLogo extends StatefulWidget {
  const CompareLogo({super.key});

  @override
  State<CompareLogo> createState() => _CompareLogoState();
}

class _CompareLogoState extends State<CompareLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the controller with a duration of 1.5 seconds.
    // Setting repeat with reverse: true creates a smooth back-and-forth loop.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Apply a curved animation for a more natural ease-in and ease-out effect.
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    // Always dispose the controller to prevent memory leaks when the widget is removed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate the distance the arrows will travel.
        // Multiplying the animation value (0.0 to 1.0) by 15 means a max movement of 15 pixels.
        final double slideOffset = _animation.value * 15.0;

        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.transparent, // Dark charcoal from your palette
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF19A1E6,
                ).withOpacity(0.1), // Glowing electric blue
                blurRadius: 8,
                spreadRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Top arrow: Moves horizontally to the right
              Transform.translate(
                offset: Offset(slideOffset - 7.5, -25),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.blueAccent,
                  size: 70,
                ),
              ),
              // Bottom arrow: Moves horizontally to the left
              Transform.translate(
                offset: Offset(-slideOffset + 7.5, 25),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.successGreen,
                  size: 70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
