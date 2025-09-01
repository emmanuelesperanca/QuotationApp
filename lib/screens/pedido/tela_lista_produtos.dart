import 'package:flutter/material.dart';
import '../../database.dart';

class TelaListaProdutos extends StatefulWidget {
  final AppDatabase database;
  const TelaListaProdutos({super.key, required this.database});
  @override
  State<TelaListaProdutos> createState() => _TelaListaProdutosState();
}

class _TelaListaProdutosState extends State<TelaListaProdutos> {
  late Future<List<Produto>> _produtosFuture;

  @override
  void initState() {
    super.initState();
    _produtosFuture = widget.database.getTodosProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Selecionar Produto'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: FutureBuilder<List<Produto>>(
        future: _produtosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum produto encontrado."));
          }

          final produtos = snapshot.data!;
          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return ListTile(
                title: Text(produto.descricao),
                subtitle: Text('Cód: ${produto.referencia} - R\$ ${produto.valor.toStringAsFixed(2)}'),
                onTap: () {
                  Navigator.pop(context, produto);
                },
              );
            },
          );
        },
      ),
    );
  }
}
