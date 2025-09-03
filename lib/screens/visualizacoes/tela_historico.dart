import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../models/item_pedido.dart';
import '../../api_service.dart';
import '../../pdf_service.dart';
import '../../providers/auth_notifier.dart'; 

class TelaHistorico extends StatefulWidget {
  final AppDatabase database;
  const TelaHistorico({super.key, required this.database});
  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  late Future<List<PedidoEnviado>> _historicoFuture;
  final _searchController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _historicoFuture = widget.database.getTodosPedidosEnviados();
    });
  }

  void _search() {
    setState(() {
      _historicoFuture = widget.database.searchPedidosEnviados(_searchController.text);
    });
  }

  Future<void> _updateStatus(PedidoEnviado pedido) async {
    setState(() => _isUpdating = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (pedido.appPedidoId == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Este pedido antigo não possui um ID para atualização.'), backgroundColor: Colors.orange));
      setState(() => _isUpdating = false);
      return;
    }

    try {
      final statusData = await ApiService.getStatusPedido(pedido.appPedidoId!);
      if (statusData != null) {
        await widget.database.updateStatusPedidoEnviado(
          pedido.appPedidoId!,
          statusData['numeroPedidoSap'] ?? '',
          statusData['status'] ?? '',
          statusData['obsCentral'] ?? '',
        );
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Status atualizado com sucesso!'), backgroundColor: Colors.green));
        _refreshData();
      } else {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Nenhuma atualização encontrada para este pedido.'), backgroundColor: Colors.orange));
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Erro ao buscar atualizações: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Histórico de Pedidos'),
        actions: [
          if (Provider.of<AuthNotifier>(context).username == 'admin')
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Limpar Histórico',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar Exclusão'),
                    content: const Text('Tem a certeza de que deseja apagar TODO o histórico de pedidos? Esta ação não pode ser desfeita.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apagar')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await widget.database.apagarTodosPedidosEnviados();
                  _refreshData();
                }
              },
            ),
        ],
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por Código do Cliente...',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _search,
                    ),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<PedidoEnviado>>(
                  future: _historicoFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Nenhum pedido no histórico."));
                    
                    final pedidos = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidos[index];
                        final pedidoData = jsonDecode(pedido.pedidoJson);
                        final List<dynamic> itensJson = (pedidoData['itens'] is String)
                            ? jsonDecode(pedidoData['itens'])
                            : pedidoData['itens'];
                        final List<ItemPedido> itens = itensJson.map((item) => ItemPedido.fromJson(item)).toList();

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.black.withOpacity(0.4),
                          child: ExpansionTile(
                            leading: const Icon(Icons.history, color: Colors.blueGrey),
                            title: Text('Cliente: ${pedidoData['cliente'] ?? 'N/A'}'),
                            subtitle: Text('Enviado em: ${DateFormat('dd/MM/yyyy HH:mm').format(pedido.dataEnvio)}'),
                            trailing: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 IconButton(
                                   icon: const Icon(Icons.print_outlined),
                                   tooltip: 'Imprimir Cópia do Pedido',
                                   onPressed: () => PdfService.generateAndPrintPdf(pedidoData),
                                 ),
                                 IconButton(
                                   icon: const Icon(Icons.sync),
                                   tooltip: 'Obter Atualizações',
                                   onPressed: () => _updateStatus(pedido),
                                 ),
                               ],
                            ),
                            children: [
                               Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow('Status:', pedido.status ?? 'Aguardando Sincronização'),
                                    _buildDetailRow('Nº Pedido SAP:', pedido.numeroPedidoSap ?? 'N/A'),
                                    _buildDetailRow('Obs. Central:', pedido.obsCentral ?? 'N/A'),
                                    const Divider(height: 20),
                                    _buildDetailRow('Cód. Cliente:', pedidoData['cod_cliente'] ?? 'N/A'),
                                    _buildDetailRow('Pagamento:', '${pedidoData['condicao_pagamento'] ?? 'N/A'} (${pedidoData['parcelas'] ?? ''})'),
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
              ),
            ],
          ),
           if (_isUpdating)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('A obter atualizações...'),
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
