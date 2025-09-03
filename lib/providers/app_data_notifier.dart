import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';

class AppDataNotifier with ChangeNotifier {
  final AppDatabase database;
  int _pendingOrderCount = 0;
  DateTime? _lastClientSync;
  DateTime? _lastProductSync;
  DateTime? _lastEnderecoSync;
  bool _isSyncing = false;
  String _syncMessage = '';
  Timer? _syncTimer;

  AppDataNotifier(this.database) {
    updatePendingOrderCount();
    _loadSyncDates();
    _startAutoSyncTimer();
  }

  int get pendingOrderCount => _pendingOrderCount;
  DateTime? get lastClientSync => _lastClientSync;
  DateTime? get lastProductSync => _lastProductSync;
  DateTime? get lastEnderecoSync => _lastEnderecoSync;
  bool get isSyncing => _isSyncing;
  String get syncMessage => _syncMessage;

  void _startAutoSyncTimer() {
    // A cada hora, aciona a sincronização de todas as bases
    _syncTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      debugPrint("--- Acionando sincronização automática horária ---");
      syncAllBasesSilently();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

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
    final enderecoMillis = prefs.getInt('lastEnderecoSync');
    if (enderecoMillis != null) {
      _lastEnderecoSync = DateTime.fromMillisecondsSinceEpoch(enderecoMillis);
    }
    notifyListeners();
  }
  
  void _updateSyncMessage(String message) {
    _syncMessage = message;
    notifyListeners();
  }

  Future<bool> syncClientesOnline({bool silent = false}) async {
    if (!silent) {
      _isSyncing = true;
      _updateSyncMessage('A iniciar sincronização de clientes...');
    }
    try {
      void updateCallback(int count) {
        if (!silent) _updateSyncMessage('Clientes sincronizados: $count');
      }
      await database.populateClientesFromAPI(updateCallback);
      final now = DateTime.now();
      _lastClientSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastClientSync', now.millisecondsSinceEpoch);
      return true;
    } catch (e) {
      debugPrint("Erro ao sincronizar clientes online: $e");
      return false;
    } finally {
      if (!silent) {
        _isSyncing = false;
        _updateSyncMessage('');
      }
    }
  }

  Future<bool> syncProdutosOnline({bool silent = false}) async {
    if (!silent) {
      _isSyncing = true;
      _updateSyncMessage('A iniciar sincronização de produtos...');
    }
    try {
      void updateCallback(int count) {
        if (!silent) _updateSyncMessage('Produtos sincronizados: $count');
      }
      await database.populateProdutosFromAPI(updateCallback);
      final now = DateTime.now();
      _lastProductSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastProductSync', now.millisecondsSinceEpoch);
      return true;
    } catch (e) {
      debugPrint("Erro ao sincronizar produtos online: $e");
      return false;
    } finally {
      if (!silent) {
        _isSyncing = false;
        _updateSyncMessage('');
      }
    }
  }

  Future<bool> syncEnderecosOnline({bool silent = false}) async {
    if (!silent) {
      _isSyncing = true;
      _updateSyncMessage('A iniciar sincronização de endereços...');
    }
    try {
      void updateCallback(int count) {
        if (!silent) _updateSyncMessage('Endereços sincronizados: $count');
      }
      await database.populateEnderecosFromAPI(updateCallback);
      final now = DateTime.now();
      _lastEnderecoSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastEnderecoSync', now.millisecondsSinceEpoch);
      return true;
    } catch (e) {
      debugPrint("Erro ao sincronizar endereços online: $e");
      return false;
    } finally {
      if (!silent) {
        _isSyncing = false;
        _updateSyncMessage('');
      }
    }
  }

  Future<void> syncAllBasesSilently() async {
    debugPrint("Sincronizando clientes silenciosamente...");
    await syncClientesOnline(silent: true);
    debugPrint("Sincronizando produtos silenciosamente...");
    await syncProdutosOnline(silent: true);
    debugPrint("Sincronizando endereços silenciosamente...");
    await syncEnderecosOnline(silent: true);
    debugPrint("Sincronização silenciosa concluída.");
  }


  Future<void> updatePendingOrderCount() async {
    _pendingOrderCount = await database.countPedidosPendentes();
    notifyListeners();
  }
}

