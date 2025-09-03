import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database.dart';
import '../../models/item_pedido.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/pedido_provider.dart';
import '../../api_service.dart';
import '../../pdf_service.dart';

class TelaDePedido extends StatefulWidget {
  // Já não precisa de receber a base de dados como parâmetro
  const TelaDePedido({super.key});

  @override
  State<TelaDePedido> createState() => _TelaDePedidoState();
}

class _TelaDePedidoState extends State<TelaDePedido> {
  // Focus nodes para a lógica de aviso
  final _telefoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  bool _hasShownSapWarning = false;

  // Estado local para o envio
  bool _isSending = false;
  
  // Acesso à base de dados através do AppDataNotifier
  late AppDatabase database;

  @override
  void initState() {
    super.initState();
    database = Provider.of<AppDataNotifier>(context, listen: false).database;
    
    // Configura o código do assessor e os listeners uma única vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
      if (pedidoProvider.codigoAssessorController.text.isEmpty) {
        final auth = Provider.of<AuthNotifier>(context, listen: false);
        pedidoProvider.setCodigoAssessor(auth.username ?? '');
      }
      _telefoneFocusNode.addListener(_showSapWarningIfNeeded);
      _emailFocusNode.addListener(_showSapWarningIfNeeded);
    });
  }

  @override
  void dispose() {
    _telefoneFocusNode.removeListener(_showSapWarningIfNeeded);
    _emailFocusNode.removeListener(_showSapWarningIfNeeded);
    _telefoneFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _showSapWarningIfNeeded() {
    if ((_telefoneFocusNode.hasFocus || _emailFocusNode.hasFocus) && !_hasShownSapWarning) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aviso'),
          content: const Text('Essa edição não altera o cadastro do cliente no SAP.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      setState(() {
        _hasShownSapWarning = true;
      });
    }
  }
  
  Future<void> _abrirListaProdutos(PedidoProvider pedidoProvider) async {
    final produtoSelecionado = await Navigator.pushNamed(context, '/lista_produtos') as Produto?;
    if (produtoSelecionado != null) {
      pedidoProvider.adicionarItem(produtoSelecionado);
    }
  }

  Future<void> _mostrarConfirmacaoPedido(PedidoProvider pedidoProvider) async {
    final total = pedidoProvider.itensPedido.fold(0.0, (sum, item) => sum + item.valorFinal).toStringAsFixed(2);
    final endereco = pedidoProvider.usarEnderecoPrincipal
        ? (pedidoProvider.clienteSelecionado?.enderecoCompleto ?? 'N/A')
        : pedidoProvider.enderecoEntregaController.text;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pedido'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Por favor, confirme os detalhes do pedido:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              Text('Cliente: ${pedidoProvider.clienteSelecionado?.nome ?? 'N/A'}'),
              Text('Telefone: ${pedidoProvider.telefoneController.text}'),
              Text('Endereço de Entrega: $endereco'),
              Text('Total: R\$ $total'),
              const SizedBox(height: 8),
              const Text('Itens:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...pedidoProvider.itensPedido.map((item) => Text('- ${item.qtd}x ${item.cod}')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Retornar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Enviar Pedido')),
        ],
      ),
    );

    if (confirm == true) {
      _enviarPedido(pedidoProvider);
    }
  }

  Future<String> _getDeviceUUID() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('deviceUUID');
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString('deviceUUID', uuid);
    }
    return uuid;
  }

  Future<void> _enviarPedido(PedidoProvider pedidoProvider) async {
    if (pedidoProvider.clienteSelecionado == null || pedidoProvider.itensPedido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente e itens são obrigatórios.'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSending = true);
    
    final total = pedidoProvider.itensPedido.fold(0.0, (sum, item) => sum + item.valorFinal);
    final appPedidoId = const Uuid().v4();
    
    // Monta o JSON para a API de Pedidos (_postOrderUrl)
    final Map<String, dynamic> pedidoPostJson = {
      "app_pedido_id": appPedidoId,
      "cliente": pedidoProvider.clienteSelecionado!.nome,
      "retira_estande": pedidoProvider.retiraEstande,
      "endereço_padrão": pedidoProvider.usarEnderecoPrincipal,
      "email": pedidoProvider.emailController.text,
      "telefone": pedidoProvider.telefoneController.text,
      "cod_cliente": pedidoProvider.clienteSelecionado!.numeroCliente,
      "cod_assessor": pedidoProvider.codigoAssessorController.text,
      "endereco_entrega": pedidoProvider.usarEnderecoPrincipal 
          ? pedidoProvider.clienteSelecionado!.enderecoCompleto 
          : pedidoProvider.enderecoEntregaController.text,
      "entrega": pedidoProvider.metodoDeEntrega,
      "condicao_pagamento": pedidoProvider.metodoPagamento,
      "parcelas": (pedidoProvider.metodoPagamento == 'Boleto' || pedidoProvider.metodoPagamento == 'Cartão') 
          ? '${pedidoProvider.parcelasCartao} x' : '1 x',
      "promocode": pedidoProvider.promocodeController.text,
      "total": total,
      "itens": jsonEncode(pedidoProvider.itensPedido.map((item) => item.toJson()).toList()),
      "obs": pedidoProvider.obsController.text,
      "pre-cadastro": pedidoProvider.clienteSelecionado is PreCadastro 
          ? pedidoProvider.clienteSelecionado.preCadastro : '',
    };
    
    // Gera o PDF e adiciona ao JSON
    try {
        final pdfBytes = await PdfService.generateOrderPdfBytes(pedidoPostJson);
        pedidoPostJson['pdf_base64'] = base64Encode(pdfBytes);
    } catch (e) {
        debugPrint("Erro ao gerar PDF: $e");
        pedidoPostJson['pdf_base64'] = ''; // Envia vazio se falhar
    }

    final jsonStringParaSalvar = jsonEncode(pedidoPostJson);

    bool sucesso = false;
    try {
      sucesso = await ApiService.enviarPedido(pedidoPostJson);
      if (sucesso) {
        await database.inserePedidoEnviado(jsonStringParaSalvar, appPedidoId);
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido enviado com sucesso!'), backgroundColor: Colors.green));
        }
      } else {
        throw Exception("Falha no servidor (status code não foi 2xx)");
      }
    } catch (e) {
      await database.inserePedidoPendente(jsonStringParaSalvar);
      if(mounted) {
        Provider.of<AppDataNotifier>(context, listen: false).updatePendingOrderCount();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro de conexão: $e. Pedido salvo para envio posterior.'), backgroundColor: Colors.amber));
      }
    }

    // Envia os dados para a API de análise, independentemente do sucesso do envio do pedido
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceUUID = await _getDeviceUUID();

      final Map<String, dynamic> analyticsJson = {
        "transacao": {
          "appPedidoUUID": appPedidoId,
          "timestampPedido": DateTime.now().toUtc().toIso8601String(),
          "vendedor": {"codigoAssessor": pedidoProvider.codigoAssessorController.text},
          "dispositivo": {"deviceUUID": deviceUUID},
          "cliente": {
            "numeroClienteSAP": pedidoProvider.clienteSelecionado.numeroCliente,
            "nome": pedidoProvider.clienteSelecionado.nome
          },
          "pedido": {
            "valorTotal": total,
            "condicaoPagamento": pedidoProvider.metodoPagamento,
            "parcelas": pedidoProvider.parcelasCartao,
            "metodoEntrega": pedidoProvider.metodoDeEntrega,
            "promocode": pedidoProvider.promocodeController.text
          },
          "itens": pedidoProvider.itensPedido.map((item) => {
            "referencia": item.cod,
            "quantidade": item.qtd,
            "valorUnitario": item.valorUnitario,
            "descontoPercentual": item.desconto
          }).toList()
        },
        "evento": {
          "tipo": sucesso ? "PEDIDO_ENVIADO" : "PEDIDO_PENDENTE",
          "versaoApp": packageInfo.version
        }
      };
      await ApiService.enviarDadosAnalise(analyticsJson);
    } catch (e) {
      debugPrint("Falha ao enviar dados de análise: $e");
      // Não notificar o utilizador, pois esta é uma operação de fundo
    }
    
    // Limpa o formulário e finaliza o loading
    if(mounted) {
      setState(() => _isSending = false);
      pedidoProvider.limparPedido();
    }
  }


  @override
  Widget build(BuildContext context) {
    // Usa o Consumer para reconstruir o widget quando o provider notificar
    return Consumer<PedidoProvider>(
      builder: (context, pedidoProvider, child) {
        final valorTotal = pedidoProvider.itensPedido.fold(0.0, (sum, item) => sum + item.valorFinal);
        final hasItemSelected = pedidoProvider.itensPedido.any((item) => item.isSelected);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Processar Pedido'),
            backgroundColor: Colors.black.withOpacity(0.5),
            actions: [
              IconButton(
                icon: const Icon(Icons.cleaning_services_rounded),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Limpar Pedido'),
                      content: const Text('Tem a certeza de que deseja limpar todos os campos deste pedido?'),
                      actions: [
                        TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop(false)),
                        FilledButton(child: const Text('Limpar'), onPressed: () => Navigator.of(ctx).pop(true)),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    pedidoProvider.limparPedido();
                  }
                },
                tooltip: 'Limpar Formulário',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dados do Cliente', style: Theme.of(context).textTheme.headlineSmall),
                CheckboxListTile(
                  title: const Text('Cliente em Pré-Cadastro?'),
                  value: pedidoProvider.buscarPreCadastro,
                  onChanged: (value) => pedidoProvider.toggleBuscarPreCadastro(value!),
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
                    if (pedidoProvider.buscarPreCadastro) {
                      return await database.searchPreCadastros(textEditingValue.text);
                    }
                    return await database.searchClientes(textEditingValue.text);
                  },
                  onSelected: (selection) {
                    pedidoProvider.setCliente(selection, database);
                    _hasShownSapWarning = false;
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    // Limpa o campo se o utilizador apagar o texto
                    if (pedidoProvider.clienteSelecionado != null && textEditingController.text.isEmpty) {
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                           pedidoProvider.limparPedido();
                       });
                    }
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Buscar Cliente...', border: OutlineInputBorder()),
                    );
                  },
                ),
                if (pedidoProvider.clienteSelecionado != null) ...[
                  const SizedBox(height: 8),
                  Text('Cliente: ${pedidoProvider.clienteSelecionado!.nome}'),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: pedidoProvider.telefoneController, focusNode: _telefoneFocusNode, decoration: const InputDecoration(labelText: 'Telefone'))),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          const Text('Confirmado?'),
                          Checkbox(value: pedidoProvider.telefoneConfirmado, onChanged: (val) => pedidoProvider.setTelefoneConfirmado(val!)),
                        ],
                      )
                    ],
                  ),
                  TextFormField(controller: pedidoProvider.emailController, focusNode: _emailFocusNode, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 8),
                  Card(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    child: ListTile(
                      leading: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
                      title: const Text('Endereço Principal'),
                      subtitle: Text(pedidoProvider.clienteSelecionado!.enderecoCompleto ?? 'Endereço não disponível'),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text('Usar este endereço para entrega?'),
                    value: pedidoProvider.usarEnderecoPrincipal,
                    onChanged: (value) => pedidoProvider.toggleUsarEnderecoPrincipal(value!),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (!pedidoProvider.usarEnderecoPrincipal)
                    Column(
                      children: [
                        DropdownButtonFormField<EnderecoAlternativo>(
                          value: pedidoProvider.enderecoAlternativoSelecionado,
                          hint: const Text('Selecione um endereço alternativo'),
                          isExpanded: true,
                          items: [
                            ...pedidoProvider.enderecosAlternativos.map((e) => DropdownMenuItem(value: e, child: Text(e.enderecoFormatado, overflow: TextOverflow.ellipsis))),
                            const DropdownMenuItem(value: null, child: Text('Outro...')),
                          ],
                          onChanged: (value) => pedidoProvider.setEnderecoAlternativo(value),
                        ),
                        if (pedidoProvider.mostrarCampoOutroEndereco)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextField(
                              controller: pedidoProvider.enderecoEntregaController,
                              decoration: const InputDecoration(labelText: 'Digite o endereço e adicione em observações', border: OutlineInputBorder()),
                              onChanged: (text) {
                                pedidoProvider.obsController.text = "Endereço de entrega alternativo: $text";
                              },
                            ),
                          ),
                      ],
                    ),
                ],
                const Divider(height: 32),
                CheckboxListTile(
                  title: const Text('Este pedido é Retira Estande?'),
                  value: pedidoProvider.retiraEstande,
                  onChanged: (value) => pedidoProvider.toggleRetiraEstande(value!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: pedidoProvider.metodoDeEntrega,
                        decoration: const InputDecoration(labelText: 'Entrega', border: OutlineInputBorder()),
                        items: ["Padrão", "Motoboy", "Correios", "Retira Loja"].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                        onChanged: (value) => pedidoProvider.setMetodoEntrega(value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: pedidoProvider.codigoAssessorController, readOnly: true, decoration: const InputDecoration(labelText: 'Código Assessor', border: OutlineInputBorder()))),
                  ],
                ),
                const Divider(height: 32),
                Text('Condições de Pagamento', style: Theme.of(context).textTheme.headlineSmall),
                Row(
                  children: ['Pix', 'Boleto', 'Cartão'].map((metodo) => Expanded(
                    child: RadioListTile<String>(
                      title: Text(metodo),
                      value: metodo,
                      groupValue: pedidoProvider.metodoPagamento,
                      onChanged: (value) => pedidoProvider.setMetodoPagamento(value!),
                    ),
                  )).toList(),
                ),
                if (pedidoProvider.metodoPagamento == 'Cartão' || pedidoProvider.metodoPagamento == 'Boleto')
                  DropdownButtonFormField<int>(
                    value: pedidoProvider.parcelasCartao,
                    decoration: const InputDecoration(labelText: 'Nº de Parcelas', border: OutlineInputBorder()),
                    items: List.generate(12, (index) => index + 1)
                        .map((p) => DropdownMenuItem(value: p, child: Text('$p x')))
                        .toList(),
                    onChanged: (value) => pedidoProvider.setParcelas(value!),
                  ),
                const Divider(height: 32),
                TextField(controller: pedidoProvider.promocodeController, decoration: const InputDecoration(labelText: 'Promocode', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                Text('Itens do Pedido', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Autocomplete<Produto>(
                        displayStringForOption: (Produto option) => '${option.referencia} - ${option.descricao}',
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) return const Iterable<Produto>.empty();
                          return database.searchProdutos(textEditingValue.text);
                        },
                        onSelected: (Produto selection) {
                          pedidoProvider.adicionarItem(selection);
                        },
                        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(labelText: 'Buscar Produto...', border: OutlineInputBorder()),
                            onFieldSubmitted: (_) => textEditingController.clear(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.list_alt),
                      onPressed: () => _abrirListaProdutos(pedidoProvider),
                      tooltip: 'Selecionar da lista',
                      iconSize: 28,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                if (hasItemSelected)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: pedidoProvider.descontoMassaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Desconto %', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: () {
                          pedidoProvider.aplicarDescontoEmMassa();
                          FocusScope.of(context).unfocus();
                        }, child: const Text('Aplicar'))
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Checkbox(
                          value: pedidoProvider.selectAllItems,
                          onChanged: (value) => pedidoProvider.toggleSelectAllItems(value!),
                        ),
                      ),
                      const DataColumn(label: Text('Descrição')),
                      const DataColumn(label: Text('Qtd')),
                      const DataColumn(label: Text('Desconto %')),
                      const DataColumn(label: Text('V. Final')),
                      const DataColumn(label: Text('Ações')),
                    ],
                    rows: pedidoProvider.itensPedido.asMap().entries.map((entry) {
                      int index = entry.key;
                      ItemPedido item = entry.value;
                      return DataRow(cells: [
                        DataCell(Checkbox(
                          value: item.isSelected,
                          onChanged: (value) => pedidoProvider.toggleSelectItem(index, value!),
                        )),
                        DataCell(Text(item.descricao)),
                        DataCell(
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: item.qtd.toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: (value) => pedidoProvider.atualizarQuantidadeItem(index, int.tryParse(value) ?? 1),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              controller: pedidoProvider.descontoControllers[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: (value) => pedidoProvider.atualizarDescontoItem(index, double.tryParse(value) ?? 0.0),
                            ),
                          ),
                        ),
                        DataCell(Text('R\$ ${item.valorFinal.toStringAsFixed(2)}')),
                        DataCell(IconButton(icon: const Icon(Icons.close), onPressed: () => pedidoProvider.removerItem(index))),
                      ]);
                    }).toList(),
                  ),
                ),
                const Divider(height: 32),
                TextFormField(
                  controller: pedidoProvider.obsController,
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
                      onPressed: _isSending || !pedidoProvider.telefoneConfirmado ? null : () => _mostrarConfirmacaoPedido(pedidoProvider),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: pedidoProvider.telefoneConfirmado ? null : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

