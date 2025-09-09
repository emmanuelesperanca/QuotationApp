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

  Future<void> _reenviarTodosPedidos() async {
    final pedidos = await _pedidosPendentesFuture;
    if (pedidos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum pedido pendente para reenviar')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reenviar Todos os Pedidos'),
        content: Text('Deseja tentar reenviar todos os ${pedidos.length} pedidos pendentes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reenviar Todos'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSending = true;
    });

    int sucessos = 0;
    int falhas = 0;
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    for (final pedido in pedidos) {
      try {
        final pedidoData = jsonDecode(pedido.pedidoJson);
        final pdfBytes = await PdfService.generateOrderPdfBytes(pedidoData);
        final pdfBase64 = base64Encode(pdfBytes);
        pedidoData['pdf_base64'] = pdfBase64;

        final sucesso = await ApiService.enviarPedido(pedidoData);

        if (sucesso) {
          final appPedidoId = pedidoData['app_pedido_id'] as String;
          await widget.database.inserePedidoEnviado(pedido.pedidoJson, appPedidoId);
          await widget.database.deletaPedidoPendente(pedido.id);
          sucessos++;
        } else {
          falhas++;
        }
      } catch (e) {
        falhas++;
      }
    }

    setState(() {
      _isSending = false;
    });

    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Processamento concluído: $sucessos enviados com sucesso, $falhas falharam',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: sucessos > 0 ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      _refreshData();
    }
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

        // Enviar dados de analytics para o reenvio bem-sucedido
        final String? deviceUUID = await ApiService.getDeviceUUID();
        final String version = await ApiService.getAppVersion();
        
        final Map<String, dynamic> transacaoData = {
          'transacao': {
            'appPedidoUUID': appPedidoId,
            'timestampPedido': DateTime.now().toIso8601String(),
            'vendedor': {'codigoAssessor': pedidoData['cod_assessor'] ?? ''},
            'dispositivo': {'deviceUUID': deviceUUID},
            'cliente': {'numeroClienteSAP': pedidoData['cod_cliente'] ?? '', 'nome': pedidoData['cliente'] ?? ''},
            'pedido': {
              'valorTotal': (pedidoData['total'] as num?)?.toDouble() ?? 0.0,
              'condicaoPagamento': pedidoData['condicao_pagamento'] ?? '',
              'parcelas': _extrairNumeroParcelas(pedidoData['parcelas']),
              'metodoEntrega': pedidoData['entrega'] ?? '',
              'promocode': pedidoData['promocode'] ?? '',
            },
            'itens': _extrairItensParaAnalytics(pedidoData['itens']),
          },
          'evento': {
            'tipo': 'PEDIDO_ENVIADO',
            'versaoApp': version,
          },
        };

        await ApiService.enviarDadosAnalise(transacaoData);

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

  List<Map<String, dynamic>> _extrairItensParaAnalytics(dynamic itensData) {
    List<Map<String, dynamic>> itensAnalytics = [];
    
    try {
      if (itensData is String) {
        // Tenta fazer parse como JSON primeiro (pedidos antigos)
        try {
          final List<dynamic> itensJson = jsonDecode(itensData);
          itensAnalytics = itensJson.map((item) {
            final itemMap = item as Map<String, dynamic>;
            return {
              'referencia': itemMap['cod'] ?? '',
              'quantidade': itemMap['qtd'] ?? 0,
              'valorUnitario': (itemMap['valorUnitario'] as num?)?.toDouble() ?? 0.0,
              'descontoPercentual': (itemMap['desconto'] as num?)?.toDouble() ?? 0.0,
            };
          }).toList();
        } catch (e) {
          // Se falhar, é o novo formato string - cria itens básicos a partir do texto
          final String itensTexto = itensData;
          final linhas = itensTexto.split('\n').where((linha) => linha.trim().isNotEmpty).toList();
          
          for (final linha in linhas) {
            // Pula linhas de cabeçalho e desconto
            if (linha.contains('Desconto aplicado') || linha.contains('=')) continue;
            
            final partes = linha.trim().split(' ');
            if (partes.length >= 2) {
              final codigo = partes[0];
              final quantidade = int.tryParse(partes[1]) ?? 1;
              itensAnalytics.add({
                'referencia': codigo,
                'quantidade': quantidade,
                'valorUnitario': 0.0,
                'descontoPercentual': 0.0,
              });
            }
          }
        }
      } else {
        // Formato de lista direta
        final List<dynamic> itensJson = itensData;
        itensAnalytics = itensJson.map((item) {
          final itemMap = item as Map<String, dynamic>;
          return {
            'referencia': itemMap['cod'] ?? '',
            'quantidade': itemMap['qtd'] ?? 0,
            'valorUnitario': (itemMap['valorUnitario'] as num?)?.toDouble() ?? 0.0,
            'descontoPercentual': (itemMap['desconto'] as num?)?.toDouble() ?? 0.0,
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Erro ao extrair itens para analytics: $e');
      // Se tudo falhar, retorna lista vazia
      itensAnalytics = [];
    }
    
    return itensAnalytics;
  }

  int _extrairNumeroParcelas(dynamic parcelasData) {
    if (parcelasData == null) return 1;
    
    if (parcelasData is int) {
      return parcelasData;
    }
    
    if (parcelasData is String) {
      // Extrai o número da string "X x" ou "X"
      final String parcelasString = parcelasData.trim();
      final match = RegExp(r'^(\d+)').firstMatch(parcelasString);
      if (match != null) {
        return int.tryParse(match.group(1)!) ?? 1;
      }
    }
    
    return 1;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pedidos Pendentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Atualizar Lista',
          ),
          IconButton(
            icon: _isSending 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.send_and_archive),
            onPressed: _isSending ? null : _reenviarTodosPedidos,
            tooltip: 'Reenviar Todos os Pedidos',
          ),
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
                  
                  // Tratamento para diferentes formatos de itens (antigo JSON vs novo formato string)
                  List<ItemPedido> itens = [];
                  try {
                    if (pedidoData['itens'] is String) {
                      // Tenta fazer parse como JSON primeiro (pedidos antigos)
                      try {
                        final List<dynamic> itensJson = jsonDecode(pedidoData['itens']);
                        itens = itensJson.map((item) => ItemPedido.fromJson(item as Map<String, dynamic>)).toList();
                      } catch (e) {
                        // Se falhar, é o novo formato string - cria itens básicos a partir do texto
                        final String itensTexto = pedidoData['itens'];
                        final linhas = itensTexto.split('\n').where((linha) => linha.trim().isNotEmpty).toList();
                        
                        for (final linha in linhas) {
                          // Pula linhas de cabeçalho e desconto
                          if (linha.contains('Desconto aplicado') || linha.contains('=')) continue;
                          
                          final partes = linha.trim().split(' ');
                          if (partes.length >= 2) {
                            final codigo = partes[0];
                            final quantidade = int.tryParse(partes[1]) ?? 1;
                            itens.add(ItemPedido(
                              cod: codigo,
                              descricao: 'Produto $codigo', // Descrição básica
                              qtd: quantidade,
                              valorUnitario: 0.0, // Não temos o valor no novo formato
                            ));
                          }
                        }
                      }
                    } else {
                      // Formato de lista direta
                      final List<dynamic> itensJson = pedidoData['itens'];
                      itens = itensJson.map((item) => ItemPedido.fromJson(item as Map<String, dynamic>)).toList();
                    }
                  } catch (e) {
                    // Se tudo falhar, cria uma lista vazia
                    itens = [];
                    debugPrint('Erro ao processar itens do pedido pendente: $e');
                  }

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
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          
          // Só mostra o FAB no mobile, no desktop o botão do AppBar é suficiente
          if (!isMobile) return const SizedBox.shrink();
          
          return FutureBuilder<List<PedidoPendente>>(
            future: _pedidosPendentesFuture,
            builder: (context, snapshot) {
              final hasPedidos = snapshot.hasData && snapshot.data!.isNotEmpty;
              
              return FloatingActionButton.extended(
                onPressed: (_isSending || !hasPedidos) ? null : _reenviarTodosPedidos,
                icon: _isSending 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_and_archive),
                label: Text(_isSending ? 'Enviando...' : 'Reenviar Todos'),
                backgroundColor: _isSending || !hasPedidos 
                  ? Colors.grey 
                  : Theme.of(context).primaryColor,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 400;
          
          if (isMobile) {
            // Layout mobile: título e valor em coluna
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13)),
              ],
            );
          } else {
            // Layout desktop: título e valor em linha
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(child: Text(value)),
              ],
            );
          }
        },
      ),
    );
  }
}
