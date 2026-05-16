import 'package:flutter/material.dart';

/// Convenience extensions
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
}

extension ColorExtensions on Color {
  Color withGlow([double opacity = 0.5]) => withValues(alpha: opacity);
}

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
