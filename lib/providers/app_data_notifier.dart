import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../database.dart';

class AppDataNotifier with ChangeNotifier {
  final AppDatabase database;
  int _pendingOrderCount = 0;
  DateTime? _lastClientSync;
  DateTime? _lastProductSync;
  DateTime? _lastEnderecoSync;
  bool _isSyncing = false;
  bool _isSyncCancelled = false;
  double _syncProgress = 0.0;
  String _syncMessage = '';

  Timer? _syncTimer;

  AppDataNotifier(this.database) {
    updatePendingOrderCount();
    _loadSyncDates();
    _startAutoSyncTimer();
  }

  // Getters
  int get pendingOrderCount => _pendingOrderCount;
  DateTime? get lastClientSync => _lastClientSync;
  DateTime? get lastProductSync => _lastProductSync;
  DateTime? get lastEnderecoSync => _lastEnderecoSync;
  bool get isSyncing => _isSyncing;
  double get syncProgress => _syncProgress;
  String get syncMessage => _syncMessage;

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  void _startAutoSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      debugPrint("--- Disparando sincronização automática horária ---");
      syncClientesFromAPI();
      syncProdutosFromAPI();
      syncEnderecosFromAPI();
    });
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
  
  void cancelSync() {
    if (_isSyncing) {
      _isSyncCancelled = true;
      debugPrint("--- Solicitação de cancelamento de sincronização recebida ---");
    }
  }

  Future<bool> syncClientesFromAPI() async {
    if (_isSyncing) return false;
    
    _isSyncing = true;
    _isSyncCancelled = false;
    _syncProgress = 0.0;
    _syncMessage = "A iniciar sincronização de clientes...";
    notifyListeners();

    try {
      final List<Map<String, dynamic>> allData = [];
      int skip = 0;
      const int batchSize = 2048;
      const int totalApprox = 160000;

      while (true) {
        if (_isSyncCancelled) throw Exception("Sincronização cancelada pelo utilizador.");

        _syncMessage = "A buscar clientes... (${allData.length}/~$totalApprox)";
        _syncProgress = allData.length / totalApprox;
        notifyListeners();

        final List<dynamic>? batch = await ApiService.getBaseData('clientes', skip);

        if (batch == null) throw Exception("Falha ao buscar dados da API.");
        
        allData.addAll(batch.cast<Map<String, dynamic>>());

        if (batch.length < batchSize) break;
        skip += batchSize;
      }
      
      _syncMessage = "A processar e guardar ${allData.length} clientes na base de dados...";
      notifyListeners();

      if (!_isSyncCancelled) {
        await database.populateClientesFromAPI(allData);
        final now = DateTime.now();
        _lastClientSync = now;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastClientSync', now.millisecondsSinceEpoch);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erro durante a sincronização de clientes: $e");
      return false;
    } finally {
      _isSyncing = false;
      _syncMessage = '';
      _syncProgress = 0.0;
      notifyListeners();
    }
  }
  
  Future<bool> syncProdutosFromAPI() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    _isSyncCancelled = false;
    _syncProgress = 0.0;
    _syncMessage = "A iniciar sincronização de produtos...";
    notifyListeners();
    
    try {
      final List<Map<String, dynamic>> allData = [];
      int skip = 0;
      const int batchSize = 2048;
      const int totalApprox = 20000;

      while (true) {
        if (_isSyncCancelled) throw Exception("Sincronização cancelada pelo utilizador.");

        _syncMessage = "A buscar produtos... (${allData.length}/~$totalApprox)";
        _syncProgress = allData.length / totalApprox;
        notifyListeners();

        final List<dynamic>? batch = await ApiService.getBaseData('produtos', skip);
        if (batch == null) throw Exception("Falha ao buscar dados da API.");

        allData.addAll(batch.cast<Map<String, dynamic>>());

        if (batch.length < batchSize) break;
        skip += batchSize;
      }
      
      _syncMessage = "A processar e guardar ${allData.length} produtos...";
      notifyListeners();

      if (!_isSyncCancelled) {
        await database.populateProdutosFromAPI(allData);
        final now = DateTime.now();
        _lastProductSync = now;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastProductSync', now.millisecondsSinceEpoch);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erro durante a sincronização de produtos: $e");
      return false;
    } finally {
      _isSyncing = false;
      _syncMessage = '';
      _syncProgress = 0.0;
      notifyListeners();
    }
  }

  Future<bool> syncEnderecosFromAPI() async {
    if (_isSyncing) return false;

    _isSyncing = true;
    _isSyncCancelled = false;
    _syncProgress = 0.0;
    _syncMessage = "A iniciar sincronização de endereços...";
    notifyListeners();

    try {
      final List<Map<String, dynamic>> allData = [];
      int skip = 0;
      const int batchSize = 2048;
      const int totalApprox = 100000;

      while (true) {
        if (_isSyncCancelled) throw Exception("Sincronização cancelada pelo utilizador.");

        _syncMessage = "A buscar endereços... (${allData.length}/~$totalApprox)";
        _syncProgress = allData.length / totalApprox;
        notifyListeners();
        
        final List<dynamic>? batch = await ApiService.getBaseData('enderecos', skip);
        if (batch == null) throw Exception("Falha ao buscar dados da API.");
        
        allData.addAll(batch.cast<Map<String, dynamic>>());

        if (batch.length < batchSize) break;
        skip += batchSize;
      }
      
      _syncMessage = "A processar e guardar ${allData.length} endereços...";
      notifyListeners();

      if (!_isSyncCancelled) {
        await database.populateEnderecosFromAPI(allData);
        final now = DateTime.now();
        _lastEnderecoSync = now;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastEnderecoSync', now.millisecondsSinceEpoch);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erro durante a sincronização de endereços: $e");
      return false;
    } finally {
      _isSyncing = false;
      _syncMessage = '';
      _syncProgress = 0.0;
      notifyListeners();
    }
  }

  Future<void> updatePendingOrderCount() async {
    _pendingOrderCount = await database.countPedidosPendentes();
    notifyListeners();
  }
}

