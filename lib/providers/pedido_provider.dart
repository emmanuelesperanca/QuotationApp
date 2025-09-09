import 'package:flutter/material.dart';
import '../database.dart';
import '../models/item_pedido.dart';
import '../models/promocao.dart';
import '../models/condicoes_pagamento.dart';
import '../screens/pedido/tela_selecao_variacoes.dart';


class PedidoProvider with ChangeNotifier {
  final AppDatabase database;

  // Construtor
  PedidoProvider(this.database);

  // --- Estado do Formulário ---
  dynamic _clienteSelecionado;
  bool _buscarPreCadastro = false;
  bool _usarEnderecoPrincipal = true;
  CondicaoPagamento? _condicaoPagamentoSelecionada;
  int? _parcelasSelecionadas;
  final List<ItemPedido> _itensPedido = [];
  
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _codigoAssessorController = TextEditingController();
  final _enderecoEntregaController = TextEditingController();
  final _promocodeController = TextEditingController();
  final _obsController = TextEditingController();
  
  bool _telefoneConfirmado = false;
  List<EnderecoAlternativo> _enderecosAlternativos = [];
  EnderecoAlternativo? _enderecoAlternativoSelecionado;
  bool _mostrarCampoOutroEndereco = false;

  bool _retiraEstande = false;
  String _metodoDeEntrega = "Padrão";
  final List<String> _listaMetodosEntrega = ["Motoboy", "Correios", "Padrão", "Retira Loja"];

  bool _selectAllItems = false;
  final _descontoMassaController = TextEditingController();
  final List<TextEditingController> _descontoControllers = [];
  bool _temItensPromocionais = false;

  // --- Getters ---
  dynamic get clienteSelecionado => _clienteSelecionado;
  bool get buscarPreCadastro => _buscarPreCadastro;
  bool get usarEnderecoPrincipal => _usarEnderecoPrincipal;
  CondicaoPagamento? get condicaoPagamentoSelecionada => _condicaoPagamentoSelecionada;
  int? get parcelasSelecionadas => _parcelasSelecionadas;
  List<ItemPedido> get itensPedido => _itensPedido;
  TextEditingController get telefoneController => _telefoneController;
  TextEditingController get emailController => _emailController;
  TextEditingController get codigoAssessorController => _codigoAssessorController;
  TextEditingController get enderecoEntregaController => _enderecoEntregaController;
  TextEditingController get promocodeController => _promocodeController;
  TextEditingController get obsController => _obsController;
  bool get telefoneConfirmado => _telefoneConfirmado;
  List<EnderecoAlternativo> get enderecosAlternativos => _enderecosAlternativos;
  EnderecoAlternativo? get enderecoAlternativoSelecionado => _enderecoAlternativoSelecionado;
  bool get mostrarCampoOutroEndereco => _mostrarCampoOutroEndereco;
  bool get retiraEstande => _retiraEstande;
  String get metodoDeEntrega => _metodoDeEntrega;
  List<String> get listaMetodosEntrega => _listaMetodosEntrega;
  bool get selectAllItems => _selectAllItems;
  TextEditingController get descontoMassaController => _descontoMassaController;
  List<TextEditingController> get descontoControllers => _descontoControllers;
  bool get temItensPromocionais => _temItensPromocionais;


  // --- Ações ---

  void limparPedido({bool promocaoAplicada = false}) {
    _clienteSelecionado = null;
    _usarEnderecoPrincipal = true;
    _condicaoPagamentoSelecionada = null;
    _parcelasSelecionadas = null;
    _itensPedido.clear();
    _telefoneController.clear();
    _emailController.clear();
    _enderecoEntregaController.clear();
    if (!promocaoAplicada) _promocodeController.clear();
    _obsController.clear();
    _telefoneConfirmado = false;
    _enderecosAlternativos = [];
    _enderecoAlternativoSelecionado = null;
    _mostrarCampoOutroEndereco = false;
    _retiraEstande = false;
    _metodoDeEntrega = "Padrão";
    _selectAllItems = false;
    _descontoMassaController.clear();
    for (var controller in _descontoControllers) {
      controller.dispose();
    }
    _descontoControllers.clear();
    _temItensPromocionais = promocaoAplicada;
    notifyListeners();
  }

  // MÉTODO ADICIONADO PARA CORRIGIR O ERRO
  void limparItensNaoPromocionais() {
    // Itera pela lista de forma inversa para remover itens sem problemas de índice
    for (int i = _itensPedido.length - 1; i >= 0; i--) {
      if (!_itensPedido[i].isPromocional) {
        _itensPedido.removeAt(i);
        _descontoControllers.removeAt(i).dispose();
      }
    }
    _recalcularStatusPromocao();
    notifyListeners();
  }

  void setCodigoAssessor(String codigo) {
    _codigoAssessorController.text = codigo;
    notifyListeners();
  }

  void toggleBuscaPreCadastro() {
    _buscarPreCadastro = !_buscarPreCadastro;
    _clienteSelecionado = null;
    notifyListeners();
  }

  void setCliente(dynamic cliente, String? cpfCnpj) {
    _clienteSelecionado = cliente;
    if (cliente is Cliente) {
      _telefoneController.text = cliente.telefone1 ?? '';
      _emailController.text = cliente.email ?? '';
    } else if (cliente is PreCadastro) {
      _telefoneController.text = cliente.telefone1 ?? '';
      _emailController.text = cliente.email ?? '';
    }
    notifyListeners();
  }

  void setEnderecosAlternativos(List<EnderecoAlternativo> enderecos) {
    _enderecosAlternativos = enderecos;
    _enderecoAlternativoSelecionado = null;
    _mostrarCampoOutroEndereco = false;
    notifyListeners();
  }

  void setTelefoneConfirmado(bool confirmado) {
    _telefoneConfirmado = confirmado;
    notifyListeners();
  }

  void setUsarEnderecoPrincipal(bool usar) {
    _usarEnderecoPrincipal = usar;
    notifyListeners();
  }

  void setEnderecoAlternativo(EnderecoAlternativo? endereco) {
    _enderecoAlternativoSelecionado = endereco;
    // Para pessoa jurídica, não permite o modo "Outro endereço"
    _mostrarCampoOutroEndereco = (endereco == null) && !clienteEhPessoaJuridica;
    if (endereco != null) {
      _enderecoEntregaController.text = endereco.enderecoFormatado;
      // Adiciona automaticamente nas observações quando um endereço é selecionado
      adicionarEnderecoNasObservacoes(endereco.enderecoFormatado);
    } else {
      _enderecoEntregaController.clear();
      // Remove das observações quando nenhum endereço está selecionado
      removerEnderecoNasObservacoes();
    }
    notifyListeners();
  }

  void setRetiraEstande(bool retira) {
    _retiraEstande = retira;
    if (retira) {
      _metodoDeEntrega = 'Retirada';
    } else {
      _metodoDeEntrega = 'Padrão';
    }
    notifyListeners();
  }

  void setMetodoEntrega(String metodo) {
    _metodoDeEntrega = metodo;
    notifyListeners();
  }

  void setCondicaoPagamento(CondicaoPagamento? condicao) {
    _condicaoPagamentoSelecionada = condicao;
    // Reset parcelas quando mudar a condição
    _parcelasSelecionadas = null;
    notifyListeners();
  }

  void setParcelasSelecionadas(int? parcelas) {
    _parcelasSelecionadas = parcelas;
    notifyListeners();
  }

  // Verifica se o cliente selecionado é pessoa jurídica (código SAP inicia com 4452)
  bool get clienteEhPessoaJuridica {
    if (_clienteSelecionado == null) return false;
    final numeroCliente = _clienteSelecionado!.numeroCliente as String?;
    return numeroCliente?.startsWith('04453') == true;
  }

  void adicionarProduto(Produto produto) {
    _itensPedido.add(ItemPedido(
      cod: produto.referencia,
      descricao: produto.descricao,
      valorUnitario: produto.valor,
    ));
    _descontoControllers.add(TextEditingController());
    notifyListeners();
  }

  void removerItem(int index) {
    _itensPedido.removeAt(index);
    _descontoControllers.removeAt(index).dispose();
    _recalcularStatusPromocao();
    notifyListeners();
  }
  
  void aplicarDescontoEmMassa() {
    final desconto = double.tryParse(_descontoMassaController.text) ?? 0.0;
    for (int i = 0; i < _itensPedido.length; i++) {
      if (_itensPedido[i].isSelected) {
        _itensPedido[i].desconto = desconto;
        _descontoControllers[i].text = desconto.toString();
      }
    }
    _descontoMassaController.clear();
    notifyListeners();
  }

  void toggleSelectAll(bool select) {
    _selectAllItems = select;
    for (var item in _itensPedido) {
      item.isSelected = select;
    }
    notifyListeners();
  }

  void toggleItemSelection(int index, bool isSelected) {
    _itensPedido[index].isSelected = isSelected;
    notifyListeners();
  }

  void atualizarQtdItem(int index, int qtd) {
    _itensPedido[index].qtd = qtd;
    notifyListeners();
  }

  void atualizarDescontoItem(int index, double desconto) {
    _itensPedido[index].desconto = desconto;
    notifyListeners();
  }
  
  void adicionarEnderecoNasObservacoes(String enderecoAlternativo) {
    if (enderecoAlternativo.trim().isEmpty) return;
    
    final observacaoEndereco = "Endereço de entrega alternativo: $enderecoAlternativo";
    final observacaoAtual = _obsController.text.trim();
    
    // Verifica se já existe uma observação de endereço alternativo para evitar duplicação
    if (observacaoAtual.contains("Endereço de entrega alternativo:")) {
      // Remove a observação antiga e adiciona a nova
      final linhas = observacaoAtual.split('\n');
      final linhasSemEndereco = linhas.where((linha) => !linha.contains("Endereço de entrega alternativo:")).toList();
      
      // Remove linhas vazias desnecessárias
      linhasSemEndereco.removeWhere((linha) => linha.trim().isEmpty);
      
      if (linhasSemEndereco.isNotEmpty) {
        linhasSemEndereco.add(observacaoEndereco);
        _obsController.text = linhasSemEndereco.join('\n');
      } else {
        _obsController.text = observacaoEndereco;
      }
    } else {
      // Adiciona a nova observação
      if (observacaoAtual.isEmpty) {
        _obsController.text = observacaoEndereco;
      } else {
        _obsController.text = "$observacaoAtual\n$observacaoEndereco";
      }
    }
    notifyListeners();
  }

  void removerEnderecoNasObservacoes() {
    final observacaoAtual = _obsController.text.trim();
    if (observacaoAtual.contains("Endereço de entrega alternativo:")) {
      final linhas = observacaoAtual.split('\n');
      final linhasSemEndereco = linhas.where((linha) => !linha.contains("Endereço de entrega alternativo:")).toList();
      
      // Remove linhas vazias desnecessárias
      linhasSemEndereco.removeWhere((linha) => linha.trim().isEmpty);
      
      _obsController.text = linhasSemEndereco.join('\n').trim();
      notifyListeners();
    }
  }

  void _recalcularStatusPromocao() {
    _temItensPromocionais = _itensPedido.any((item) => item.isPromocional);
    if (!_temItensPromocionais) {
      _promocodeController.clear();
    }
  }

  Future<void> aplicarPromocao(Promocao promocao, BuildContext context) async {
    _promocodeController.text = promocao.promocode;

    for (final itemPromocional in promocao.itens) {
      if (itemPromocional.isFamiliaDeProdutos) {
        final itensSelecionados = await showDialog<List<ItemPedido>>(
          context: context,
          builder: (_) => TelaSelecaoVariacoes(
            database: database,
            itemPromocional: itemPromocional,
          ),
        );
        if (itensSelecionados != null) {
          for (final itemSelecionado in itensSelecionados) {
            _itensPedido.add(itemSelecionado);
            _descontoControllers.add(TextEditingController(text: itemSelecionado.desconto.toString()));
          }
        }
      } else {
        if (itemPromocional.qtdDigitacao > 0) {
           final produtoBase = await database.getProdutoPorCod(itemPromocional.cod);
           if (produtoBase != null) {
            _itensPedido.add(ItemPedido(
              cod: itemPromocional.cod,
              descricao: produtoBase.descricao,
              valorUnitario: produtoBase.valor,
              qtd: itemPromocional.qtdDigitacao,
              desconto: itemPromocional.descontoDigitacao,
              isPromocional: true,
            ));
            _descontoControllers.add(TextEditingController(text: itemPromocional.descontoDigitacao.toString()));
           }
        }
      }
    }
    
    _recalcularStatusPromocao();
    notifyListeners();
  }

}

