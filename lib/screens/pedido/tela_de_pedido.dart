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
import '../../services/config_service.dart';
import '../../widgets/seletor_condicoes_pagamento.dart';
import 'tela_lista_produtos.dart';
import 'tela_catalogo_promocoes.dart';
import '../../pdf_service.dart';

class TelaDePedido extends StatefulWidget {
  final AppDatabase database;
  const TelaDePedido({super.key, required this.database});
  @override
  State<TelaDePedido> createState() => _TelaDePedidoState();
}

class _TelaDePedidoState extends State<TelaDePedido> {
  late PedidoProvider _pedidoProvider;
  bool _isSending = false;
  bool _configCheckScheduled = false; // Flag para evitar múltiplas verificações
  
  @override
  void initState() {
    super.initState();
    _pedidoProvider = Provider.of<PedidoProvider>(context, listen: false);
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    _pedidoProvider.setCodigoAssessor(auth.username ?? '');
    
    // Adiciona listener para o campo de endereço alternativo
    _pedidoProvider.enderecoEntregaController.addListener(_onEnderecoAlternativoChanged);
    
    // Agenda verificação de configuração remota apenas uma vez
    _scheduleConfigCheck();
  }

  void _scheduleConfigCheck() {
    if (!_configCheckScheduled) {
      _configCheckScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ConfigService.checkRemoteConfig(context);
        }
      });
    }
  }
  
  @override
  void dispose() {
    _pedidoProvider.enderecoEntregaController.removeListener(_onEnderecoAlternativoChanged);
    super.dispose();
  }
  
  void _onEnderecoAlternativoChanged() {
    final endereco = _pedidoProvider.enderecoEntregaController.text.trim();
    if (endereco.isNotEmpty) {
      _pedidoProvider.adicionarEnderecoNasObservacoes(endereco);
    } else {
      _pedidoProvider.removerEnderecoNasObservacoes();
    }
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

  void _abrirCatalogoPromocoes() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TelaCatalogoPromocoes(),
      ),
    );
  }

  Future<void> _mostrarConfirmacaoPedido() async {
    if (!mounted) return;
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

  void _mostrarAvisoEdicaoCliente() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Aviso Importante'),
          ],
        ),
        content: const Text('Esta alteração não será aplicada ao cadastro do cliente no SAP, apenas para este pedido específico.\n\nOs dados originais do cliente permanecerão inalterados no sistema.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  String _formatarItensParaAPI(List<ItemPedido> itens) {
    final StringBuffer buffer = StringBuffer();
    
    // Primeira parte: código e quantidade
    for (final item in itens) {
      buffer.writeln('${item.cod} ${item.qtd}');
    }
    
    // Adiciona uma linha vazia
    buffer.writeln();
    
    // Segunda parte: descontos aplicados
    buffer.writeln('Desconto aplicado');
    for (final item in itens) {
      buffer.writeln('${item.cod} = ${item.desconto.toStringAsFixed(1)}%');
    }
    
    return buffer.toString().trim();
  }

  int _getParcelasParaEnvio(PedidoProvider provider) {
    // Para BR77 (Cartão de Crédito Manual), usa as parcelas selecionadas pelo usuário
    if (provider.condicaoPagamentoSelecionada?.codigo == 'BR77') {
      return provider.parcelasSelecionadas ?? 1;
    }
    // Para outras condições, usa o máximo de parcelas definido
    return provider.condicaoPagamentoSelecionada?.parcelasMaximas ?? 1;
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
    if (pedidoProvider.condicaoPagamentoSelecionada == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Por favor, selecione uma condição de pagamento.'), backgroundColor: Colors.orange));
      return;
    }
    // Validação específica para BR77 (Cartão de Crédito Manual)
    if (pedidoProvider.condicaoPagamentoSelecionada?.codigo == 'BR77' && pedidoProvider.parcelasSelecionadas == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Por favor, selecione o número de parcelas para Cartão de Crédito Manual.'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSending = true);

    try {
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
        "condicao_pagamento": pedidoProvider.condicaoPagamentoSelecionada?.codigo ?? '',
        "condicao_pagamento_descricao": pedidoProvider.condicaoPagamentoSelecionada?.descricao ?? '',
        "parcelas": pedidoProvider.condicaoPagamentoSelecionada?.permiteParcelamento == true 
            ? '${_getParcelasParaEnvio(pedidoProvider)} x' 
            : '1 x',
        "promocode": pedidoProvider.promocodeController.text,
        "total": total,
        "itens": _formatarItensParaAPI(pedidoProvider.itensPedido),
        "obs": pedidoProvider.obsController.text,
        "pre-cadastro": pedidoProvider.clienteSelecionado is PreCadastro ? pedidoProvider.clienteSelecionado.preCadastro : '',
      };

      // Cria uma versão separada para o PDF com itens em formato JSON
      final Map<String, dynamic> pedidoDataPdf = Map.from(pedidoData);
      pedidoDataPdf['itens'] = jsonEncode(pedidoProvider.itensPedido.map((item) => item.toJson()).toList());
      
      final pdfBytes = await PdfService.generateOrderPdfBytes(pedidoDataPdf);
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
              'cliente': {'numeroClienteSAP': pedidoProvider.clienteSelecionado!.numeroCliente, 'nome': pedidoProvider.clienteSelecionado!.nome},
              'pedido': {
                  'valorTotal': total,
                  'condicaoPagamento': pedidoProvider.condicaoPagamentoSelecionada?.codigo ?? '',
                  'condicaoPagamentoDescricao': pedidoProvider.condicaoPagamentoSelecionada?.descricao ?? '',
                  'parcelas': _getParcelasParaEnvio(pedidoProvider),
                  'metodoEntrega': pedidoProvider.metodoDeEntrega,
                  'promocode': pedidoProvider.promocodeController.text,
              },
              'itens': pedidoProvider.itensPedido.map((item) => {
                'referencia': item.cod,
                'quantidade': item.qtd,
                'valorUnitario': item.valorUnitario,
                'descontoPercentual': item.desconto,
              }).toList(),
          },
          'evento': {
              'tipo': success ? 'PEDIDO_ENVIADO' : 'PEDIDO_PENDENTE',
              'versaoApp': version,
          },
      };

      await ApiService.enviarDadosAnalise(transacaoData);
      pedidoProvider.limparPedido();
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Erro ao processar pedido: $e'), 
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ));
      print('Erro ao enviar pedido: $e'); // Para debug
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
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
                  title: const Text('Cliente em Formulário de Contato?'),
                  value: provider.buscarPreCadastro,
                  onChanged: (value) => provider.toggleBuscaPreCadastro(),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                Autocomplete<Object>(
                  displayStringForOption: (option) {
                    if (option is Cliente) {
                      final cpfCnpj = option.cpfCnpj != null && option.cpfCnpj!.isNotEmpty 
                          ? ' - ${option.cpfCnpj}' 
                          : '';
                      return '${option.nome}$cpfCnpj - ${option.numeroCliente}';
                    }
                    if (option is PreCadastro) {
                      final cpfCnpj = option.cpfCnpj != null && option.cpfCnpj!.isNotEmpty 
                          ? ' - ${option.cpfCnpj}' 
                          : '';
                      return '${option.nome}$cpfCnpj - ${option.numeroCliente}';
                    }
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
                   // LABELTEXT ADICIONADO
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onFieldSubmitted: (_) => onSubmitted(),
                      decoration: const InputDecoration(
                        labelText: 'Buscar Cliente por Nome, CPF/CNPJ ou Código',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                if (provider.clienteSelecionado != null) ...[
                  const SizedBox(height: 8),
                  Text('Cliente: ${provider.clienteSelecionado!.nome}'),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: provider.telefoneController,
                          decoration: InputDecoration(
                            labelText: 'Telefone',
                            suffixIcon: Icon(Icons.info, color: Theme.of(context).colorScheme.primary, size: 20),
                          ),
                          onTap: () => _mostrarAvisoEdicaoCliente(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          const Text('Confirmado?'),
                          Checkbox(value: provider.telefoneConfirmado, onChanged: (val) => provider.setTelefoneConfirmado(val!)),
                        ],
                      )
                    ],
                  ),
                  TextFormField(
                    controller: provider.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      suffixIcon: Icon(Icons.info, color: Theme.of(context).colorScheme.primary, size: 20),
                    ),
                    onTap: () => _mostrarAvisoEdicaoCliente(),
                  ),
                  
                  // Exibir endereço padrão do cliente
                  if (provider.clienteSelecionado!.enderecoCompleto != null && 
                      provider.clienteSelecionado!.enderecoCompleto!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 600;
                        final colorScheme = Theme.of(context).colorScheme;
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 8 : 12),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.3),
                            border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: colorScheme.primary, size: isMobile ? 18 : 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Endereço Padrão do Cliente',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                        fontSize: isMobile ? 13 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                provider.clienteSelecionado!.enderecoCompleto!,
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 600;
                        final colorScheme = Theme.of(context).colorScheme;
                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 8 : 12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withOpacity(0.3),
                            border: Border.all(color: colorScheme.error.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: colorScheme.error, size: isMobile ? 18 : 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cliente não possui endereço padrão cadastrado',
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: isMobile ? 13 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],

                const Divider(height: 32),

                CheckboxListTile(
                  title: const Text('Usar endereço principal para entrega?'),
                  value: provider.usarEnderecoPrincipal,
                  onChanged: (value) => provider.setUsarEnderecoPrincipal(value!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (!provider.usarEnderecoPrincipal)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<EnderecoAlternativo>(
                        value: provider.enderecoAlternativoSelecionado,
                        hint: const Text('Selecione um endereço alternativo'),
                        isExpanded: true,
                        items: [
                          ...provider.enderecosAlternativos.map((e) => DropdownMenuItem(value: e, child: Text(e.enderecoFormatado, overflow: TextOverflow.ellipsis))),
                          // Só mostra "Outro..." se não for pessoa jurídica
                          if (!provider.clienteEhPessoaJuridica)
                            const DropdownMenuItem(value: null, child: Text('Outro...')),
                        ],
                        onChanged: (value) => provider.setEnderecoAlternativo(value),
                      ),
                      // Aviso para pessoa jurídica
                      if (provider.clienteEhPessoaJuridica)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Cliente Pessoa Jurídica: Apenas endereços cadastrados são permitidos para entrega.',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                if (!provider.usarEnderecoPrincipal && provider.mostrarCampoOutroEndereco && !provider.clienteEhPessoaJuridica)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: provider.enderecoEntregaController,
                      decoration: InputDecoration(
                        labelText: 'Digite o endereço e adicione em observações',
                        border: const OutlineInputBorder(),
                        suffixIcon: Icon(Icons.info, color: Theme.of(context).colorScheme.primary, size: 20),
                      ),
                      onTap: () => _mostrarAvisoEdicaoCliente(),
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
                
                // Novo seletor de condições de pagamento
                const SeletorCondicoesPagamento(),

                const Divider(height: 32),
                
                Row(
                  children: [
                    Expanded(child: TextField(controller: provider.promocodeController, readOnly: provider.temItensPromocionais, decoration: const InputDecoration(labelText: 'Promocode', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.card_giftcard),
                      onPressed: _abrirCatalogoPromocoes,
                      tooltip: 'Catálogo de Promoções',
                      iconSize: 28,
                    ),
                  ],
                ),
                
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
                          provider.adicionarProduto(selection);
                        },
                        // LABELTEXT ADICIONADO
                        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            onFieldSubmitted: (_) {
                              onSubmitted();
                              controller.clear();
                            },
                            decoration: const InputDecoration(
                              labelText: 'Buscar Produto por Cód. ou Descrição',
                              border: OutlineInputBorder(),
                            ),
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 600;
                      
                      if (isMobile) {
                        // Versão mobile - lista vertical com cards
                        return Column(
                          children: provider.itensPedido.asMap().entries.map((entry) {
                            int index = entry.key;
                            ItemPedido item = entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: item.isSelected,
                                          onChanged: item.isPromocional ? null : (value) => provider.toggleItemSelection(index, value!),
                                        ),
                                        Expanded(
                                          child: Text(
                                            item.descricao,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (!item.isPromocional)
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () => provider.removerItem(index),
                                          )
                                        else
                                          const Icon(Icons.lock, size: 20),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Qtd', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Desc %', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text('V. Final', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                              Text(
                                                'R\$ ${item.valorFinal.toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        // Versão tablet/desktop - DataTable otimizada
                        double availableWidth = constraints.maxWidth;
                        double checkboxWidth = 50;
                        double qtdWidth = 80;
                        double descontoWidth = 100;
                        double valorWidth = 120;
                        double acoesWidth = 80;
                        double descricaoWidth = availableWidth - checkboxWidth - qtdWidth - descontoWidth - valorWidth - acoesWidth - 80; // 80 para espaçamentos
                        
                        // Garante largura mínima para descrição
                        if (descricaoWidth < 150) {
                          descricaoWidth = 150;
                        }
                        
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                              maxWidth: availableWidth > 800 ? availableWidth : 800,
                            ),
                            child: DataTable(
                              columnSpacing: 12,
                              horizontalMargin: 12,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 80,
                              columns: [
                                DataColumn(
                                  label: SizedBox(
                                    width: checkboxWidth,
                                    child: Checkbox(
                                      value: provider.selectAllItems,
                                      onChanged: provider.temItensPromocionais ? null : (value) => provider.toggleSelectAll(value!),
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: descricaoWidth,
                                    child: const Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: qtdWidth,
                                    child: const Text('Qtd', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: descontoWidth,
                                    child: const Text('Desconto %', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: valorWidth,
                                    child: const Text('V. Final', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: acoesWidth,
                                    child: const Text('Ações', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                              rows: provider.itensPedido.asMap().entries.map((entry) {
                                int index = entry.key;
                                ItemPedido item = entry.value;
                                return DataRow(cells: [
                                  DataCell(
                                    SizedBox(
                                      width: checkboxWidth,
                                      child: Checkbox(
                                        value: item.isSelected,
                                        onChanged: item.isPromocional ? null : (value) => provider.toggleItemSelection(index, value!),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: descricaoWidth,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Text(
                                          item.descricao,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: qtdWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: TextFormField(
                                          initialValue: item.qtd.toString(),
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          readOnly: item.isPromocional,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) => provider.atualizarQtdItem(index, int.tryParse(value) ?? 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: descontoWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: TextFormField(
                                          controller: provider.descontoControllers[index],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          readOnly: item.isPromocional,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: const InputDecoration(
                                            hintText: '0',
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) => provider.atualizarDescontoItem(index, double.tryParse(value) ?? 0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: valorWidth,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Text(
                                          'R\$ ${item.valorFinal.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: acoesWidth,
                                      child: item.isPromocional 
                                        ? const Icon(Icons.lock, size: 20, color: Colors.grey)
                                        : IconButton(
                                            icon: const Icon(Icons.close, size: 20),
                                            onPressed: () => provider.removerItem(index),
                                            tooltip: 'Remover item',
                                          ),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const Divider(height: 32),
                TextFormField(
                  controller: provider.obsController,
                  decoration: const InputDecoration(labelText: 'Observação', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;
                    
                    if (isMobile) {
                      // Layout vertical para mobile
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                            ),
                            child: Text(
                              'TOTAL: R\$ ${valorTotal.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              icon: _isSending 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                                : const Icon(Icons.send),
                              label: Text(_isSending ? 'A Enviar...' : 'Enviar Pedido'),
                              onPressed: _isSending || !provider.telefoneConfirmado ? null : _mostrarConfirmacaoPedido,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                backgroundColor: provider.telefoneConfirmado ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Layout horizontal para tablet/desktop
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'TOTAL: R\$ ${valorTotal.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            flex: 1,
                            child: FilledButton.icon(
                              icon: _isSending 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                                : const Icon(Icons.send),
                              label: Text(_isSending ? 'A Enviar...' : 'Enviar Pedido'),
                              onPressed: _isSending || !provider.telefoneConfirmado ? null : _mostrarConfirmacaoPedido,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                backgroundColor: provider.telefoneConfirmado ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

