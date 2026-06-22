import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mostrador_au/config/config.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme());

  void setColor(int index) => state = state.copyWith(selectedColor: index);
  void toggleDarkMode() => state = state.copyWith(isDarkMode: !state.isDarkMode);
}
