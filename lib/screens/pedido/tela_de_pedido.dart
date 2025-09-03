import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:order_simulator/api_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../database.dart';
import '../../models/item_pedido.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/app_data_notifier.dart';

class TelaDePedido extends StatefulWidget {
  final AppDatabase database;
  const TelaDePedido({super.key, required this.database});
  @override
  State<TelaDePedido> createState() => _TelaDePedidoState();
}

class _TelaDePedidoState extends State<TelaDePedido> {
  dynamic _clienteSelecionado;
  bool _buscarPreCadastro = false;
  bool _usarEnderecoPrincipal = true;
  String _metodoPagamento = 'Pix';
  int _parcelasCartao = 1;
  final List<ItemPedido> _itensPedido = [];
  
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _codigoAssessorController = TextEditingController();
  final _enderecoEntregaController = TextEditingController();
  final _promocodeController = TextEditingController();
  final _obsController = TextEditingController();
  final _telefoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  bool _hasShownSapWarning = false;
  bool _retiraEstande = false;
  String _metodoDeEntrega = "Padrão";
  final List<String> _listaMetodosEntrega = ["Motoboy", "Correios", "Padrão"];
  bool _isSending = false;
  bool _selectAllItems = false;
  final _descontoMassaController = TextEditingController();
  
  final List<TextEditingController> _descontoControllers = [];
  
  bool _telefoneConfirmado = false;
  List<EnderecoAlternativo> _enderecosAlternativos = [];
  EnderecoAlternativo? _enderecoAlternativoSelecionado;
  bool _mostrarCampoOutroEndereco = false;

  String? _deviceUUID;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _telefoneFocusNode.addListener(_showSapWarningIfNeeded);
    _emailFocusNode.addListener(_showSapWarningIfNeeded);
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    _codigoAssessorController.text = auth.username ?? '';
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    // Carrega o UUID do dispositivo
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('deviceUUID');
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString('deviceUUID', uuid);
    }
    
    // Carrega a versão do app
    final packageInfo = await PackageInfo.fromPlatform();
    
    setState(() {
      _deviceUUID = uuid;
      _appVersion = packageInfo.version;
    });
  }

  @override
  void dispose() {
    _telefoneController.dispose();
    _emailController.dispose();
    _codigoAssessorController.dispose();
    _enderecoEntregaController.dispose();
    _promocodeController.dispose();
    _obsController.dispose();
    _telefoneFocusNode.removeListener(_showSapWarningIfNeeded);
    _emailFocusNode.removeListener(_showSapWarningIfNeeded);
    _telefoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _descontoMassaController.dispose();
    for (var controller in _descontoControllers) {
      controller.dispose();
    }
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
  
  Future<void> _buscarEnderecosAlternativos(String? cpfCnpj) async {
    if (cpfCnpj == null || cpfCnpj.isEmpty) {
      setState(() => _enderecosAlternativos = []);
      return;
    }
    final enderecos = await widget.database.getEnderecosPorCpfCnpj(cpfCnpj);
    setState(() {
      _enderecosAlternativos = enderecos;
      _enderecoAlternativoSelecionado = null;
      _mostrarCampoOutroEndereco = false;
    });
  }

  void _adicionarProduto(Produto produto) {
    setState(() {
      _itensPedido.add(ItemPedido(
        cod: produto.referencia,
        descricao: produto.descricao,
        valorUnitario: produto.valor,
      ));
      _descontoControllers.add(TextEditingController());
    });
  }

  void _removerItem(int index) {
    setState(() {
      _itensPedido.removeAt(index);
      _descontoControllers.removeAt(index).dispose();
    });
  }
  
  void _aplicarDescontoEmMassa() {
    final desconto = double.tryParse(_descontoMassaController.text) ?? 0.0;
    setState(() {
      for (int i = 0; i < _itensPedido.length; i++) {
        if (_itensPedido[i].isSelected) {
          _itensPedido[i].desconto = desconto;
          _descontoControllers[i].text = desconto.toString();
        }
      }
    });
    _descontoMassaController.clear();
    FocusScope.of(context).unfocus();
  }

  void _abrirListaProdutos() async {
    final produtoSelecionado = await Navigator.pushNamed(context, '/lista_produtos') as Produto?;
    if (produtoSelecionado != null) {
      _adicionarProduto(produtoSelecionado);
    }
  }

  Future<void> _limparFormulario() async {
    bool confirm = true;
    if (_clienteSelecionado != null || _itensPedido.isNotEmpty) {
      confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Limpar Pedido'),
          content: const Text('Tem a certeza de que deseja apagar todos os dados do pedido atual?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Limpar')),
          ],
        ),
      ) ?? false;
    }

    if (confirm) {
      setState(() {
        _clienteSelecionado = null;
        _buscarPreCadastro = false;
        _usarEnderecoPrincipal = true;
        _metodoPagamento = 'Pix';
        _parcelasCartao = 1;
        _itensPedido.clear();
        _descontoControllers.forEach((c) => c.dispose());
        _descontoControllers.clear();
        _telefoneController.clear();
        _emailController.clear();
        _enderecoEntregaController.clear();
        _promocodeController.clear();
        _obsController.clear();
        _hasShownSapWarning = false;
        _retiraEstande = false;
        _metodoDeEntrega = "Padrão";
        _selectAllItems = false;
        _descontoMassaController.clear();
        _telefoneConfirmado = false;
        _enderecosAlternativos.clear();
        _enderecoAlternativoSelecionado = null;
        _mostrarCampoOutroEndereco = false;
      });
    }
  }

  Future<void> _mostrarConfirmacaoPedido() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pedido'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Por favor, confirme os detalhes do pedido antes de enviar:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              Text('Cliente: ${_clienteSelecionado?.nome ?? 'N/A'}'),
              Text('Telefone: ${_telefoneController.text}'),
              Text('Endereço de Entrega: ${ _usarEnderecoPrincipal ? (_clienteSelecionado?.enderecoCompleto ?? 'N/A') : _enderecoEntregaController.text }'),
              Text('Total: R\$ ${_itensPedido.fold(0.0, (sum, item) => sum + item.valorFinal).toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              const Text('Itens:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._itensPedido.map((item) => Text('- ${item.qtd}x ${item.cod}')),
            ],
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
    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione um cliente.'), backgroundColor: Colors.orange));
      return;
    }
    if (_itensPedido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, adicione pelo menos um item ao pedido.'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSending = true);

    final total = _itensPedido.fold(0.0, (sum, item) => sum + item.valorFinal);
    final appPedidoId = const Uuid().v4();

    final Map<String, dynamic> pedidoJson = {
      "app_pedido_id": appPedidoId,
      "cliente": _clienteSelecionado!.nome,
      "retira_estande": _retiraEstande,
      "endereço_padrão": _usarEnderecoPrincipal,
      "email": _emailController.text,
      "telefone": _telefoneController.text,
      "cod_cliente": _clienteSelecionado!.numeroCliente,
      "cod_assessor": _codigoAssessorController.text,
      "endereco_entrega": _usarEnderecoPrincipal ? _clienteSelecionado!.enderecoCompleto : _enderecoEntregaController.text,
      "entrega": _metodoDeEntrega,
      "condicao_pagamento": _metodoPagamento,
      "parcelas": (_metodoPagamento == 'Boleto' || _metodoPagamento == 'Cartão') ? '$_parcelasCartao x' : '1 x',
      "promocode": _promocodeController.text,
      "total": total,
      "itens": _itensPedido.map((item) => item.toJson()).toList(),
      "obs": _obsController.text,
      "pre-cadastro": _clienteSelecionado is PreCadastro ? _clienteSelecionado.preCadastro : '',
    };
    
    bool sucesso = false;
    String motivoFalha = '';

    try {
      final response = await http.post(
        Uri.parse("https://prod-50.westeurope.logic.azure.com:443/workflows/e273fbdc9d274955b78906f65fabc86a/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=57sZ3srSrWagjZjlRv33ptPHxmiLQFlGv-4Mo8DnHIo"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pedidoJson),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        sucesso = true;
      } else {
        motivoFalha = 'Falha no servidor: ${response.statusCode}';
      }
    } catch (e) {
      motivoFalha = 'Erro de rede ou timeout';
    }

    // Enviar dados de análise independentemente do resultado do pedido principal
    _enviarDadosAnaliticos(sucesso ? "PEDIDO_ENVIADO" : "PEDIDO_PENDENTE", appPedidoId, total);

    if (sucesso) {
      await _salvarPedidoEnviado(jsonEncode(pedidoJson), appPedidoId);
      _limparFormularioAposEnvio();
    } else {
      await _salvarPedidoPendente(jsonEncode(pedidoJson), motivoFalha);
      _limparFormularioAposEnvio();
    }

    setState(() => _isSending = false);
  }

  void _limparFormularioAposEnvio() {
    setState(() {
      _clienteSelecionado = null;
      _buscarPreCadastro = false;
      _usarEnderecoPrincipal = true;
      _metodoPagamento = 'Pix';
      _parcelasCartao = 1;
      _itensPedido.clear();
      _descontoControllers.forEach((c) => c.dispose());
      _descontoControllers.clear();
      _telefoneController.clear();
      _emailController.clear();
      _enderecoEntregaController.clear();
      _promocodeController.clear();
      _obsController.clear();
      _hasShownSapWarning = false;
      _retiraEstande = false;
      _metodoDeEntrega = "Padrão";
      _selectAllItems = false;
      _descontoMassaController.clear();
      _telefoneConfirmado = false;
      _enderecosAlternativos.clear();
      _enderecoAlternativoSelecionado = null;
      _mostrarCampoOutroEndereco = false;
    });
  }

  Future<void> _enviarDadosAnaliticos(String tipoEvento, String appPedidoId, double total) async {
    final analyticsPayload = {
      "transacao": {
        "appPedidoUUID": appPedidoId,
        "timestampPedido": DateTime.now().toUtc().toIso8601String(),
        "vendedor": {
          "codigoAssessor": _codigoAssessorController.text,
        },
        "dispositivo": {
          "deviceUUID": _deviceUUID,
        },
        "cliente": {
          "numeroClienteSAP": _clienteSelecionado!.numeroCliente,
          "nome": _clienteSelecionado!.nome,
        },
        "pedido": {
          "valorTotal": total,
          "condicaoPagamento": _metodoPagamento,
          "parcelas": _parcelasCartao,
          "metodoEntrega": _metodoDeEntrega,
          "promocode": _promocodeController.text,
        },
        "itens": _itensPedido.map((item) => {
          "referencia": item.cod,
          "quantidade": item.qtd,
          "valorUnitario": item.valorUnitario,
          "descontoPercentual": item.desconto,
        }).toList(),
      },
      "evento": {
        "tipo": tipoEvento,
        "versaoApp": _appVersion,
      }
    };

    // Envio em "fire-and-forget"
    ApiService.enviarDadosAnaliticos(analyticsPayload);
  }

  Future<void> _salvarPedidoPendente(String json, String motivo) async {
    await widget.database.inserePedidoPendente(json);
    if(mounted) {
      Provider.of<AppDataNotifier>(context, listen: false).updatePendingOrderCount();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$motivo. Pedido salvo para envio posterior.'), backgroundColor: Colors.amber));
    }
  }
  
  Future<void> _salvarPedidoEnviado(String json, String appPedidoId) async {
    await widget.database.inserePedidoEnviado(json, appPedidoId);
     if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido enviado com sucesso!'), backgroundColor: Colors.green));
    }
  }


  @override
  Widget build(BuildContext context) {
    double valorTotal = _itensPedido.fold(0.0, (sum, item) => sum + item.valorFinal);
    bool hasItemSelected = _itensPedido.any((item) => item.isSelected);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Processar Pedido'), 
        backgroundColor: Colors.black.withOpacity(0.5),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _limparFormulario,
            tooltip: 'Limpar Pedido',
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
              value: _buscarPreCadastro,
              onChanged: (value) {
                setState(() {
                  _buscarPreCadastro = value!;
                  _clienteSelecionado = null;
                });
              },
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
                if (_buscarPreCadastro) {
                  return await widget.database.searchPreCadastros(textEditingValue.text);
                }
                return await widget.database.searchClientes(textEditingValue.text);
              },
              onSelected: (selection) {
                setState(() {
                  _clienteSelecionado = selection;
                  String? cpfCnpj;
                  if (selection is Cliente) {
                    _telefoneController.text = selection.telefone1 ?? '';
                    _emailController.text = selection.email ?? '';
                    cpfCnpj = selection.cpfCnpj;
                  } else if (selection is PreCadastro) {
                    _telefoneController.text = selection.telefone1 ?? '';
                    _emailController.text = selection.email ?? '';
                    cpfCnpj = selection.cpfCnpj;
                  }
                  _buscarEnderecosAlternativos(cpfCnpj);
                  _hasShownSapWarning = false;
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Buscar Cliente por Nome, CPF/CNPJ ou Código', border: OutlineInputBorder()),
                );
              },
            ),
            if (_clienteSelecionado != null) ...[
              const SizedBox(height: 8),
              Text('Cliente: ${_clienteSelecionado!.nome}'),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _telefoneController, focusNode: _telefoneFocusNode, decoration: const InputDecoration(labelText: 'Telefone'))),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      const Text('Confirmado?'),
                      Checkbox(value: _telefoneConfirmado, onChanged: (val) => setState(() => _telefoneConfirmado = val!)),
                    ],
                  )
                ],
              ),
              TextFormField(controller: _emailController, focusNode: _emailFocusNode, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                child: ListTile(
                  leading: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Endereço Principal'),
                  subtitle: Text(_clienteSelecionado!.enderecoCompleto ?? 'Endereço não disponível'),
                ),
              ),
              CheckboxListTile(
                title: const Text('Usar este endereço para entrega?'),
                value: _usarEnderecoPrincipal,
                onChanged: (value) => setState(() => _usarEnderecoPrincipal = value!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (!_usarEnderecoPrincipal)
                Column(
                  children: [
                    DropdownButtonFormField<EnderecoAlternativo>(
                      value: _enderecoAlternativoSelecionado,
                      hint: const Text('Selecione um endereço alternativo'),
                      isExpanded: true,
                      items: [
                        ..._enderecosAlternativos.map((e) => DropdownMenuItem(value: e, child: Text(e.enderecoFormatado, overflow: TextOverflow.ellipsis))),
                        const DropdownMenuItem(value: null, child: Text('Outro...')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _enderecoAlternativoSelecionado = value;
                          _mostrarCampoOutroEndereco = (value == null);
                          if (value != null) {
                            _enderecoEntregaController.text = value.enderecoFormatado;
                          } else {
                            _enderecoEntregaController.clear();
                          }
                        });
                      },
                    ),
                    if (_mostrarCampoOutroEndereco)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextField(
                          controller: _enderecoEntregaController,
                          decoration: const InputDecoration(labelText: 'Digite o endereço e adicione em observações', border: OutlineInputBorder()),
                          onChanged: (text) {
                            _obsController.text = "Endereço de entrega alternativo: $text";
                          },
                        ),
                      ),
                  ],
                ),
            ],
            const Divider(height: 32),
            CheckboxListTile(
              title: const Text('Este pedido é Retira Estande?'),
              value: _retiraEstande,
              onChanged: (value) {
                setState(() {
                  _retiraEstande = value!;
                  if (_retiraEstande) {
                    _metodoDeEntrega = 'Retirada';
                  } else {
                    _metodoDeEntrega = 'Padrão';
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _retiraEstande ? null : _metodoDeEntrega,
                    hint: _retiraEstande ? const Text('Retirada') : null,
                    decoration: const InputDecoration(labelText: 'Entrega', border: OutlineInputBorder()),
                    items: _listaMetodosEntrega.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: _retiraEstande ? null : (value) {
                      if (value != null) {
                        setState(() => _metodoDeEntrega = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _codigoAssessorController, readOnly: true, decoration: const InputDecoration(labelText: 'Código Assessor', border: OutlineInputBorder()))),
              ],
            ),
            const Divider(height: 32),
            Text('Condições de Pagamento', style: Theme.of(context).textTheme.headlineSmall),
            Row(
              children: ['Pix', 'Boleto', 'Cartão'].map((metodo) => Expanded(
                child: RadioListTile<String>(
                  title: Text(metodo),
                  value: metodo,
                  groupValue: _metodoPagamento,
                  onChanged: (value) => setState(() => _metodoPagamento = value!),
                ),
              )).toList(),
            ),
            if (_metodoPagamento == 'Cartão' || _metodoPagamento == 'Boleto')
              DropdownButtonFormField<int>(
                value: _parcelasCartao,
                decoration: const InputDecoration(labelText: 'Nº de Parcelas', border: OutlineInputBorder()),
                items: List.generate(12, (index) => index + 1)
                    .map((p) => DropdownMenuItem(value: p, child: Text('$p x')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _parcelasCartao = value);
                  }
                },
              ),
            const Divider(height: 32),
            TextField(controller: _promocodeController, decoration: const InputDecoration(labelText: 'Promocode', border: OutlineInputBorder())),
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
                      return widget.database.searchProdutos(textEditingValue.text);
                    },
                    onSelected: (Produto selection) {
                      _adicionarProduto(selection);
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Buscar Produto por Cód. ou Descrição', border: OutlineInputBorder()),
                        onFieldSubmitted: (_) => textEditingController.clear(),
                      );
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
            if (hasItemSelected)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: _descontoMassaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Desconto %', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _aplicarDescontoEmMassa, child: const Text('Aplicar'))
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Checkbox(
                      value: _selectAllItems,
                      onChanged: (value) {
                        setState(() {
                          _selectAllItems = value!;
                          for (var item in _itensPedido) {
                            item.isSelected = _selectAllItems;
                          }
                        });
                      },
                    ),
                  ),
                  const DataColumn(label: Text('Descrição')),
                  const DataColumn(label: Text('Qtd')),
                  const DataColumn(label: Text('Desconto %')),
                  const DataColumn(label: Text('V. Final')),
                  const DataColumn(label: Text('Ações')),
                ],
                rows: _itensPedido.asMap().entries.map((entry) {
                  int index = entry.key;
                  ItemPedido item = entry.value;
                  return DataRow(cells: [
                    DataCell(Checkbox(
                      value: item.isSelected,
                      onChanged: (value) => setState(() => item.isSelected = value!),
                    )),
                    DataCell(Text(item.descricao)),
                    DataCell(
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          initialValue: item.qtd.toString(),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (value) => setState(() => item.qtd = int.tryParse(value) ?? 1),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: _descontoControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '',
                          ),
                          onChanged: (value) => setState(() => item.desconto = double.tryParse(value) ?? 0.0),
                        ),
                      ),
                    ),
                    DataCell(Text('R\$ ${item.valorFinal.toStringAsFixed(2)}')),
                    DataCell(IconButton(icon: const Icon(Icons.close), onPressed: () => _removerItem(index))),
                  ]);
                }).toList(),
              ),
            ),
            const Divider(height: 32),
            TextFormField(
              controller: _obsController,
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
                  onPressed: _isSending || !_telefoneConfirmado ? null : _mostrarConfirmacaoPedido,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: _telefoneConfirmado ? null : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

