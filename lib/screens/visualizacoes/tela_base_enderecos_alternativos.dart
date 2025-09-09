import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/auth_notifier.dart';
import '../../services/csv_service.dart';

class TelaBaseEnderecosAlternativos extends StatefulWidget {
  final AppDatabase database;
  const TelaBaseEnderecosAlternativos({super.key, required this.database});
  @override
  State<TelaBaseEnderecosAlternativos> createState() => _TelaBaseEnderecosAlternativosState();
}

class _TelaBaseEnderecosAlternativosState extends State<TelaBaseEnderecosAlternativos> {
  late Future<List<EnderecoAlternativo>> _enderecosFuture;
  int _totalEnderecos = 0;
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
      _usarCsv = prefs.getBool('enderecos_usar_csv') ?? true;
    });
  }

  // Salva a preferência
  void _saveCsvPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enderecos_usar_csv', value);
    setState(() {
      _usarCsv = value;
    });
  }

  void _updateCount() async {
    final count = await widget.database.countEnderecos();
     if (mounted) {
      setState(() => _totalEnderecos = count);
    }
  }

  void _refreshList() {
    setState(() {
      _enderecosFuture = widget.database.getTodosEnderecosAlternativos();
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
    final success = await appData.syncEnderecosFromAPI(); 
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Base de endereços sincronizada com sucesso!'), backgroundColor: Colors.green));
        _refreshList();
        _updateCount();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao sincronizar a base de endereços.'), backgroundColor: Colors.red));
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
      final enderecosCsv = await CsvService.carregarEnderecosDoCsv();
      
      if (enderecosCsv.isNotEmpty) {
        // Limpa a base atual e insere os dados do CSV
        await widget.database.apagarTodosEnderecos();
        await widget.database.batch((batch) {
          batch.insertAll(widget.database.enderecosAlternativos, enderecosCsv, mode: drift.InsertMode.insertOrReplace);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${enderecosCsv.length} endereços carregados do CSV!'), backgroundColor: Colors.green)
          );
          _refreshList();
          _updateCount();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum endereço encontrado no CSV'), backgroundColor: Colors.orange)
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
        content: const Text('Tem a certeza de que pretende limpar toda a base de endereços alternativos? Esta ação não pode ser desfeita.'),
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
      await widget.database.apagarTodosEnderecos();
      _refreshList();
      _updateCount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Base de endereços limpa com sucesso.'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppDataNotifier>(context);
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    final lastSync = appData.lastEnderecoSync; 
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Base de Endereços Alternativos'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          if (auth.username == 'admin')
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _limparBase,
              tooltip: 'Limpar Base de Endereços',
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
                  decoration: const InputDecoration(labelText: 'Pesquisar endereço...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
                  onChanged: (value) => setState(() => _enderecosFuture = widget.database.searchEnderecosAlternativos(value)),
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
                              ? 'Última atualização: ${DateFormat('dd/MM/yy HH:mm').format(lastSync)} ($_totalEnderecos itens)' 
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
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              lastSync != null 
                              ? 'Última atualização: ${DateFormat('dd/MM/yy HH:mm').format(lastSync)} ($_totalEnderecos itens)' 
                              : 'Nunca atualizado',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Switch para escolher entre CSV e API
                          Flexible(
                            flex: 1,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 16,
                                  color: _usarCsv ? Colors.blue : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'CSV',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _usarCsv ? Colors.blue : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch.adaptive(
                                  value: !_usarCsv,
                                  onChanged: (bool novoValor) async {
                                    setState(() {
                                      _usarCsv = !novoValor;
                                    });
                                    _saveCsvPreference(_usarCsv);
                                  },
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.blue,
                                  inactiveTrackColor: Colors.blue.withOpacity(0.3),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'API',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: !_usarCsv ? Colors.green : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.cloud_outlined,
                                  size: 16,
                                  color: !_usarCsv ? Colors.green : Colors.grey,
                                ),
                              ],
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
                                  label: Text(_usarCsv ? 'Carregar do CSV Local' : 'Atualizar Base Online'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _usarCsv ? Colors.blue : null,
                                  ),
                                ),
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
            child: FutureBuilder<List<EnderecoAlternativo>>(
              future: _enderecosFuture,
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('A carregar base de endereços...'),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nenhum endereço encontrado."));
                
                final enderecos = snapshot.data!;
                return ListView.builder(
                  itemCount: enderecos.length,
                  itemBuilder: (context, index) {
                    final endereco = enderecos[index];
                    return ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(endereco.enderecoFormatado),
                      subtitle: Text('Cliente: ${endereco.numeroCliente} - Doc: ${endereco.cpfCnpj}'),
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

