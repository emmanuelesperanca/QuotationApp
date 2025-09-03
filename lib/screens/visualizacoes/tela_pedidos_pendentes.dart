import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../models/item_pedido.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/auth_notifier.dart';
import '../../api_service.dart';
import '../../pdf_service.dart';

class TelaPedidosPendentes extends StatefulWidget {
  final AppDatabase database;
  const TelaPedidosPendentes({super.key, required this.database});
  @override
  State<TelaPedidosPendentes> createState() => _TelaPedidosPendentesState();
}

class _TelaPedidosPendentesState extends State<TelaPedidosPendentes> {
  late Future<List<PedidoPendente>> _pedidosPendentesFuture;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _pedidosPendentesFuture = widget.database.getTodosPedidosPendentes();
      Provider.of<AppDataNotifier>(context, listen: false).updatePendingOrderCount();
    });
  }

  Future<void> _reenviarPedido(PedidoPendente pedido) async {
    setState(() {
      _isSending = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final pedidoData = jsonDecode(pedido.pedidoJson);
      final pdfBytes = await PdfService.generateOrderPdfBytes(pedidoData);
      final pdfBase64 = base64Encode(pdfBytes);
      pedidoData['pdf_base64'] = pdfBase64;

      final sucesso = await ApiService.enviarPedido(pedidoData);

      if (!mounted) return;

      if (sucesso == true) {
        final appPedidoId = pedidoData['app_pedido_id'] as String;
        await widget.database.inserePedidoEnviado(pedido.pedidoJson, appPedidoId);
        await widget.database.deletaPedidoPendente(pedido.id);

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Pedido reenviado e movido para o histórico com sucesso!'), backgroundColor: Colors.green),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Falha ao reenviar o pedido. A API retornou um erro.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
       if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erro de conexão ao reenviar o pedido: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
      _refreshData();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pedidos Pendentes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
          if (Provider.of<AuthNotifier>(context).username == 'admin')
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Limpar Pedidos Pendentes',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar Exclusão'),
                    content: const Text('Tem a certeza de que deseja apagar TODOS os pedidos pendentes? Esta ação não pode ser desfeita.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apagar')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await widget.database.apagarTodosPedidosPendentes();
                  _refreshData();
                }
              },
            ),
        ],
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<PedidoPendente>>(
            future: _pedidosPendentesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nenhum pedido pendente."));
              
              final pedidos = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidos[index];
                  final pedidoData = jsonDecode(pedido.pedidoJson);
                  
                   final List<dynamic> itensJson = (pedidoData['itens'] is String)
                      ? jsonDecode(pedidoData['itens'])
                      : pedidoData['itens'];
                  
                  final List<ItemPedido> itens = itensJson.map((item) {
                      return ItemPedido.fromJson(item as Map<String, dynamic>);
                  }).toList();

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.black.withOpacity(0.4),
                    child: ExpansionTile(
                      leading: const Icon(Icons.receipt_long, color: Colors.orangeAccent),
                      title: Text('Cliente: ${pedidoData['cliente'] ?? 'N/A'}'),
                      subtitle: Text('Total: R\$ ${pedidoData['total']?.toStringAsFixed(2) ?? '0.00'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.print_outlined),
                            tooltip: 'Imprimir Cópia do Pedido',
                            onPressed: () => PdfService.generateAndPrintPdf(pedidoData),
                          ),
                          IconButton(
                            icon: const Icon(Icons.upload),
                            tooltip: 'Reenviar Pedido',
                            onPressed: () => _reenviarPedido(pedido),
                          ),
                        ],
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Cód. Cliente:', pedidoData['cod_cliente'] ?? 'N/A'),
                              _buildDetailRow('Pagamento:', '${pedidoData['condicao_pagamento'] ?? 'N/A'} (${pedidoData['parcelas'] ?? ''})'),
                              _buildDetailRow('Entrega:', pedidoData['entrega'] ?? 'N/A'),
                              const Divider(height: 20),
                              const Text('Itens:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              ...itens.map((item) => Text('- ${item.qtd}x ${item.descricao} (Cód: ${item.cod})')).toList(),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
          if (_isSending)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('A reenviar pedido...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
