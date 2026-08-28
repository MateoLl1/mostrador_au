import 'package:flutter/material.dart';

const colorList = <Color>[
  Color(0xFF2196F3), // Blue
  Color(0xFF4CAF50), // Green
  Color(0xFF9C27B0), // Purple
  Color(0xFFF44336), // Red
  Color(0xFFFF9800), // Orange
  Color(0xFF00BCD4), // Cyan
  Color(0xFFE91E63), // Pink
];

class AppTheme {
  final int selectedColor;
  final bool isDarkMode;

  const AppTheme({
    this.selectedColor = 0,
    this.isDarkMode = false,
  }) : assert(selectedColor >= 0 && selectedColor < colorList.length);

  ThemeData theme() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorList[selectedColor],
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
      );

  AppTheme copyWith({int? selectedColor, bool? isDarkMode}) => AppTheme(
        selectedColor: selectedColor ?? this.selectedColor,
        isDarkMode: isDarkMode ?? this.isDarkMode,
      );
}
