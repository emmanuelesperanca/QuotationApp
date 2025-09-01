import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/auth_notifier.dart';

class TelaBaseProdutos extends StatefulWidget {
  final AppDatabase database;
  const TelaBaseProdutos({super.key, required this.database});

  @override
  State<TelaBaseProdutos> createState() => _TelaBaseProdutosState();
}

class _TelaBaseProdutosState extends State<TelaBaseProdutos> {
  late Future<List<Produto>> _produtosFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }
  
  void _refreshList() {
     setState(() {
      _produtosFuture = widget.database.getTodosProdutos();
    });
  }

  void _handleSync() async {
    final appData = Provider.of<AppDataNotifier>(context, listen: false);
    final success = await appData.syncProdutosFromCsv();
    if(mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Base de produtos carregada com sucesso!'), backgroundColor: Colors.green));
        _refreshList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao carregar o ficheiro CSV.'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _limparBase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Ação'),
        content: const Text('Tem a certeza de que pretende limpar toda a base de produtos? Esta ação não pode ser desfeita.'),
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
      await widget.database.apagarTodosProdutos();
      _refreshList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Base de produtos limpa com sucesso.'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppDataNotifier>(context);
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    final lastSync = appData.lastProductSync;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Base de Produtos'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          if (auth.username == 'admin')
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _limparBase,
              tooltip: 'Limpar Base de Produtos',
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
                  decoration: const InputDecoration(labelText: 'Pesquisar produto...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
                  onChanged: (value) => setState(() => _produtosFuture = widget.database.searchProdutos(value)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lastSync != null ? 'Última atualização: ${DateFormat('dd/MM/yy HH:mm').format(lastSync)}' : 'Nunca atualizado'),
                    ElevatedButton.icon(
                      onPressed: appData.isSyncing ? null : _handleSync,
                      icon: appData.isSyncing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2,)) : const Icon(Icons.upload_file),
                      label: Text(appData.isSyncing ? 'A Carregar...' : 'Carregar do CSV'),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Produto>>(
              future: _produtosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nenhum produto encontrado."));
                
                final produtos = snapshot.data!;
                return ListView.builder(
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    final produto = produtos[index];
                    return ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(produto.descricao),
                      subtitle: Text('Cód: ${produto.referencia} - R\$ ${produto.valor.toStringAsFixed(2)}'),
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
