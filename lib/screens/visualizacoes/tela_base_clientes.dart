import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/auth_notifier.dart';
import '../../services/csv_service.dart';

class TelaBaseClientes extends StatefulWidget {
  final AppDatabase database;
  const TelaBaseClientes({super.key, required this.database});
  @override
  State<TelaBaseClientes> createState() => _TelaBaseClientesState();
}

class _TelaBaseClientesState extends State<TelaBaseClientes> {
  late Future<List<Cliente>> _clientesFuture;
  int _totalClientes = 0;
  bool _usarCsv = true; // Por padrão usa CSV
  bool _loadingCsv = false;

  @override
  void initState() {
    super.initState();
    _loadCsvPreference();
    _refreshList();
    _updateCount();
  }

  // Carrega a preferência salva
  void _loadCsvPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usarCsv = prefs.getBool('clientes_usar_csv') ?? true;
    });
  }

  // Salva a preferência
  void _saveCsvPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('clientes_usar_csv', value);
    setState(() {
      _usarCsv = value;
    });
  }

  void _updateCount() async {
    final count = await widget.database.countClientes();
    if (mounted) {
      setState(() => _totalClientes = count);
    }
  }

  void _refreshList() {
    setState(() {
      _clientesFuture = widget.database.getTodosClientes();
    });
  }

  void _handleSync() async {
    if (_usarCsv) {
      _handleCsvLoad();
    } else {
      _handleOnlineSync();
    }
  }

  // Sincronização online (método original)
  void _handleOnlineSync() async {
    final appData = Provider.of<AppDataNotifier>(context, listen: false);
    final success = await appData.syncClientesFromAPI();
    if(mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Base de clientes sincronizada com sucesso!'), backgroundColor: Colors.green));
        _refreshList();
        _updateCount();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao sincronizar a base de clientes.'), backgroundColor: Colors.red));
      }
    }
  }

  // Carregamento do CSV
  void _handleCsvLoad() async {
    setState(() => _loadingCsv = true);
    
    try {
      final csvDisponivel = await CsvService.csvDisponivel();
      if (!csvDisponivel) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arquivos CSV não encontrados'), backgroundColor: Colors.red)
          );
        }
        return;
      }

      // Carrega dados do CSV
      final clientesCsv = await CsvService.carregarClientesDoCsv();
      
      if (clientesCsv.isNotEmpty) {
        // Limpa a base atual e insere os dados do CSV
        await widget.database.apagarTodosClientes();
        await widget.database.batch((batch) {
          batch.insertAll(widget.database.clientes, clientesCsv, mode: drift.InsertMode.insertOrReplace);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${clientesCsv.length} clientes carregados do CSV!'), backgroundColor: Colors.green)
          );
          _refreshList();
          _updateCount();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum cliente encontrado no CSV'), backgroundColor: Colors.orange)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar CSV: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingCsv = false);
      }
    }
  }

  Future<void> _limparBase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Ação'),
        content: const Text('Tem a certeza de que pretende limpar toda a base de clientes? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpar'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.database.apagarTodosClientes();
      _refreshList();
      _updateCount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Base de clientes limpa com sucesso.'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppDataNotifier>(context);
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    final lastSync = appData.lastClientSync;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Base de Clientes'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          if (auth.username == 'admin')
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _limparBase,
              tooltip: 'Limpar Base de Clientes',
            )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Pesquisar cliente...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
                  onChanged: (value) => setState(() => _clientesFuture = widget.database.searchClientes(value)),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;
                    
                    if (isMobile) {
                      // Layout vertical para mobile
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lastSync != null 
                              ? 'Última atualização: ${DateFormat('dd/MM/yy HH:mm').format(lastSync)} ($_totalClientes itens)' 
                              : 'Nunca atualizado',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Switch para escolher fonte dos dados
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _usarCsv ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _usarCsv ? Colors.blue : Colors.green,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _usarCsv ? Icons.folder_open : Icons.cloud,
                                  color: _usarCsv ? Colors.blue : Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _usarCsv ? 'Dados do CSV Local' : 'Dados Online (API)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _usarCsv ? Colors.blue : Colors.green,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _usarCsv,
                                  onChanged: _saveCsvPreference,
                                  activeColor: Colors.blue,
                                  inactiveThumbColor: Colors.green,
                                  inactiveTrackColor: Colors.green.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (appData.isSyncing || _loadingCsv)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: appData.cancelSync,
                                icon: const Icon(Icons.stop_circle_outlined),
                                label: const Text('Parar'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _handleSync,
                                icon: Icon(_usarCsv ? Icons.folder_open : Icons.sync),
                                label: Text(_usarCsv ? 'Carregar do CSV Local' : 'Atualizar Base Online'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _usarCsv ? Colors.blue : null,
                                ),
                              ),
                            ),
                        ],
                      );
                    } else {
                      // Layout horizontal para tablet/desktop
                      return Column(
                        children: [
                          // Switch para desktop
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _usarCsv ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _usarCsv ? Colors.blue : Colors.green,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _usarCsv ? Icons.folder_open : Icons.cloud,
                                  color: _usarCsv ? Colors.blue : Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _usarCsv ? 'Dados do CSV Local' : 'Dados Online (API)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _usarCsv ? Colors.blue : Colors.green,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _usarCsv,
                                  onChanged: _saveCsvPreference,
                                  activeColor: Colors.blue,
                                  inactiveThumbColor: Colors.green,
                                  inactiveTrackColor: Colors.green.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  lastSync != null 
                                  ? 'Última atualização: ${DateFormat('dd/MM/yy HH:mm').format(lastSync)} ($_totalClientes itens)' 
                                  : 'Nunca atualizado',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                flex: 1,
                                child: (appData.isSyncing || _loadingCsv)
                                  ? ElevatedButton.icon(
                                      onPressed: appData.cancelSync,
                                      icon: const Icon(Icons.stop_circle_outlined),
                                      label: const Text('Parar'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _handleSync,
                                      icon: Icon(_usarCsv ? Icons.folder_open : Icons.sync),
                                      label: Text(_usarCsv ? 'Carregar CSV' : 'Atualizar Online'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _usarCsv ? Colors.blue : null,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
                if (appData.isSyncing)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(value: appData.syncProgress),
                        const SizedBox(height: 4),
                        Text(appData.syncMessage, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Cliente>>(
              future: _clientesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('A carregar base de clientes...'),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nenhum cliente encontrado."));
                
                final clientes = snapshot.data!;
                return ListView.builder(
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(cliente.nome),
                      subtitle: Text(cliente.email ?? 'Sem email'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

