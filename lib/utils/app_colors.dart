import 'package:flutter/material.dart';

class AppColors {
  // Main Colors
  static const Color iconColor = Color(0xFF407691); //Icons
  static const Color drawerBackground = Color(0xFF2C3133); //Drawer Background
  static const Color buttonBackground = Color(0xFF2E373C); //button Background
  static const Color backGround= Color(0xFF0f1e45);
  // Brand & Main Blues
  static const Color primaryBlue = Color(0xFF3B72FF);
  static const Color secondaryBlue = Color(0xFFB0C7F1);
  static const Color brandBlue = Color(0xFF4D8BFF);

  // Backgrounds & Surfaces
  static const Color mainBackground = Color(0xFF020818);
  static const Color secondarySurface = Color(0xFF081232);
  static const Color dropdownSurface = Color(0xFF0A1230);

  // Custom transparent backgrounds for specific components
  static final Color sidebarBackground = const Color(0xFF020818).withOpacity(0.80);
  static final Color searchBarBackground = const Color(0xFF081232).withOpacity(0.85);

  // Typography
  static const Color primaryText = Color(0xFFE2E8F0);
  static const Color secondaryText = Color(0xFFC7D8FF);

  // Status & Accents
  static const Color successGreen = Color(0xFF34D399);
  static const Color warningAccent = Color(0xFFF59E0B);

  // Borders
  static final Color whiteBorderThin = Colors.white.withOpacity(0.06);
  static final Color whiteBorderThinner = Colors.white.withOpacity(0.05);
  static final Color blueBorderThin = const Color(0xFF4D8BFF).withOpacity(0.20);

  // Background Glow Layers
  static final Color glowLayer1 = const Color(0xFF0F3CB4);
  static final Color glowLayer2 = const Color(0xFF1E50DC).withOpacity(0.17);

  // Interactive Elements (Buttons & Menus)
  static const Color buttonHover = Color(0xFF4D80FF);
  static final Color buttonGlowShadow = const Color(0xFF3B72FF).withOpacity(0.40);
  static final Color menuHover = Colors.white.withOpacity(0.80);
  static final Color menuActiveBackground = const Color(0xFF3B72FF).withOpacity(0.10);

}