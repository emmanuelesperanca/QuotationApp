import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeNotifier with ChangeNotifier {
  String _currentThemeId = 'straumann_classic';

  ThemeNotifier() {
    _loadTheme();
  }

  String get currentThemeId => _currentThemeId;
  AppTheme get currentTheme => availableThemes.firstWhere((t) => t.id == _currentThemeId);

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _currentThemeId = prefs.getString('themeId') ?? 'straumann_classic';
    notifyListeners();
  }

  Future<void> updateTheme(String themeId) async {
    _currentThemeId = themeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeId', themeId);
    notifyListeners();
  }
}
