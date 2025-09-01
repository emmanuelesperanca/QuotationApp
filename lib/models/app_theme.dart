import 'package:flutter/material.dart';

class AppTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final String mainBgAsset;
  final String innerBgAsset;
  final Brightness brightness;

  AppTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.mainBgAsset,
    required this.innerBgAsset,
    required this.brightness,
  });
}

// --- LISTA DE TEMAS DISPONÍVEIS ---
final List<AppTheme> availableThemes = [
  AppTheme(
    id: 'straumann_classic',
    name: 'Straumann Classic',
    primaryColor: const Color(0xFF003D7D),
    secondaryColor: const Color(0xFF00A3E0),
    mainBgAsset: 'assets/images/straumann_main.jpg',
    innerBgAsset: 'assets/images/straumann_inner.jpg',
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'neodent_purple',
    name: 'Neodent Purple',
    primaryColor: const Color(0xFF5E2750),
    secondaryColor: const Color(0xFF9C4D8B),
    mainBgAsset: 'assets/images/neodent_main.jpg',
    innerBgAsset: 'assets/images/neodent_inner.jpg',
    brightness: Brightness.dark,
  ),
  AppTheme(
    id: 'clear_correct',
    name: 'ClearCorrect Blue',
    primaryColor: const Color(0xFF009FE3),
    secondaryColor: const Color(0xFF7DD8F3),
    mainBgAsset: 'assets/images/clearcorrect_main.jpg',
    innerBgAsset: 'assets/images/clearcorrect_inner.jpg',
    brightness: Brightness.light,
  ),
  // ATUALIZADO: Novo tema adicionado
  AppTheme(
    id: 'straumann_green',
    name: 'Straumann Green',
    primaryColor: const Color(0xFF2D7662),
    secondaryColor: const Color(0xFF46B98C),
    mainBgAsset: 'assets/images/straumann_green_main.jpg',
    innerBgAsset: 'assets/images/straumann_green_inner.jpg',
    brightness: Brightness.dark,
  ),
];
