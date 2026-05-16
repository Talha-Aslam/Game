import 'package:flutter/material.dart';

/// Responsive sizing utility for phones, tablets, and foldables
class Responsive {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  /// Returns value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// Player card size based on screen
  static double playerCardSize(BuildContext context) {
    return value(context, mobile: 70.0, tablet: 85.0, desktop: 100.0);
  }

  /// Circle radius for player layout
  static double playerCircleRadius(BuildContext context) {
    final w = screenWidth(context);
    final h = screenHeight(context);
    final minDim = w < h ? w : h;
    return value(context, mobile: minDim * 0.32, tablet: minDim * 0.3);
  }

  /// Game timer font size
  static double timerFontSize(BuildContext context) {
    return value(context, mobile: 48.0, tablet: 56.0, desktop: 64.0);
  }

  /// Horizontal padding
  static double horizontalPadding(BuildContext context) {
    return value(context, mobile: 16.0, tablet: 32.0, desktop: 48.0);
  }
}
