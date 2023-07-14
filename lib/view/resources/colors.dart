import 'package:flutter/material.dart';

class AppColors {
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  static MaterialColor primaryColor = createMaterialColor(Color(0xff722cce));
  static Color defaultPrimaryColor = Color(0xff722cce);
  static Color listDividerColor = Color.fromRGBO(255, 255, 255, 0.359);
  static Color descriptionDividerColor = Colors.white;
  static Color darkBackground = Color.fromRGBO(22, 22, 34, 1);
  static Color accentBackground = Color.fromRGBO(39, 39, 54, 1.0);
}
