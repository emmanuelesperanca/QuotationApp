import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeNotifier with ChangeNotifier {
  String _currentThemeId = 'straumann_classic';
  bool _isInitialized = false;

  ThemeNotifier() {
    _loadTheme();
  }

  String get currentThemeId => _currentThemeId;
  AppTheme get currentTheme => availableThemes.firstWhere((t) => t.id == _currentThemeId);
  bool get isInitialized => _isInitialized;

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeId = prefs.getString('themeId') ?? 'straumann_classic';
      
      // Só notifica se o tema realmente mudou
      if (_currentThemeId != savedThemeId) {
        _currentThemeId = savedThemeId;
      }
      
      _isInitialized = true;
      notifyListeners(); // Notificação direta para inicialização
      
    } catch (e) {
      // Se houver erro, usa o tema padrão
      _currentThemeId = 'straumann_classic';
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> updateTheme(String themeId) async {
    if (_currentThemeId == themeId) return; // Evita mudanças desnecessárias
    
    // Muda imediatamente para responsividade
    _currentThemeId = themeId;
    notifyListeners(); // Notifica imediatamente
    
    // Salva em background
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeId', themeId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao salvar tema: $e');
      }
    }
  }
}
