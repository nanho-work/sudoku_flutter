import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/palette.dart';

class ThemeController extends ChangeNotifier {
  static const _themeKey = 'selected_theme';
  String _currentTheme = 'light';
  String get currentTheme => _currentTheme;

  AppColorPalette get colors {
    switch (_currentTheme) {
      case 'dark': return const DarkAppColors();
      case 'pink': return const PinkAppColors();
      default: return const LightAppColors();
    }
  }

  Brightness get brightness =>
      _currentTheme == 'dark' ? Brightness.dark : Brightness.light;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = prefs.getString(_themeKey) ?? 'light';
    notifyListeners();
  }

  Future<void> setTheme(String themeName) async {
    _currentTheme = themeName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeName);
    notifyListeners();
  }

  bool isCurrent(String themeName) => _currentTheme == themeName;
}