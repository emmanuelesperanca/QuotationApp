import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'dart:async';
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
  
  bool _clienteJaExiste = false;
  Timer? _debounce;
  bool _consentimentoMarcado = false;

  @override
  void initState() {
    super.initState();
    _cpfCnpjController.addListener(_onCpfCnpjChanged);
  }

  @override
  void dispose() {
    _cpfCnpjController.removeListener(_onCpfCnpjChanged);
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

  void _onCpfCnpjChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final cpfCnpj = _cpfCnpjController.text;
      if (cpfCnpj.isNotEmpty) {
        final existe = await widget.database.clienteExistsByCpfCnpj(cpfCnpj);
        if (mounted) {
          setState(() {
            _clienteJaExiste = existe;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _clienteJaExiste = false;
          });
        }
      }
    });
  }

  void _salvarPreCadastro() async {
    if (_formKey.currentState!.validate() && !_clienteJaExiste && _consentimentoMarcado) {
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pré-Cadastro salvo com sucesso!')));
      
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
        _consentimentoMarcado = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = !_clienteJaExiste && _consentimentoMarcado;

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
                decoration: InputDecoration(
                  labelText: 'CPF / CNPJ',
                  border: const OutlineInputBorder(),
                  errorText: _clienteJaExiste ? 'Este cliente já existe na base de dados.' : null,
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
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text("Declaro que informei ao cliente que os dados serão utilizados apenas para contato posterior"),
                value: _consentimentoMarcado,
                onChanged: (bool? value) {
                  setState(() {
                    _consentimentoMarcado = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isFormValid ? _salvarPreCadastro : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isFormValid ? null : Colors.grey,
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

