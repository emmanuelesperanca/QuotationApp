import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../providers/auth_notifier.dart';

class TelaBasePreCadastro extends StatefulWidget {
  final AppDatabase database;
  const TelaBasePreCadastro({super.key, required this.database});
  @override
  State<TelaBasePreCadastro> createState() => _TelaBasePreCadastroState();
}

class _TelaBasePreCadastroState extends State<TelaBasePreCadastro> {
  late Future<List<PreCadastro>> _preCadastrosFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _preCadastrosFuture = widget.database.getTodosPreCadastros();
    });
  }

  Future<void> _limparBase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Ação'),
        content: const Text('Tem a certeza de que pretende limpar toda a base de pré-cadastros? Esta ação não pode ser desfeita.'),
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
      await widget.database.apagarTodosPreCadastros();
      _refreshList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Base de pré-cadastros limpa com sucesso.'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Base de Pré-Cadastros'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          if (auth.username == 'admin')
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _limparBase,
              tooltip: 'Limpar Base de Pré-Cadastros',
            )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Pesquisar cliente...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)),
              onChanged: (value) => setState(() => _preCadastrosFuture = widget.database.searchPreCadastros(value)),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PreCadastro>>(
              future: _preCadastrosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nenhum cliente pré-cadastrado."));
                
                final clientes = snapshot.data!;
                return ListView.builder(
                  itemCount: clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = clientes[index];
                    return ListTile(
                      leading: const Icon(Icons.person_add),
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
