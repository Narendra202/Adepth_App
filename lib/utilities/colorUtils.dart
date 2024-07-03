import 'package:flutter/material.dart';

class ColorUtils {
  static const Color primaryColor = Color(0xff673AB7);
  static const Color primaryColorLight = Color(0xffF0EBF8);
  static const Color secondaryColor = Color(0xff4081EC);
  static MaterialColor primarySwatch =
      MaterialColor(primaryColor.value, <int, Color>{
    50: primaryColor.withOpacity(0.1),
    100: primaryColor.withOpacity(0.2),
    200: primaryColor.withOpacity(0.3),
    300: primaryColor.withOpacity(0.4),
    400: primaryColor.withOpacity(0.5),
    500: primaryColor.withOpacity(0.6),
    600: primaryColor.withOpacity(0.7),
    700: primaryColor.withOpacity(0.8),
    800: primaryColor.withOpacity(0.9),
    900: primaryColor,
  });

  static const Color kErrorRed = Colors.redAccent;
  static const Color kDarkGray = Color(0xFFA3A3A3);
  static const Color kLightGray = Color(0xFFF1F0F5);
  static const Color pearlWhite = Color(0xffDFFFFF);
  static const Color toolChip = Color(0xffC8E6C9);
  static const Color platformChip = Color(0xff80CBC4);
  static const Color headingCard = Color(0xffCFD8DC);
  static const Color textButtonSelected = Color(0xff388E3C);

  static const Color diveColor = Color(0xff795548);
  static const Color sampleColor = Color(0xffEF6C00);
  static const Color analysisColor = Color(0xff283593);

  // bottom navigation bar
  static const Color homeBar = secondaryColor;
  static const Color configBar = secondaryColor;
  static const Color diveBar = secondaryColor;
  static const Color dataBar = secondaryColor;
}
