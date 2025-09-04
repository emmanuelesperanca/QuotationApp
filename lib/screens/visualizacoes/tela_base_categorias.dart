import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/auth_notifier.dart';

class TelaBaseCategorias extends StatefulWidget {
  final AppDatabase database;
  const TelaBaseCategorias({super.key, required this.database});
  @override
  State<TelaBaseCategorias> createState() => _TelaBaseCategoriasState();
}

class _TelaBaseCategoriasState extends State<TelaBaseCategorias> {
  // O Future agora é para a classe que une Produto e Categoria
  late Future<List<ProdutoComCategoria>> _produtosComCategoriaFuture;
  int _totalCategorias = 0;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      // Usaremos um método de busca genérico para carregar todos no início
      _produtosComCategoriaFuture = widget.database.searchProdutosPorCategoria({});
      widget.database.countCategorias().then((count) {
        if (mounted) setState(() => _totalCategorias = count);
      });
    });
  }

  void _handleSync() async {
    final appData = Provider.of<AppDataNotifier>(context, listen: false);
    final success = await appData.syncCategoriasFromAPI();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Base de categorias carregada com sucesso!'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appData.syncMessage), backgroundColor: Colors.red));
      }
      _refreshList();
    }
  }

  Future<void> _limparBase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Ação'),
        content: const Text('Tem a certeza de que pretende limpar toda a base de categorias? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpar'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.database.apagarTodasCategorias();
      if(mounted) _refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppDataNotifier>(context);
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    final lastSync = appData.lastCategoriaSync;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Base de Categorias de Produtos'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          if (auth.username == 'admin')
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _limparBase,
              tooltip: 'Limpar Base de Categorias',
            )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lastSync != null ? 'Última atualização: ${DateFormat('dd/MM/yy HH:mm').format(lastSync)} ($_totalCategorias itens)' : 'Nunca atualizado'),
                    if (appData.isSyncing)
                      ElevatedButton.icon(
                        onPressed: appData.cancelSync,
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Parar'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _handleSync,
                        icon: const Icon(Icons.sync),
                        label: const Text('Atualizar Base Online'),
                      )
                  ],
                ),
                 if (appData.isSyncing)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(value: appData.syncProgress),
                        const SizedBox(height: 4),
                        Text(appData.syncMessage, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ProdutoComCategoria>>(
              future: _produtosComCategoriaFuture,
              builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nenhuma categoria encontrada."));
                
                final produtos = snapshot.data!;
                return ListView.builder(
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final item = produtos[index];
                    return ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: Text(item.produto.descricao),
                      subtitle: Text(
                        'Cód: ${item.produto.referencia} | Marca: ${item.categoria?.brandTopNode ?? "N/A"}',
                        style: const TextStyle(fontSize: 12),
                      ),
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
