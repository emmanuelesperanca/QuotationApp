import 'package:flutter/material.dart';
import '../../database.dart';
import '../../models/item_pedido.dart';
import '../../models/promocao.dart';

class TelaSelecaoVariacoes extends StatefulWidget {
  final AppDatabase database;
  final ItemPromocao itemPromocional;

  const TelaSelecaoVariacoes({
    super.key,
    required this.database,
    required this.itemPromocional,
  });

  @override
  State<TelaSelecaoVariacoes> createState() => _TelaSelecaoVariacoesState();
}

class _TelaSelecaoVariacoesState extends State<TelaSelecaoVariacoes> {
  late Future<List<Produto>> _variacoesFuture;
  final Map<String, int> _quantidadesSelecionadas = {};
  int _quantidadeTotal = 0;

  @override
  void initState() {
    super.initState();
    _variacoesFuture = widget.database.searchProdutosPorFamilia(widget.itemPromocional.descricao);
  }
  
  void _atualizarTotal() {
    setState(() {
      _quantidadeTotal = _quantidadesSelecionadas.values.fold(0, (soma, atual) => soma + atual);
    });
  }

  void _confirmarSelecao() {
    final List<ItemPedido> itensSelecionados = [];
    _quantidadesSelecionadas.forEach((referencia, quantidade) {
      if (quantidade > 0) {
        // Encontra o produto correspondente para obter todos os detalhes
        _variacoesFuture.then((listaProdutos) {
          final produto = listaProdutos.firstWhere((p) => p.referencia == referencia);
          itensSelecionados.add(ItemPedido(
            cod: produto.referencia,
            descricao: produto.descricao,
            valorUnitario: produto.valor,
            qtd: quantidade,
            desconto: widget.itemPromocional.descontoDigitacao, // Aplica o desconto da promoção
            isPromocional: true,
          ));
        });
      }
    });
    // Aguarda a conclusão de todos os futures antes de fechar
    Future.wait([_variacoesFuture]).then((_) {
      Navigator.of(context).pop(itensSelecionados);
    });
  }


  @override
  Widget build(BuildContext context) {
    final int quantidadeMaxima = widget.itemPromocional.qtdDigitacao;
    final bool podeAdicionarMais = _quantidadeTotal < quantidadeMaxima;
    final bool podeConfirmar = _quantidadeTotal == quantidadeMaxima;

    return AlertDialog(
      title: Text('Selecione as Variações de ${widget.itemPromocional.descricao}'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Distribua a quantidade total de $quantidadeMaxima itens entre as opções abaixo.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _quantidadeTotal / quantidadeMaxima,
              minHeight: 10,
            ),
            Text('$_quantidadeTotal / $quantidadeMaxima selecionados'),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Produto>>(
                future: _variacoesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhuma variação encontrada.'));
                  }
                  
                  final variacoes = snapshot.data!;

                  return ListView.builder(
                    itemCount: variacoes.length,
                    itemBuilder: (context, index) {
                      final produto = variacoes[index];
                      final quantidadeAtual = _quantidadesSelecionadas[produto.referencia] ?? 0;

                      return ListTile(
                        title: Text(produto.descricao),
                        subtitle: Text('Cód: ${produto.referencia}'),
                        trailing: SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: quantidadeAtual > 0
                                    ? () {
                                        setState(() {
                                          _quantidadesSelecionadas[produto.referencia] = quantidadeAtual - 1;
                                          _atualizarTotal();
                                        });
                                      }
                                    : null,
                              ),
                              Text(quantidadeAtual.toString(), style: Theme.of(context).textTheme.titleLarge),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: podeAdicionarMais
                                    ? () {
                                        setState(() {
                                          _quantidadesSelecionadas[produto.referencia] = quantidadeAtual + 1;
                                          _atualizarTotal();
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: podeConfirmar ? _confirmarSelecao : null,
          child: const Text('Confirmar Seleção'),
        ),
      ],
    );
  }
}

