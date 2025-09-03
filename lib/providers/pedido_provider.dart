import 'package:flutter/material.dart';
import '../database.dart';
import '../models/item_pedido.dart';

// Este Provider centraliza toda a lógica e estado da tela de criação de pedido.
// Isto permite que os dados sejam preservados ao navegar entre telas.
class PedidoProvider with ChangeNotifier {
  // --- ESTADO DO PEDIDO ---

  dynamic _clienteSelecionado;
  bool _buscarPreCadastro = false;
  bool _usarEnderecoPrincipal = true;
  String _metodoPagamento = 'Pix';
  int _parcelasCartao = 1;
  final List<ItemPedido> _itensPedido = [];

  // Controllers para os campos de texto
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final codigoAssessorController = TextEditingController();
  final enderecoEntregaController = TextEditingController();
  final promocodeController = TextEditingController();
  final obsController = TextEditingController();
  final descontoMassaController = TextEditingController();
  final List<TextEditingController> descontoControllers = [];

  // Outras variáveis de estado
  bool _telefoneConfirmado = false;
  List<EnderecoAlternativo> _enderecosAlternativos = [];
  EnderecoAlternativo? _enderecoAlternativoSelecionado;
  bool _mostrarCampoOutroEndereco = false;
  bool _retiraEstande = false;
  String _metodoDeEntrega = "Padrão";
  bool _selectAllItems = false;
  
  // --- GETTERS (para a UI aceder aos dados) ---

  dynamic get clienteSelecionado => _clienteSelecionado;
  bool get buscarPreCadastro => _buscarPreCadastro;
  bool get usarEnderecoPrincipal => _usarEnderecoPrincipal;
  String get metodoPagamento => _metodoPagamento;
  int get parcelasCartao => _parcelasCartao;
  List<ItemPedido> get itensPedido => _itensPedido;
  bool get telefoneConfirmado => _telefoneConfirmado;
  List<EnderecoAlternativo> get enderecosAlternativos => _enderecosAlternativos;
  EnderecoAlternativo? get enderecoAlternativoSelecionado => _enderecoAlternativoSelecionado;
  bool get mostrarCampoOutroEndereco => _mostrarCampoOutroEndereco;
  bool get retiraEstande => _retiraEstande;
  String get metodoDeEntrega => _metodoDeEntrega;
  bool get selectAllItems => _selectAllItems;

  // --- MÉTODOS PARA MODIFICAR O ESTADO ---

  void setCodigoAssessor(String codigo) {
    codigoAssessorController.text = codigo;
    notifyListeners();
  }

  void toggleBuscarPreCadastro(bool value) {
    _buscarPreCadastro = value;
    _clienteSelecionado = null; // Limpa o cliente ao mudar o tipo de busca
    notifyListeners();
  }
  
  void setCliente(dynamic cliente, AppDatabase database) async {
    _clienteSelecionado = cliente;
    String? cpfCnpj;
    if (cliente is Cliente) {
      telefoneController.text = cliente.telefone1 ?? '';
      emailController.text = cliente.email ?? '';
      enderecoEntregaController.text = cliente.enderecoCompleto ?? '';
      cpfCnpj = cliente.cpfCnpj;
    } else if (cliente is PreCadastro) {
      telefoneController.text = cliente.telefone1 ?? '';
      emailController.text = cliente.email ?? '';
      enderecoEntregaController.text = cliente.enderecoCompleto ?? '';
      cpfCnpj = cliente.cpfCnpj;
    }
    
    // Busca endereços alternativos
    if (cpfCnpj != null && cpfCnpj.isNotEmpty) {
      _enderecosAlternativos = await database.getEnderecosPorCpfCnpj(cpfCnpj);
    } else {
      _enderecosAlternativos = [];
    }
    _enderecoAlternativoSelecionado = null;
    _mostrarCampoOutroEndereco = false;
    _usarEnderecoPrincipal = true;

    notifyListeners();
  }

  void setTelefoneConfirmado(bool value) {
    _telefoneConfirmado = value;
    notifyListeners();
  }

  void toggleUsarEnderecoPrincipal(bool value) {
    _usarEnderecoPrincipal = value;
    notifyListeners();
  }

  void setEnderecoAlternativo(EnderecoAlternativo? endereco) {
      _enderecoAlternativoSelecionado = endereco;
      _mostrarCampoOutroEndereco = (endereco == null);
      if (endereco != null) {
          enderecoEntregaController.text = endereco.enderecoFormatado;
      } else {
          enderecoEntregaController.clear();
      }
      notifyListeners();
  }

  void setMetodoPagamento(String metodo) {
    _metodoPagamento = metodo;
    notifyListeners();
  }

  void setParcelas(int parcelas) {
    _parcelasCartao = parcelas;
    notifyListeners();
  }

  void setMetodoEntrega(String metodo) {
    _metodoDeEntrega = metodo;
    notifyListeners();
  }

  void toggleRetiraEstande(bool value) {
      _retiraEstande = value;
      if (_retiraEstande) {
          _metodoDeEntrega = 'Retira Loja';
      } else {
          _metodoDeEntrega = 'Padrão';
      }
      notifyListeners();
  }

  void adicionarItem(Produto produto) {
    _itensPedido.add(ItemPedido(
      cod: produto.referencia,
      descricao: produto.descricao,
      valorUnitario: produto.valor,
    ));
    descontoControllers.add(TextEditingController());
    notifyListeners();
  }

  void removerItem(int index) {
    _itensPedido.removeAt(index);
    descontoControllers.removeAt(index).dispose(); // Libera a memória do controller
    notifyListeners();
  }

  void atualizarQuantidadeItem(int index, int qtd) {
    if (index >= 0 && index < _itensPedido.length) {
      _itensPedido[index].qtd = qtd > 0 ? qtd : 1; // Garante que a qtd não seja menor que 1
      notifyListeners();
    }
  }

  void atualizarDescontoItem(int index, double desconto) {
    if (index >= 0 && index < _itensPedido.length) {
      _itensPedido[index].desconto = desconto;
      notifyListeners();
    }
  }

  void toggleSelectItem(int index, bool isSelected) {
     if (index >= 0 && index < _itensPedido.length) {
      _itensPedido[index].isSelected = isSelected;
      notifyListeners();
    }
  }

  void toggleSelectAllItems(bool isSelected) {
    _selectAllItems = isSelected;
    for (var item in _itensPedido) {
      item.isSelected = _selectAllItems;
    }
    notifyListeners();
  }

  void aplicarDescontoEmMassa() {
    final desconto = double.tryParse(descontoMassaController.text) ?? 0.0;
    for (int i = 0; i < _itensPedido.length; i++) {
      if (_itensPedido[i].isSelected) {
        _itensPedido[i].desconto = desconto;
        descontoControllers[i].text = desconto.toStringAsFixed(2);
      }
    }
    descontoMassaController.clear();
    notifyListeners();
  }

  // Limpa todos os campos para reiniciar o formulário
  void limparPedido() {
    _clienteSelecionado = null;
    _buscarPreCadastro = false;
    _usarEnderecoPrincipal = true;
    _metodoPagamento = 'Pix';
    _parcelasCartao = 1;
    _itensPedido.clear();
    
    telefoneController.clear();
    emailController.clear();
    enderecoEntregaController.clear();
    promocodeController.clear();
    obsController.clear();
    descontoMassaController.clear();

    for (var controller in descontoControllers) {
      controller.dispose();
    }
    descontoControllers.clear();

    _telefoneConfirmado = false;
    _enderecosAlternativos = [];
    _enderecoAlternativoSelecionado = null;
    _mostrarCampoOutroEndereco = false;
    _retiraEstande = false;
    _metodoDeEntrega = "Padrão";
    _selectAllItems = false;
    
    notifyListeners();
  }

  // Libera a memória dos controllers quando o provider for destruído
  @override
  void dispose() {
    telefoneController.dispose();
    emailController.dispose();
    codigoAssessorController.dispose();
    enderecoEntregaController.dispose();
    promocodeController.dispose();
    obsController.dispose();
    descontoMassaController.dispose();
    for (var controller in descontoControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

