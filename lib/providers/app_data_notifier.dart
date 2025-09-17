import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import '../api_service.dart';
import '../database.dart';
import '../services/csv_service.dart';

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
  Timer? _syncTimer;
  
  // Configurações de sincronização - v1.0.1
  bool _autoSyncEnabled = false;
  bool _devToolsEnabled = false;

  // Valores totais aproximados para a barra de progresso
  final int _totalClientesAprox = 160000;
  final int _totalProdutosAprox = 20000;
  final int _totalEnderecosAprox = 100000;
  final int _totalCategoriasAprox = 50000;


  AppDataNotifier(this.database) {
    updatePendingOrderCount();
    _loadSyncDates();
    _loadSyncConfig();
    
    // Verifica se é a primeira execução e inicia sincronização automática
    _checkFirstRun();
    
    // Inicia a sincronização automática em segundo plano (AUMENTADO PARA 6 HORAS)
    _startAutoSyncTimer();
  }
  
  // Controla a sincronização automática
  void _startAutoSyncTimer() {
    if (_autoSyncEnabled) {
      _syncTimer = Timer.periodic(const Duration(hours: 6), (timer) {
        if (!_isSyncing && _autoSyncEnabled) {
          print('🔄 Iniciando sincronização automática (6h)');
          syncAllBasesSilently();
        }
      });
    }
  }
  
  void _stopAutoSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
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
  bool get autoSyncEnabled => _autoSyncEnabled;
  bool get devToolsEnabled => _devToolsEnabled;
  
  // Configurações de desenvolvedor - v1.0.1
  Future<void> setDevToolsEnabled(bool enabled) async {
    _devToolsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dev_tools_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setAutoSyncEnabled(bool enabled) async {
    _autoSyncEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_sync_enabled', enabled);
    
    if (enabled) {
      _startAutoSyncTimer();
    } else {
      _stopAutoSyncTimer();
    }
    notifyListeners();
  }
  
  // Carrega configurações de sincronização
  Future<void> _loadSyncConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? false;
    _devToolsEnabled = prefs.getBool('dev_tools_enabled') ?? false;
    
    notifyListeners();
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
    final categoriaMillis = prefs.getInt('lastCategoriaSync');
    if (categoriaMillis != null) {
      _lastCategoriaSync = DateTime.fromMillisecondsSinceEpoch(categoriaMillis);
    }
    notifyListeners();
  }
  
  // Verifica se é a primeira execução e carrega dados iniciais
  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('first_run') ?? true;
    
    if (isFirstRun) {
      print('🚀 AppDataNotifier: Primeira execução detectada');
      
      // Verifica se as bases estão vazias
      final clientesCount = await database.countClientes();
      final produtosCount = await database.countProdutos();
      final enderecosCount = await database.countEnderecos();
      
      print('📊 Contadores atuais: Clientes=$clientesCount, Produtos=$produtosCount, Endereços=$enderecosCount');
      
      // Se pelo menos uma das bases estiver vazia, carrega dados iniciais
      if (clientesCount == 0 || produtosCount == 0 || enderecosCount == 0) {
        print('🔄 Iniciando carregamento automático da primeira execução...');
        
        // Marca que já não é mais a primeira execução
        await prefs.setBool('first_run', false);
        
        // Inicia a sincronização em background
        _startFirstRunSync();
      } else {
        // Se as bases já têm dados, só marca como não sendo primeira execução
        await prefs.setBool('first_run', false);
        print('✅ Bases já contêm dados, carregamento automático não necessário');
      }
    }
  }
  
  // Carregamento específico para primeira execução (CSV ao invés de API)
  Future<void> _startFirstRunSync() async {
    // Executa em uma nova "thread" para não bloquear a UI
    Future.delayed(const Duration(seconds: 2), () async {
      if (!_isSyncing) {
        print('� Iniciando carregamento silencioso do CSV na primeira execução...');
        await _loadAllFromCsvSilently();
      }
    });
  }
  
  void cancelSync() {
    _cancelSync = true;
    _isSyncing = false; // CORREÇÃO: Resetar o estado de sincronização
    _syncProgress = 0.0; // CORREÇÃO: Resetar o progresso
    _syncMessage = 'Sincronização cancelada.';
    notifyListeners();
  }

  // Método para forçar reset do estado de sincronização em caso de problemas
  void forceResetSyncState() {
    print('🔄 AppDataNotifier: Forçando reset do estado de sincronização');
    _isSyncing = false;
    _cancelSync = false;
    _syncProgress = 0.0;
    _syncMessage = 'Pronto para sincronizar';
    notifyListeners();
  }
  
  // Dispose para limpar recursos
  @override
  void dispose() {
    _stopAutoSyncTimer();
    super.dispose();
  }

  // --- LÓGICA DE SINCRONIZAÇÃO DE CLIENTES ---
  Future<bool> syncClientesFromAPI() async {
    _isSyncing = true;
    _cancelSync = false;
    _syncProgress = 0.0;
    _syncMessage = 'A iniciar sincronização de clientes...';
    notifyListeners();

    // Primeiro tenta sincronizar da API
    bool sucessoAPI = await _syncClientesFromAPI();
    
    // Se falhou na API, tenta usar CSV local como fallback
    if (!sucessoAPI && await CsvService.csvDisponivel()) {
      print('🔄 API falhou, tentando carregar clientes do CSV local...');
      _syncMessage = 'API indisponível, carregando dados locais...';
      notifyListeners();
      
      try {
        await database.apagarTodosClientes();
        final clientesCsv = await CsvService.carregarClientesDoCsv();
        
        if (clientesCsv.isNotEmpty) {
          // Usar batch para inserir em lotes, mais eficiente
          await database.batch((batch) {
            batch.insertAll(database.clientes, clientesCsv, mode: InsertMode.insertOrReplace);
          });
          
          if (!_cancelSync) {
            final now = DateTime.now();
            _lastClientSync = now;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('lastClientSync', now.millisecondsSinceEpoch);
            _syncMessage = 'Clientes carregados do backup local!';
            print('✅ Clientes carregados do CSV local com sucesso');
            sucessoAPI = true;
          }
        }
      } catch (e) {
        print('❌ Erro ao carregar clientes do CSV: $e');
        _syncMessage = 'Erro ao carregar dados locais.';
      }
    }

    _isSyncing = false;
    _cancelSync = false;
    notifyListeners();
    return sucessoAPI;
  }
  
  // Método auxiliar para sincronização via API
  Future<bool> _syncClientesFromAPI() async {
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

    return sucesso;
  }
  
  // --- LÓGICA DE SINCRONIZAÇÃO DE PRODUTOS ---
  Future<bool> syncProdutosFromAPI() async {
     print('🚀 AppDataNotifier: Iniciando sincronização de produtos...');
     _isSyncing = true;
    _cancelSync = false;
    _syncProgress = 0.0;
    _syncMessage = 'A iniciar sincronização de produtos...';
    notifyListeners();

    // Primeiro tenta sincronizar da API
    bool sucessoAPI = await _syncProdutosFromAPI();
    
    // Se falhou na API, tenta usar CSV local como fallback
    if (!sucessoAPI && await CsvService.csvDisponivel()) {
      print('🔄 API falhou, tentando carregar produtos do CSV local...');
      _syncMessage = 'API indisponível, carregando produtos locais...';
      notifyListeners();
      
      try {
        await database.apagarTodosProdutos();
        final produtosCsv = await CsvService.carregarProdutosDoCsv();
        
        if (produtosCsv.isNotEmpty) {
          // Usar batch para inserir em lotes, mais eficiente
          await database.batch((batch) {
            batch.insertAll(database.produtos, produtosCsv, mode: InsertMode.insertOrReplace);
          });
          
          if (!_cancelSync) {
            final now = DateTime.now();
            _lastProductSync = now;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('lastProductSync', now.millisecondsSinceEpoch);
            _syncMessage = 'Produtos carregados do backup local!';
            print('✅ Produtos carregados do CSV local com sucesso');
            sucessoAPI = true;
          }
        }
      } catch (e) {
        print('❌ Erro ao carregar produtos do CSV: $e');
        _syncMessage = 'Erro ao carregar produtos locais.';
      }
    }

    print('🏁 AppDataNotifier: Finalizando sincronização de produtos (isSyncing = false)');
    _isSyncing = false;
    _cancelSync = false;
    notifyListeners();
    return sucessoAPI;
  }
  
  // Método auxiliar para sincronização via API
  Future<bool> _syncProdutosFromAPI() async {
    print('🗑️ AppDataNotifier: Apagando produtos existentes...');
    await database.apagarTodosProdutos();
    
    int totalRecebido = 0;
    bool sucesso = true;
    
    while (true) {
      if (_cancelSync) {
        print('❌ AppDataNotifier: Sincronização de produtos cancelada pelo usuário');
        sucesso = false;
        break;
      }

      _syncMessage = 'A buscar produtos... ($totalRecebido / ~$_totalProdutosAprox)';
      print('📡 AppDataNotifier: Buscando produtos batch - skip: $totalRecebido');
      notifyListeners();

      final batch = await ApiService.getBaseData('produtos', skip: totalRecebido);

      if (batch == null) {
        print('❌ AppDataNotifier: Erro ao buscar batch de produtos - API retornou null');
        sucesso = false;
        break;
      }

      print('✅ AppDataNotifier: Recebido batch com ${batch.length} produtos');
      await database.populateProdutosFromAPI(batch);

      totalRecebido += batch.length;
       _syncProgress = (totalRecebido / _totalProdutosAprox).clamp(0.0, 1.0);
      notifyListeners();

      if (batch.length < 2000) {
        print('🏁 AppDataNotifier: Última página de produtos recebida (${batch.length} < 2000)');
        break;
      }
    }

    if (sucesso) {
      print('✅ AppDataNotifier: Sincronização de produtos concluída com sucesso!');
      final now = DateTime.now();
      _lastProductSync = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastProductSync', now.millisecondsSinceEpoch);
      _syncMessage = 'Sincronização de produtos concluída!';
    } else {
       print('❌ AppDataNotifier: Sincronização de produtos falhou ou foi cancelada');
       _syncMessage = _cancelSync ? 'Sincronização de produtos cancelada.' : 'Erro ao sincronizar produtos.';
    }

    return sucesso;
  }

  // --- LÓGICA DE SINCRONIZAÇÃO DE ENDEREÇOS ---
  Future<bool> syncEnderecosFromAPI() async {
     _isSyncing = true;
    _cancelSync = false;
    _syncProgress = 0.0;
    _syncMessage = 'A iniciar sincronização de endereços...';
    notifyListeners();

    // Primeiro tenta sincronizar da API
    bool sucessoAPI = await _syncEnderecosFromAPI();
    
    // Se falhou na API, tenta usar CSV local como fallback
    if (!sucessoAPI && await CsvService.csvDisponivel()) {
      print('🔄 API falhou, tentando carregar endereços do CSV local...');
      _syncMessage = 'API indisponível, carregando endereços locais...';
      notifyListeners();
      
      try {
        await database.apagarTodosEnderecos();
        final enderecosCsv = await CsvService.carregarEnderecosDoCsv();
        
        if (enderecosCsv.isNotEmpty) {
          // Usar batch para inserir em lotes, mais eficiente
          await database.batch((batch) {
            batch.insertAll(database.enderecosAlternativos, enderecosCsv, mode: InsertMode.insertOrReplace);
          });
          
          if (!_cancelSync) {
            final now = DateTime.now();
            _lastEnderecoSync = now;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('lastEnderecoSync', now.millisecondsSinceEpoch);
            _syncMessage = 'Endereços carregados do backup local!';
            print('✅ Endereços carregados do CSV local com sucesso');
            sucessoAPI = true;
          }
        }
      } catch (e) {
        print('❌ Erro ao carregar endereços do CSV: $e');
        _syncMessage = 'Erro ao carregar endereços locais.';
      }
    }

    _isSyncing = false;
    _cancelSync = false;
    notifyListeners();
    return sucessoAPI;
  }
  
  // Método auxiliar para sincronização via API
  Future<bool> _syncEnderecosFromAPI() async {
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

  // Carrega dados do CSV silenciosamente na primeira execução
  Future<void> _loadAllFromCsvSilently() async {
    try {
      // Verifica se CSVs estão disponíveis
      final csvDisponivel = await CsvService.csvDisponivel();
      if (!csvDisponivel) {
        print('❌ Arquivos CSV não encontrados para primeira execução');
        return;
      }

      print('📁 Configurando bases para CSV e carregando dados silenciosamente...');
      
      // Salva preferências para usar CSV em todas as bases
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('clientes_usar_csv', true);
      await prefs.setBool('produtos_usar_csv', true);
      await prefs.setBool('enderecos_usar_csv', true);

      // Carrega dados do CSV em paralelo
      await Future.wait([
        _loadClientesFromCsvSilently(),
        _loadProdutosFromCsvSilently(),
        _loadEnderecosFromCsvSilently(),
      ]);

      print('✅ Todas as bases carregadas do CSV com sucesso na primeira execução!');
      
    } catch (e) {
      print('❌ Erro ao carregar CSV na primeira execução: $e');
    }
  }

  // Métodos auxiliares para carregamento silencioso do CSV
  Future<void> _loadClientesFromCsvSilently() async {
    try {
      final clientesCsv = await CsvService.carregarClientesDoCsv();
      await database.populateClientesFromAPI(clientesCsv);
      print('✅ Clientes carregados do CSV: ${clientesCsv.length}');
    } catch (e) {
      print('❌ Erro ao carregar clientes do CSV: $e');
    }
  }

  Future<void> _loadProdutosFromCsvSilently() async {
    try {
      final produtosCsv = await CsvService.carregarProdutosDoCsv();
      await database.populateProdutosFromAPI(produtosCsv);
      print('✅ Produtos carregados do CSV: ${produtosCsv.length}');
    } catch (e) {
      print('❌ Erro ao carregar produtos do CSV: $e');
    }
  }

  Future<void> _loadEnderecosFromCsvSilently() async {
    try {
      final enderecosCsv = await CsvService.carregarEnderecosDoCsv();
      await database.populateEnderecosFromAPI(enderecosCsv);
      print('✅ Endereços carregados do CSV: ${enderecosCsv.length}');
    } catch (e) {
      print('❌ Erro ao carregar endereços do CSV: $e');
    }
  }
}

