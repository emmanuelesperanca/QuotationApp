import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import '../database.dart';

class CsvService {
  static const String _clientesCsvPath = 'assets/csv/clientes.csv';
  static const String _enderecosCsvPath = 'assets/csv/enderecos_alternativos.csv';
  static const String _produtosCsvPath = 'assets/csv/produtos.csv';

  /// Carrega clientes a partir do CSV local
  static Future<List<ClientesCompanion>> carregarClientesDoCsv() async {
    try {
      final csvData = await rootBundle.loadString(_clientesCsvPath);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
      
      // Remove o cabeçalho
      if (rows.isNotEmpty) {
        rows.removeAt(0);
      }
      
      List<ClientesCompanion> clientes = [];
      for (var row in rows) {
        if (row.length >= 15) { // CSV tem 15 campos: CPF,CNPJ,NumeroCliente,Nome1,Nome2,Rua,NumeroEndereco,Complemento,Cidade,Bairro,CodigoPostal,Telefone1,Telefone2,EquipeVendas,Email
          try {
            // Constrói o CPF/CNPJ (usa CPF se disponível, senão CNPJ)
            final cpf = row[0]?.toString().trim();
            final cnpj = row[1]?.toString().trim();
            final cpfCnpj = (cpf != null && cpf.isNotEmpty) ? cpf : cnpj;
            
            // Número do cliente está na posição 2
            final numeroCliente = row[2]?.toString().trim() ?? '';
            
            // Constrói o nome completo (Nome1 + Nome2 se disponível)
            final nome1 = row[3]?.toString().trim() ?? '';
            final nome2 = row[4]?.toString().trim() ?? '';
            final nomeCompleto = nome2.isNotEmpty ? '$nome1 $nome2' : nome1;
            
            // Constrói o endereço completo
            final rua = row[5]?.toString().trim() ?? '';
            final numero = row[6]?.toString().trim() ?? '';
            final complemento = row[7]?.toString().trim() ?? '';
            final cidade = row[8]?.toString().trim() ?? '';
            final bairro = row[9]?.toString().trim() ?? '';
            final cep = row[10]?.toString().trim() ?? '';
            
            final enderecoCompleto = [
              rua,
              numero.isNotEmpty ? 'Nº $numero' : '',
              complemento.isNotEmpty ? 'Compl.: $complemento' : '',
              bairro,
              cidade,
              cep.isNotEmpty ? 'CEP: $cep' : ''
            ].where((parte) => parte.isNotEmpty).join(', ');
            
            final cliente = ClientesCompanion(
              numeroCliente: Value(numeroCliente),
              cpfCnpj: Value(cpfCnpj),
              nome: Value(nomeCompleto),
              enderecoCompleto: Value(enderecoCompleto.isNotEmpty ? enderecoCompleto : null),
              telefone1: Value(row[11]?.toString().trim()), // Telefone1 está na posição 11
              telefone2: Value(row[12]?.toString().trim()), // Telefone2 está na posição 12
              email: Value(row[14]?.toString().trim()), // Email está na posição 14
              preCadastro: const Value(null),
            );
            clientes.add(cliente);
          } catch (e) {
            print('Erro ao processar linha do CSV clientes: $row - $e');
          }
        }
      }
      
      print('Carregados ${clientes.length} clientes do CSV local');
      return clientes;
    } catch (e) {
      print('Erro ao carregar clientes do CSV: $e');
      return [];
    }
  }

  /// Carrega endereços alternativos a partir do CSV local
  static Future<List<EnderecosAlternativosCompanion>> carregarEnderecosDoCsv() async {
    try {
      final csvData = await rootBundle.loadString(_enderecosCsvPath);
      // CSV de endereços agora usa vírgula como separador (mesma estrutura dos clientes)
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
      
      // Remove o cabeçalho
      if (rows.isNotEmpty) {
        rows.removeAt(0);
      }
      
      List<EnderecosAlternativosCompanion> enderecos = [];
      for (var row in rows) {
        if (row.length >= 15) { // CSV tem 15 campos: CPF,CNPJ,NumeroCliente,Nome1,Nome2,Rua,NumeroEndereco,Complemento,Cidade,Bairro,CodigoPostal,Telefone1,Telefone2,EquipeVendas,Email
          try {
            // Constrói o CPF/CNPJ (usa CPF se disponível, senão CNPJ)
            final cpf = row[0]?.toString().trim();
            final cnpj = row[1]?.toString().trim();
            final cpfCnpj = (cpf != null && cpf.isNotEmpty) ? cpf : cnpj ?? '';
            
            // Número do cliente está na posição 2
            final numeroCliente = row[2]?.toString().trim() ?? '';
            
            // Constrói o endereço formatado
            final rua = row[5]?.toString().trim() ?? '';
            final numero = row[6]?.toString().trim() ?? '';
            final complemento = row[7]?.toString().trim() ?? '';
            final cidade = row[8]?.toString().trim() ?? '';
            final bairro = row[9]?.toString().trim() ?? '';
            final cep = row[10]?.toString().trim() ?? '';
            
            final enderecoFormatado = [
              rua,
              numero.isNotEmpty ? 'Nº $numero' : '',
              complemento.isNotEmpty ? 'Compl.: $complemento' : '',
              bairro,
              cidade,
              cep.isNotEmpty ? 'CEP: $cep' : ''
            ].where((parte) => parte.isNotEmpty).join(', ');
            
            final endereco = EnderecosAlternativosCompanion(
              cpfCnpj: Value(cpfCnpj),
              numeroCliente: Value(numeroCliente),
              enderecoFormatado: Value(enderecoFormatado),
            );
            enderecos.add(endereco);
          } catch (e) {
            print('Erro ao processar linha do CSV endereços: $row - $e');
          }
        }
      }
      
      print('Carregados ${enderecos.length} endereços do CSV local');
      return enderecos;
    } catch (e) {
      print('Erro ao carregar endereços do CSV: $e');
      return [];
    }
  }

  /// Carrega produtos a partir do CSV local
  static Future<List<ProdutosCompanion>> carregarProdutosDoCsv() async {
    try {
      final csvData = await rootBundle.loadString(_produtosCsvPath);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
      
      // Remove o cabeçalho
      if (rows.isNotEmpty) {
        rows.removeAt(0);
      }
      
      List<ProdutosCompanion> produtos = [];
      for (var row in rows) {
        if (row.length >= 3) { // Garante que tem todas as colunas necessárias
          try {
            final produto = ProdutosCompanion(
              referencia: Value(row[0]?.toString() ?? ''),
              descricao: Value(row[1]?.toString() ?? ''),
              valor: Value(double.tryParse(row[2]?.toString() ?? '0') ?? 0.0),
            );
            produtos.add(produto);
          } catch (e) {
            print('Erro ao processar linha do CSV produtos: $row - $e');
          }
        }
      }
      
      print('Carregados ${produtos.length} produtos do CSV local');
      return produtos;
    } catch (e) {
      print('Erro ao carregar produtos do CSV: $e');
      return [];
    }
  }

  /// Verifica se todos os arquivos CSV estão disponíveis
  static Future<bool> csvDisponivel() async {
    try {
      await rootBundle.loadString(_clientesCsvPath);
      await rootBundle.loadString(_enderecosCsvPath);
      await rootBundle.loadString(_produtosCsvPath);
      return true;
    } catch (e) {
      print('CSV não disponível: $e');
      return false;
    }
  }
}
