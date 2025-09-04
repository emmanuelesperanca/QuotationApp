import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../api_service.dart';
import '../../database.dart';
import '../../models/item_pedido.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/pedido_provider.dart';
import 'tela_lista_produtos.dart';
import 'tela_selecao_promocao.dart';
import '../../pdf_service.dart';
import '../../models/promocao.dart'; // IMPORTAÇÃO ADICIONADA

class TelaDePedido extends StatefulWidget {
  final AppDatabase database;
  const TelaDePedido({super.key, required this.database});
  @override
  State<TelaDePedido> createState() => _TelaDePedidoState();
}

class _TelaDePedidoState extends State<TelaDePedido> {
  late PedidoProvider _pedidoProvider;
  bool _isSending = false;
  
  @override
  void initState() {
    super.initState();
    _pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    _pedidoProvider.setCodigoAssessor(auth.username ?? '');
  }

  void _abrirListaProdutos() async {
    final produtoSelecionado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaListaProdutos(database: widget.database),
      ),
    ) as Produto?;

    if (produtoSelecionado != null) {
      _pedidoProvider.adicionarProduto(produtoSelecionado);
    }
  }

  void _abrirSelecaoPromocao() async {
    final pedidoProvider = context.read<PedidoProvider>();
    if (pedidoProvider.itensPedido.isNotEmpty && !pedidoProvider.temItensPromocionais) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Atenção'),
          content: const Text('Aplicar uma promoção irá limpar os itens do seu pedido atual. Deseja continuar?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Não')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Sim')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    if (!mounted) return;
    final promocaoSelecionada = await showDialog<Promocao>(
      context: context,
      builder: (context) => const TelaSelecaoPromocao(),
    );

    if (promocaoSelecionada != null) {
      if (!mounted) return;
      await pedidoProvider.aplicarPromocao(promocaoSelecionada, context);
    }
  }

  Future<void> _mostrarConfirmacaoPedido() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pedido'),
        content: SingleChildScrollView(
          child: Consumer<PedidoProvider>(
            builder: (context, provider, child) {
               final total = provider.itensPedido.fold(0.0, (sum, item) => sum + item.valorFinal);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Por favor, confirme os detalhes do pedido antes de enviar:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text('Cliente: ${provider.clienteSelecionado?.nome ?? 'N/A'}'),
                  Text('Telefone: ${provider.telefoneController.text}'),
                  Text('Endereço de Entrega: ${ provider.usarEnderecoPrincipal ? (provider.clienteSelecionado?.enderecoCompleto ?? 'N/A') : provider.enderecoEntregaController.text }'),
                  Text('Total: R\$ ${total.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const Text('Itens:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...provider.itensPedido.map((item) => Text('- ${item.qtd}x ${item.cod}')),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Retornar para Edição')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Enviar Pedido')),
        ],
      ),
    );

    if (confirm == true) {
      _enviarPedido();
    }
  }

  Future<void> _enviarPedido() async {
    final pedidoProvider = context.read<PedidoProvider>();
    final appDataNotifier = context.read<AppDataNotifier>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (pedidoProvider.clienteSelecionado == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Por favor, selecione um cliente.'), backgroundColor: Colors.orange));
      return;
    }
    if (pedidoProvider.itensPedido.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Por favor, adicione pelo menos um item ao pedido.'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSending = true);

    final total = pedidoProvider.itensPedido.fold(0.0, (sum, item) => sum + item.valorFinal);
    final appPedidoId = const Uuid().v4();
    final String? deviceUUID = await ApiService.getDeviceUUID();
    final String version = await ApiService.getAppVersion();

    final Map<String, dynamic> pedidoData = {
      "app_pedido_id": appPedidoId,
      "cliente": pedidoProvider.clienteSelecionado!.nome,
      "retira_estande": pedidoProvider.retiraEstande,
      "endereço_padrão": pedidoProvider.usarEnderecoPrincipal,
      "email": pedidoProvider.emailController.text,
      "telefone": pedidoProvider.telefoneController.text,
      "cod_cliente": pedidoProvider.clienteSelecionado!.numeroCliente,
      "cod_assessor": pedidoProvider.codigoAssessorController.text,
      "endereco_entrega": pedidoProvider.usarEnderecoPrincipal ? pedidoProvider.clienteSelecionado!.enderecoCompleto : pedidoProvider.enderecoEntregaController.text,
      "entrega": pedidoProvider.metodoDeEntrega,
      "condicao_pagamento": pedidoProvider.metodoPagamento,
      "parcelas": (pedidoProvider.metodoPagamento == 'Boleto' || pedidoProvider.metodoPagamento == 'Cartão') ? '${pedidoProvider.parcelasCartao} x' : '1 x',
      "promocode": pedidoProvider.promocodeController.text,
      "total": total,
      "itens": jsonEncode(pedidoProvider.itensPedido.map((item) => item.toJson()).toList()),
      "obs": pedidoProvider.obsController.text,
      "pre-cadastro": pedidoProvider.clienteSelecionado is PreCadastro ? pedidoProvider.clienteSelecionado.preCadastro : '',
    };
    
    final pdfBytes = await PdfService.generateOrderPdfBytes(pedidoData);
    pedidoData['pdf_base64'] = base64Encode(pdfBytes);
    final jsonString = jsonEncode(pedidoData);
    
    final bool success = await ApiService.enviarPedido(pedidoData);

    if (!mounted) return;

    if (success) {
      await widget.database.inserePedidoEnviado(jsonString, appPedidoId);
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Pedido enviado com sucesso!'), backgroundColor: Colors.green));
    } else {
      await widget.database.inserePedidoPendente(jsonString);
      appDataNotifier.updatePendingOrderCount();
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Falha ao enviar pedido. Salvo para envio posterior.'), backgroundColor: Colors.amber));
    }

    final Map<String, dynamic> transacaoData = {
        'transacao': {
            'appPedidoUUID': appPedidoId,
            'timestampPedido': DateTime.now().toIso8601String(),
            'vendedor': {'codigoAssessor': pedidoProvider.codigoAssessorController.text},
            'dispositivo': {'deviceUUID': deviceUUID},
            'cliente': {'numeroClienteSAP': pedidoProvider.clienteSelecionado.numeroCliente, 'nome': pedidoProvider.clienteSelecionado.nome},
            'pedido': {
                'valorTotal': total,
                'condicaoPagamento': pedidoProvider.metodoPagamento,
                'parcelas': pedidoProvider.parcelasCartao,
                'metodoEntrega': pedidoProvider.metodoDeEntrega,
                'promocode': pedidoProvider.promocodeController.text,
            },
            'itens': pedidoProvider.itensPedido.map((e) => e.toJson()).toList(),
        },
        'evento': {
            'tipo': success ? 'PEDIDO_ENVIADO' : 'PEDIDO_PENDENTE',
            'versaoApp': version,
        },
    };

    await ApiService.enviarDadosAnalise(transacaoData);
    pedidoProvider.limparPedido();
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Processar Pedido'),
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded),
            onPressed: () => context.read<PedidoProvider>().limparPedido(),
            tooltip: 'Limpar Pedido',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<PedidoProvider>(
          builder: (context, provider, child) {
            final valorTotal = provider.itensPedido.fold(0.0, (sum, item) => sum + item.valorFinal);
            final hasItemSelected = provider.itensPedido.any((item) => item.isSelected);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dados do Cliente', style: Theme.of(context).textTheme.headlineSmall),
                CheckboxListTile(
                  title: const Text('Cliente em Pré-Cadastro?'),
                  value: provider.buscarPreCadastro,
                  onChanged: (value) => provider.toggleBuscaPreCadastro(),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                Autocomplete<Object>(
                  displayStringForOption: (option) {
                    if (option is Cliente) return '${option.nome} - ${option.numeroCliente}';
                    if (option is PreCadastro) return '${option.nome} - ${option.numeroCliente}';
                    return '';
                  },
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.length < 4) return const Iterable.empty();
                    return provider.buscarPreCadastro
                        ? await widget.database.searchPreCadastros(textEditingValue.text)
                        : await widget.database.searchClientes(textEditingValue.text);
                  },
                  onSelected: (selection) async {
                    String? cpfCnpj;
                    if(selection is Cliente) cpfCnpj = selection.cpfCnpj;
                    if(selection is PreCadastro) cpfCnpj = selection.cpfCnpj;
                    provider.setCliente(selection, cpfCnpj);
                    if(cpfCnpj != null) {
                      final enderecos = await widget.database.getEnderecosPorCpfCnpj(cpfCnpj);
                      provider.setEnderecosAlternativos(enderecos);
                    }
                  },
                ),
                if (provider.clienteSelecionado != null) ...[
                  const SizedBox(height: 8),
                  Text('Cliente: ${provider.clienteSelecionado!.nome}'),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: provider.telefoneController, decoration: const InputDecoration(labelText: 'Telefone'))),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          const Text('Confirmado?'),
                          Checkbox(value: provider.telefoneConfirmado, onChanged: (val) => provider.setTelefoneConfirmado(val!)),
                        ],
                      )
                    ],
                  ),
                  TextFormField(controller: provider.emailController, decoration: const InputDecoration(labelText: 'Email')),
                ],

                const Divider(height: 32),

                 // SEÇÃO DE ENTREGA E PAGAMENTO
                CheckboxListTile(
                  title: const Text('Usar endereço principal para entrega?'),
                  value: provider.usarEnderecoPrincipal,
                  onChanged: (value) => provider.setUsarEnderecoPrincipal(value!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!provider.usarEnderecoPrincipal)
                  DropdownButtonFormField<EnderecoAlternativo>(
                    value: provider.enderecoAlternativoSelecionado,
                    hint: const Text('Selecione um endereço alternativo'),
                    isExpanded: true,
                    items: [
                      ...provider.enderecosAlternativos.map((e) => DropdownMenuItem(value: e, child: Text(e.enderecoFormatado, overflow: TextOverflow.ellipsis))),
                      const DropdownMenuItem(value: null, child: Text('Outro...')),
                    ],
                    onChanged: (value) => provider.setEnderecoAlternativo(value),
                  ),
                if (!provider.usarEnderecoPrincipal && provider.mostrarCampoOutroEndereco)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: provider.enderecoEntregaController,
                      decoration: const InputDecoration(labelText: 'Digite o endereço e adicione em observações', border: OutlineInputBorder()),
                    ),
                  ),
                
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Este pedido é Retira Estande?'),
                  value: provider.retiraEstande,
                  onChanged: (value) => provider.setRetiraEstande(value!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: provider.retiraEstande ? null : provider.metodoDeEntrega,
                        hint: provider.retiraEstande ? const Text('Retirada') : null,
                        decoration: const InputDecoration(labelText: 'Entrega', border: OutlineInputBorder()),
                        items: provider.listaMetodosEntrega.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: provider.retiraEstande ? null : (value) {
                          if (value != null) provider.setMetodoEntrega(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: provider.codigoAssessorController, readOnly: true, decoration: const InputDecoration(labelText: 'Código Assessor', border: OutlineInputBorder()))),
                  ],
                ),
                
                const Divider(height: 32),
                Text('Condições de Pagamento', style: Theme.of(context).textTheme.headlineSmall),
                Row(
                  children: ['Pix', 'Boleto', 'Cartão'].map((metodo) => Expanded(
                    child: RadioListTile<String>(
                      title: Text(metodo),
                      value: metodo,
                      groupValue: provider.metodoPagamento,
                      onChanged: (value) => provider.setMetodoPagamento(value!),
                    ),
                  )).toList(),
                ),
                if (provider.metodoPagamento == 'Cartão' || provider.metodoPagamento == 'Boleto')
                  DropdownButtonFormField<int>(
                    value: provider.parcelasCartao,
                    decoration: const InputDecoration(labelText: 'Nº de Parcelas', border: OutlineInputBorder()),
                    items: List.generate(12, (index) => index + 1)
                        .map((p) => DropdownMenuItem(value: p, child: Text('$p x')))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) provider.setParcelas(value);
                    },
                  ),

                const Divider(height: 32),
                
                Row(
                  children: [
                    Expanded(child: TextField(controller: provider.promocodeController, readOnly: provider.temItensPromocionais, decoration: const InputDecoration(labelText: 'Promocode', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.card_giftcard),
                      onPressed: _abrirSelecaoPromocao,
                      tooltip: 'Selecionar Promoção',
                      iconSize: 28,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Text('Itens do Pedido', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                if(!provider.temItensPromocionais)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Autocomplete<Produto>(
                          displayStringForOption: (Produto option) => '${option.referencia} - ${option.descricao}',
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) return const Iterable<Produto>.empty();
                            return widget.database.searchProdutos(textEditingValue.text);
                          },
                          onSelected: (Produto selection) {
                            provider.adicionarProduto(selection);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        icon: const Icon(Icons.list_alt),
                        onPressed: _abrirListaProdutos,
                        tooltip: 'Selecionar da lista',
                        iconSize: 28,
                      ),
                    ],
                  ),
                
                const SizedBox(height: 16),
                if (hasItemSelected && !provider.temItensPromocionais)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: provider.descontoMassaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Desconto %', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: provider.aplicarDescontoEmMassa, child: const Text('Aplicar'))
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Checkbox(
                          value: provider.selectAllItems,
                          onChanged: provider.temItensPromocionais ? null : (value) => provider.toggleSelectAll(value!),
                        ),
                      ),
                      const DataColumn(label: Text('Descrição')),
                      const DataColumn(label: Text('Qtd')),
                      const DataColumn(label: Text('Desconto %')),
                      const DataColumn(label: Text('V. Final')),
                      const DataColumn(label: Text('Ações')),
                    ],
                    rows: provider.itensPedido.asMap().entries.map((entry) {
                      int index = entry.key;
                      ItemPedido item = entry.value;
                      return DataRow(cells: [
                        DataCell(Checkbox(
                          value: item.isSelected,
                          onChanged: item.isPromocional ? null : (value) => provider.toggleItemSelection(index, value!),
                        )),
                        DataCell(Text(item.descricao)),
                        DataCell(
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: item.qtd.toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              readOnly: item.isPromocional,
                              onChanged: (value) => provider.atualizarQtdItem(index, int.tryParse(value) ?? 1),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: provider.descontoControllers[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              readOnly: item.isPromocional,
                              decoration: const InputDecoration(hintText: ''),
                              onChanged: (value) => provider.atualizarDescontoItem(index, double.tryParse(value) ?? 0.0),
                            ),
                          ),
                        ),
                        DataCell(Text('R\$ ${item.valorFinal.toStringAsFixed(2)}')),
                        DataCell(
                          item.isPromocional 
                          ? const Icon(Icons.lock, size: 20)
                          : IconButton(icon: const Icon(Icons.close), onPressed: () => provider.removerItem(index))
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
                const Divider(height: 32),
                TextFormField(
                  controller: provider.obsController,
                  decoration: const InputDecoration(labelText: 'Observação', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL: R\$ ${valorTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium),
                    FilledButton.icon(
                      icon: _isSending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Icon(Icons.send),
                      label: Text(_isSending ? 'A Enviar...' : 'Enviar Pedido'),
                      onPressed: _isSending || !provider.telefoneConfirmado ? null : _mostrarConfirmacaoPedido,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: provider.telefoneConfirmado ? null : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

