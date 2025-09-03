import 'dart:async';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import '../../database.dart';

class TelaPreCadastroCliente extends StatefulWidget {
  final AppDatabase database;
  const TelaPreCadastroCliente({super.key, required this.database});
  @override
  State<TelaPreCadastroCliente> createState() => _TelaPreCadastroClienteState();
}

class _TelaPreCadastroClienteState extends State<TelaPreCadastroCliente> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _croController = TextEditingController();
  
  // Variáveis de estado para as novas funcionalidades
  bool _declarationAccepted = false;
  bool _isCheckingCpf = false;
  bool _cpfJaExiste = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _croController.dispose();
    super.dispose();
  }

  // Função para verificar o CPF/CNPJ com debounce
  void _checkCpfCnpj(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      if (value.isNotEmpty) {
        setState(() => _isCheckingCpf = true);
        final exists = await widget.database.clienteExistsByCpfCnpj(value);
        if (mounted) {
          setState(() {
            _cpfJaExiste = exists;
            _isCheckingCpf = false;
          });
        }
      } else {
         if (mounted) {
            setState(() => _cpfJaExiste = false);
         }
      }
    });
  }


  void _salvarPreCadastro() async {
    // Valida o formulário
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Verifica se o CPF já existe (última verificação)
    if (_cpfJaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este CPF/CNPJ já está cadastrado.'), backgroundColor: Colors.orange));
      return;
    }

    // Verifica se a declaração foi aceite
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('É necessário aceitar a declaração de uso de dados.'), backgroundColor: Colors.orange));
      return;
    }

    final String preCadastroString = 
      'Nome: ${_nomeController.text}\n'
      'CPF/CNPJ: ${_cpfCnpjController.text}\n'
      'Endereço: ${_enderecoController.text}, ${_cidadeController.text} - ${_estadoController.text}\n'
      'Telefone: ${_telefoneController.text}\n'
      'E-mail: ${_emailController.text}\n'
      'CRO: ${_croController.text}';

    final novoPreCadastro = PreCadastrosCompanion.insert(
      nome: _nomeController.text,
      cpfCnpj: Value(_cpfCnpjController.text),
      enderecoCompleto: Value('${_enderecoController.text}, ${_cidadeController.text} - ${_estadoController.text}'),
      telefone1: Value(_telefoneController.text),
      email: Value(_emailController.text),
      numeroCliente: (_croController.text),
      preCadastro: Value(preCadastroString),
    );

    await widget.database.inserePreCadastro(novoPreCadastro);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pré-Cadastro salvo com sucesso!'), backgroundColor: Colors.green));
    
    // Limpa o formulário
    _formKey.currentState?.reset();
    _nomeController.clear();
    _cpfCnpjController.clear();
    _enderecoController.clear();
    _cidadeController.clear();
    _estadoController.clear();
    _telefoneController.clear();
    _emailController.clear();
    _croController.clear();
    setState(() {
      _declarationAccepted = false;
      _cpfJaExiste = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // O botão de salvar é desativado se o CPF já existir ou a declaração não for aceite
    final bool canSave = !_cpfJaExiste && _declarationAccepted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pré-Cadastrar Cliente'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()), validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cpfCnpjController,
                onChanged: _checkCpfCnpj,
                decoration: InputDecoration(
                  labelText: 'CPF / CNPJ',
                  border: const OutlineInputBorder(),
                  // Mostra o erro ou um indicador de carregamento
                  errorText: _cpfJaExiste ? 'Este CPF/CNPJ já está cadastrado.' : null,
                  suffixIcon: _isCheckingCpf ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _enderecoController, decoration: const InputDecoration(labelText: 'Endereço', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _cidadeController, decoration: const InputDecoration(labelText: 'Cidade', border: OutlineInputBorder()))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _estadoController, decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _telefoneController, decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextFormField(controller: _croController, decoration: const InputDecoration(labelText: 'CRO', border: OutlineInputBorder())),
              const SizedBox(height: 24),
              // Checkbox de declaração
              CheckboxListTile(
                title: const Text('Declaro que informei ao cliente que os dados serão utilizados apenas para contato posterior.'),
                value: _declarationAccepted,
                onChanged: (value) => setState(() => _declarationAccepted = value!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  // O botão é desativado se as condições não forem cumpridas
                  onPressed: canSave ? _salvarPreCadastro : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    // Muda a cor do botão quando está desativado
                    backgroundColor: canSave ? null : Colors.grey.shade700,
                  ),
                  child: const Text('Salvar Pré-Cadastro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
