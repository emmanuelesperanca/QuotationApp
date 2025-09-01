import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';

class AppDataNotifier with ChangeNotifier {
  final AppDatabase database;
  int _pendingOrderCount = 0;
  DateTime? _lastClientSync;
  DateTime? _lastProductSync;
  DateTime? _lastEnderecoSync; // ADICIONADO
  bool _isSyncing = false;

  AppDataNotifier(this.database) {
    updatePendingOrderCount();
    _loadSyncDates();
  }

  int get pendingOrderCount => _pendingOrderCount;
  DateTime? get lastClientSync => _lastClientSync;
  DateTime? get lastProductSync => _lastProductSync;
  DateTime? get lastEnderecoSync => _lastEnderecoSync; // ADICIONADO
  bool get isSyncing => _isSyncing;

  Future<void> _loadSyncDates() async {
    final prefs = await SharedPreferences.getInstance();
    final clientMillis = prefs.getInt('lastClientSync');
    if (clientMillis != null) {
      _lastClientSync = DateTime.fromMillisecondsSinceEpoch(clientMillis);
    }
    final productMillis = prefs.getInt('lastProductSync');
    if (productMillis != null) {
      _lastProductSync = DateTime.fromMillisecondsSinceEpoch(productMillis);
    }
    // ADICIONADO
    final enderecoMillis = prefs.getInt('lastEnderecoSync');
    if (enderecoMillis != null) {
      _lastEnderecoSync = DateTime.fromMillisecondsSinceEpoch(enderecoMillis);
    }
    notifyListeners();
  }

  Future<bool> syncClientesFromCsv() async {
    _isSyncing = true;
    notifyListeners();
    try {
      await database.populateClientesFromCsv();
      final now = DateTime.now();
      _lastClientSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastClientSync', now.millisecondsSinceEpoch);
      return true;
    } catch (e) {
      debugPrint("Erro ao carregar clientes do CSV: $e");
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  Future<bool> syncProdutosFromCsv() async {
    _isSyncing = true;
    notifyListeners();
    try {
      await database.populateProdutosFromCsv();
      final now = DateTime.now();
      _lastProductSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastProductSync', now.millisecondsSinceEpoch);
      return true;
    } catch (e) {
      debugPrint("Erro ao carregar produtos do CSV: $e");
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // ADICIONADO: Nova função para sincronizar os endereços
  Future<bool> syncEnderecosFromCsv() async {
    _isSyncing = true;
    notifyListeners();
    try {
      await database.populateEnderecosFromCsv();
      final now = DateTime.now();
      _lastEnderecoSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastEnderecoSync', now.millisecondsSinceEpoch);
      return true;
    } catch (e) {
      debugPrint("Erro ao carregar endereços do CSV: $e");
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> updatePendingOrderCount() async {
    _pendingOrderCount = await database.countPedidosPendentes();
    notifyListeners();
  }
}
