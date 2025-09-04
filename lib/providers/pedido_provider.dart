import 'package:flutter/material.dart';
import '../database.dart';
import '../models/item_pedido.dart';
import '../models/promocao.dart';
import '../screens/pedido/tela_selecao_variacoes.dart';


class PedidoProvider with ChangeNotifier {
  final AppDatabase database;
  PedidoProvider(this.database);

  // --- ESTADO DO FORMULÁRIO ---
  dynamic _clienteSelecionado;
  bool _buscarPreCadastro = false;
  bool _usarEnderecoPrincipal = true;
  String _metodoPagamento = 'Pix';
  int _parcelasCartao = 1;
  bool _retiraEstande = false;
  String _metodoDeEntrega = "Padrão";
  bool _telefoneConfirmado = false;
  List<EnderecoAlternativo> _enderecosAlternativos = [];
  EnderecoAlternativo? _enderecoAlternativoSelecionado;
  bool _mostrarCampoOutroEndereco = false;

  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _codigoAssessorController = TextEditingController();
  final _enderecoEntregaController = TextEditingController();
  final _promocodeController = TextEditingController();
  final _obsController = TextEditingController();

  // --- ESTADO DOS ITENS DO PEDIDO ---
  final List<ItemPedido> _itensPedido = [];
  final List<TextEditingController> _descontoControllers = [];
  final _descontoMassaController = TextEditingController();
  bool _selectAllItems = false;
  bool _temItensPromocionais = false;
  
  // --- LISTAS CONSTANTES ---
  final List<String> _listaMetodosEntrega = ["Motoboy", "Correios", "Padrão", "Retira Loja"];


  // --- GETTERS ---
  dynamic get clienteSelecionado => _clienteSelecionado;
  bool get buscarPreCadastro => _buscarPreCadastro;
  bool get usarEnderecoPrincipal => _usarEnderecoPrincipal;
  String get metodoPagamento => _metodoPagamento;
  int get parcelasCartao => _parcelasCartao;
  bool get retiraEstande => _retiraEstande;
  String get metodoDeEntrega => _metodoDeEntrega;
  bool get telefoneConfirmado => _telefoneConfirmado;
  List<EnderecoAlternativo> get enderecosAlternativos => _enderecosAlternativos;
  EnderecoAlternativo? get enderecoAlternativoSelecionado => _enderecoAlternativoSelecionado;
  bool get mostrarCampoOutroEndereco => _mostrarCampoOutroEndereco;
  
  TextEditingController get telefoneController => _telefoneController;
  TextEditingController get emailController => _emailController;
  TextEditingController get codigoAssessorController => _codigoAssessorController;
  TextEditingController get enderecoEntregaController => _enderecoEntregaController;
  TextEditingController get promocodeController => _promocodeController;
  TextEditingController get obsController => _obsController;
  
  List<ItemPedido> get itensPedido => _itensPedido;
  List<TextEditingController> get descontoControllers => _descontoControllers;
  TextEditingController get descontoMassaController => _descontoMassaController;
  bool get selectAllItems => _selectAllItems;
  bool get temItensPromocionais => _temItensPromocionais;
  
  List<String> get listaMetodosEntrega => _listaMetodosEntrega;


  // --- MÉTODOS DE CONTROLE DO FORMULÁRIO ---
  void setCodigoAssessor(String codigo) {
    _codigoAssessorController.text = codigo;
    notifyListeners();
  }

  void toggleBuscaPreCadastro() {
    _buscarPreCadastro = !_buscarPreCadastro;
    setCliente(null, null); // Limpa o cliente ao trocar o tipo de busca
    notifyListeners();
  }
  
  void setCliente(dynamic cliente, String? cpfCnpj) {
    _clienteSelecionado = cliente;
    if (cliente != null) {
      _telefoneController.text = cliente.telefone1 ?? '';
      _emailController.text = cliente.email ?? '';
    } else {
      _telefoneController.clear();
      _emailController.clear();
      _enderecosAlternativos = [];
    }
    notifyListeners();
  }

  void setEnderecosAlternativos(List<EnderecoAlternativo> enderecos) {
    _enderecosAlternativos = enderecos;
    _enderecoAlternativoSelecionado = null;
    _mostrarCampoOutroEndereco = false;
    notifyListeners();
  }
  
  void setTelefoneConfirmado(bool value) {
    _telefoneConfirmado = value;
    notifyListeners();
  }

  void setUsarEnderecoPrincipal(bool value) {
    _usarEnderecoPrincipal = value;
    notifyListeners();
  }

  void setEnderecoAlternativo(EnderecoAlternativo? value) {
    _enderecoAlternativoSelecionado = value;
    _mostrarCampoOutroEndereco = (value == null);
    if (value != null) {
      _enderecoEntregaController.text = value.enderecoFormatado;
    } else {
      _enderecoEntregaController.clear();
    }
    notifyListeners();
  }

  void setRetiraEstande(bool value) {
    _retiraEstande = value;
    if (_retiraEstande) {
      _metodoDeEntrega = 'Retirada';
    } else {
      _metodoDeEntrega = 'Padrão';
    }
    notifyListeners();
  }
  
  void setMetodoEntrega(String value) {
    _metodoDeEntrega = value;
    notifyListeners();
  }

  void setMetodoPagamento(String value) {
    _metodoPagamento = value;
    notifyListeners();
  }

  void setParcelas(int value) {
    _parcelasCartao = value;
    notifyListeners();
  }


  // --- MÉTODOS DE CONTROLE DOS ITENS ---
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
    notifyListeners();
  }
  
  void toggleSelectAll(bool value) {
    _selectAllItems = value;
    for (var item in _itensPedido) {
      item.isSelected = value;
    }
    notifyListeners();
  }

  void toggleItemSelection(int index, bool value) {
    _itensPedido[index].isSelected = value;
    notifyListeners();
  }

  void atualizarQtdItem(int index, int qtd) {
    _itensPedido[index].qtd = qtd;
    notifyListeners();
  }

  void atualizarDescontoItem(int index, double desconto) {
    _itensPedido[index].desconto = desconto;
    _descontoControllers[index].text = desconto.toString();
    notifyListeners();
  }

  void aplicarDescontoEmMassa() {
    final desconto = double.tryParse(_descontoMassaController.text) ?? 0.0;
    for (int i = 0; i < _itensPedido.length; i++) {
      if (_itensPedido[i].isSelected) {
        atualizarDescontoItem(i, desconto);
      }
    }
    _descontoMassaController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    notifyListeners();
  }
  
  Future<void> aplicarPromocao(Promocao promocao, BuildContext context) async {
    limparItens();
    _promocodeController.text = promocao.promocode;
    _temItensPromocionais = true;

    for (final itemPromo in promocao.itens) {
      if (itemPromo.qtdDigitacao > 0) {
        if (itemPromo.isFamiliaDeProdutos) {
          final produtosSelecionados = await showDialog<List<ItemPedido>>(
            context: context,
            builder: (_) => TelaSelecaoVariacoes(
              database: database,
              itemPromocional: itemPromo,
            ),
          );
          if (produtosSelecionados != null) {
            for (var produto in produtosSelecionados) {
              _itensPedido.add(produto);
              _descontoControllers.add(TextEditingController(text: produto.desconto.toString()));
            }
          }
        } else {
          final produtoBase = await database.getProdutoPorCod(itemPromo.cod);
          if (produtoBase != null) {
            _itensPedido.add(ItemPedido(
              cod: itemPromo.cod,
              descricao: produtoBase.descricao,
              valorUnitario: produtoBase.valor,
              qtd: itemPromo.qtdDigitacao,
              desconto: itemPromo.descontoDigitacao,
              isPromocional: true,
            ));
            _descontoControllers.add(TextEditingController(text: itemPromo.descontoDigitacao.toString()));
          }
        }
      }
    }
    notifyListeners();
  }

  void limparItens() {
    _itensPedido.clear();
    for (var controller in _descontoControllers) {
      controller.dispose();
    }
    _descontoControllers.clear();
    _temItensPromocionais = false;
    _promocodeController.clear();
    notifyListeners();
  }

  // --- LIMPEZA GERAL ---
  void limparPedido() {
    limparItens();
    setCliente(null, null);
    _buscarPreCadastro = false;
    _usarEnderecoPrincipal = true;
    _metodoPagamento = 'Pix';
    _parcelasCartao = 1;
    _retiraEstande = false;
    _metodoDeEntrega = "Padrão";
    _telefoneConfirmado = false;
    _obsController.clear();
    notifyListeners();
  }
}

