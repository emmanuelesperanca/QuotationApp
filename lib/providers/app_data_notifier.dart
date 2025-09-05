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
  DateTime? _lastCategoriaSync;
  bool _isSyncing = false;
  bool _cancelSync = false;
  String _syncMessage = '';
  double _syncProgress = 0.0;

  // Valores totais aproximados para a barra de progresso
  final int _totalClientesAprox = 160000;
  final int _totalProdutosAprox = 20000;
  final int _totalEnderecosAprox = 100000;
  final int _totalCategoriasAprox = 50000;


  AppDataNotifier(this.database) {
    updatePendingOrderCount();
    _loadSyncDates();
    // Inicia a sincronização automática em segundo plano
    Timer.periodic(const Duration(hours: 1), (timer) {
      if (!_isSyncing) {
        syncAllBasesSilently();
      }
    });
  }

  // Getters
  int get pendingOrderCount => _pendingOrderCount;
  DateTime? get lastClientSync => _lastClientSync;
  DateTime? get lastProductSync => _lastProductSync;
  DateTime? get lastEnderecoSync => _lastEnderecoSync;
  DateTime? get lastCategoriaSync => _lastCategoriaSync;
  bool get isSyncing => _isSyncing;
  String get syncMessage => _syncMessage;
  double get syncProgress => _syncProgress;

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
    final categoriaMillis = prefs.getInt('lastCategoriaSync');
    if (categoriaMillis != null) {
      _lastCategoriaSync = DateTime.fromMillisecondsSinceEpoch(categoriaMillis);
    }
    notifyListeners();
  }
  
  void cancelSync() {
    _cancelSync = true;
    _syncMessage = 'Sincronização cancelada...';
    notifyListeners();
  }

  // --- LÓGICA DE SINCRONIZAÇÃO DE CLIENTES ---
  Future<bool> syncClientesFromAPI() async {
    _isSyncing = true;
    _cancelSync = false;
    _syncProgress = 0.0;
    _syncMessage = 'A iniciar sincronização de clientes...';
    notifyListeners();

    await database.apagarTodosClientes();
    
    int totalRecebido = 0;
    bool sucesso = true;
    
    while (true) {
      if (_cancelSync) {
        sucesso = false;
        break;
      }
      
      _syncMessage = 'A buscar clientes... ($totalRecebido / ~$_totalClientesAprox)';
      notifyListeners();

      final batch = await ApiService.getBaseData('clientes', skip: totalRecebido);

      if (batch == null) {
        sucesso = false;
        break;
      }
      
      await database.populateClientesFromAPI(batch);
      
      totalRecebido += batch.length;
      _syncProgress = (totalRecebido / _totalClientesAprox).clamp(0.0, 1.0);
      notifyListeners();
      
      if (batch.length < 2000) break;
    }

    if (sucesso) {
      final now = DateTime.now();
      _lastClientSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastClientSync', now.millisecondsSinceEpoch);
      _syncMessage = 'Sincronização de clientes concluída!';
    } else {
      _syncMessage = _cancelSync ? 'Sincronização de clientes cancelada.' : 'Erro ao sincronizar clientes.';
    }

    _isSyncing = false;
    _cancelSync = false;
    notifyListeners();
    return sucesso;
  }
  
  // --- LÓGICA DE SINCRONIZAÇÃO DE PRODUTOS ---
  Future<bool> syncProdutosFromAPI() async {
     _isSyncing = true;
    _cancelSync = false;
    _syncProgress = 0.0;
    _syncMessage = 'A iniciar sincronização de produtos...';
    notifyListeners();

    await database.apagarTodosProdutos();
    
    int totalRecebido = 0;
    bool sucesso = true;
    
    while (true) {
      if (_cancelSync) {
        sucesso = false;
        break;
      }

      _syncMessage = 'A buscar produtos... ($totalRecebido / ~$_totalProdutosAprox)';
      notifyListeners();

      final batch = await ApiService.getBaseData('produtos', skip: totalRecebido);

      if (batch == null) {
        sucesso = false;
        break;
      }

      await database.populateProdutosFromAPI(batch);

      totalRecebido += batch.length;
       _syncProgress = (totalRecebido / _totalProdutosAprox).clamp(0.0, 1.0);
      notifyListeners();

      if (batch.length < 2000) break;
    }

    if (sucesso) {
      final now = DateTime.now();
      _lastProductSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastProductSync', now.millisecondsSinceEpoch);
      _syncMessage = 'Sincronização de produtos concluída!';
    } else {
       _syncMessage = _cancelSync ? 'Sincronização de produtos cancelada.' : 'Erro ao sincronizar produtos.';
    }

    _isSyncing = false;
    _cancelSync = false;
    notifyListeners();
    return sucesso;
  }

  // --- LÓGICA DE SINCRONIZAÇÃO DE ENDEREÇOS ---
  Future<bool> syncEnderecosFromAPI() async {
     _isSyncing = true;
    _cancelSync = false;
    _syncProgress = 0.0;
    _syncMessage = 'A iniciar sincronização de endereços...';
    notifyListeners();

    await database.apagarTodosEnderecos();
    
    int totalRecebido = 0;
    bool sucesso = true;
    
    while (true) {
      if (_cancelSync) {
        sucesso = false;
        break;
      }
      _syncMessage = 'A buscar endereços... ($totalRecebido / ~$_totalEnderecosAprox)';
      notifyListeners();

      final batch = await ApiService.getBaseData('enderecos', skip: totalRecebido);

      if (batch == null) {
        sucesso = false;
        break;
      }
      
      await database.populateEnderecosFromAPI(batch);
      
      totalRecebido += batch.length;
      _syncProgress = (totalRecebido / _totalEnderecosAprox).clamp(0.0, 1.0);
      notifyListeners();
      
      if (batch.length < 2000) break;
    }

    if (sucesso) {
      final now = DateTime.now();
      _lastEnderecoSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastEnderecoSync', now.millisecondsSinceEpoch);
      _syncMessage = 'Sincronização de endereços concluída!';
    } else {
      _syncMessage = _cancelSync ? 'Sincronização de endereços cancelada.' : 'Erro ao sincronizar endereços.';
    }

    _isSyncing = false;
    _cancelSync = false;
    notifyListeners();
    return sucesso;
  }
  
  // --- LÓGICA DE SINCRONIZAÇÃO DE CATEGORIAS ---
  Future<bool> syncCategoriasFromAPI() async {
    _isSyncing = true;
    _cancelSync = false;
    _syncProgress = 0.0;
    _syncMessage = 'A iniciar sincronização de categorias...';
    notifyListeners();

    await database.apagarTodasCategorias();
    
    int totalRecebido = 0;
    bool sucesso = true;
    
    while (true) {
      if (_cancelSync) {
        sucesso = false;
        break;
      }
      
      _syncMessage = 'A buscar categorias... ($totalRecebido / ~$_totalCategoriasAprox)';
      notifyListeners();

      final batch = await ApiService.getBaseData('categorias', skip: totalRecebido);

      if (batch == null) {
        sucesso = false;
        break;
      }
      
      await database.populateCategoriasFromAPI(batch);
      
      totalRecebido += batch.length;
      _syncProgress = (totalRecebido / _totalCategoriasAprox).clamp(0.0, 1.0);
      notifyListeners();
      
      if (batch.length < 2000) break;
    }

    if (sucesso) {
      final now = DateTime.now();
      _lastCategoriaSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastCategoriaSync', now.millisecondsSinceEpoch);
      _syncMessage = 'Sincronização de categorias concluída!';
    } else {
      _syncMessage = _cancelSync ? 'Sincronização de categorias cancelada.' : 'Erro ao sincronizar categorias.';
    }

    _isSyncing = false;
    _cancelSync = false;
    notifyListeners();
    return sucesso;
  }

  // Sincronização silenciosa para a rotina automática
  Future<void> syncAllBasesSilently() async {
    debugPrint('A iniciar sincronização automática em segundo plano...');
    
    await syncClientesFromAPI();
    await syncProdutosFromAPI();
    await syncEnderecosFromAPI();
    await syncCategoriasFromAPI();
    
    debugPrint('Sincronização automática concluída.');
  }

  Future<void> updatePendingOrderCount() async {
    _pendingOrderCount = await database.countPedidosPendentes();
    notifyListeners();
  }
}

