import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<String> _favoriteCampaigns = <String>{};
  static const String _favoritesKey = 'favorite_campaigns';

  Set<String> get favoriteCampaigns => _favoriteCampaigns;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      _favoriteCampaigns = favorites.toSet();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar favoritos: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteCampaigns.toList());
    } catch (e) {
      debugPrint('Erro ao salvar favoritos: $e');
    }
  }

  bool isFavorite(String promocode) {
    return _favoriteCampaigns.contains(promocode);
  }

  Future<void> toggleFavorite(String promocode) async {
    if (_favoriteCampaigns.contains(promocode)) {
      _favoriteCampaigns.remove(promocode);
    } else {
      _favoriteCampaigns.add(promocode);
    }
    
    notifyListeners();
    await _saveFavorites();
  }

  List<String> getFavoritesList() {
    return _favoriteCampaigns.toList();
  }

  void clearAllFavorites() async {
    _favoriteCampaigns.clear();
    notifyListeners();
    await _saveFavorites();
  }
}
