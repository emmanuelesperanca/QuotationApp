import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


// Importa o conector de forma condicional.
import 'connection/native.dart' if (dart.library.html) 'connection/web.dart';

part 'database.g.dart';

// Classe de apoio para os rankings do dashboard
class RankingItem {
  final String nome;
  final int contagem;
  RankingItem({required this.nome, required this.contagem});
}


// --- DEFINIÇÃO DAS TABELAS ---
@DataClassName('Cliente')
class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get numeroCliente => text().named('NumeroCliente')();
  TextColumn get cpfCnpj => text().named('CPF_CNPJ').nullable()();
  TextColumn get nome => text().named('Nome')();
  TextColumn get enderecoCompleto => text().named('EnderecoCompleto').nullable()();
  TextColumn get telefone1 => text().named('Telefone1').nullable()();
  TextColumn get telefone2 => text().named('Telefone2').nullable()();
  TextColumn get email => text().named('Email').nullable()();
  TextColumn get preCadastro => text().nullable()();
}

@DataClassName('EnderecoAlternativo')
class EnderecosAlternativos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cpfCnpj => text().named('CPF_CNPJ')();
  TextColumn get numeroCliente => text().named('NumeroCliente')();
  TextColumn get enderecoFormatado => text().named('EnderecoFormatado')();
}


@DataClassName('PreCadastro')
class PreCadastros extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get numeroCliente => text().named('NumeroCliente')();
  TextColumn get cpfCnpj => text().named('CPF_CNPJ').nullable()();
  TextColumn get nome => text().named('Nome')();
  TextColumn get enderecoCompleto => text().named('EnderecoCompleto').nullable()();
  TextColumn get telefone1 => text().named('Telefone1').nullable()();
  TextColumn get telefone2 => text().named('Telefone2').nullable()();
  TextColumn get email => text().named('Email').nullable()();
  TextColumn get preCadastro => text().nullable()();
}

@DataClassName('Produto')
class Produtos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get referencia => text().named('Referencia').unique()();
  TextColumn get descricao => text().named('Descricao')();
  RealColumn get valor => real().named('Valor')();
}

@DataClassName('PedidoPendente')
class PedidosPendentes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pedidoJson => text()();
}

@DataClassName('PedidoEnviado')
class PedidosEnviados extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get appPedidoId => text().nullable()(); 
  TextColumn get pedidoJson => text()();
  DateTimeColumn get dataEnvio => dateTime()();
  TextColumn get numeroPedidoSap => text().nullable()();
  TextColumn get status => text().nullable()();
  TextColumn get obsCentral => text().nullable()();
}


// --- O BANCO DE DADOS ---
@DriftDatabase(tables: [Clientes, Produtos, PedidosPendentes, PedidosEnviados, PreCadastros, EnderecosAlternativos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.deleteTable('clientes');
        await m.deleteTable('produtos');
        await m.createTable(clientes);
        await m.createTable(produtos);
      }
      if (from < 3) {
        await m.createTable(preCadastros);
      }
      if (from < 4) {
        await m.createTable(enderecosAlternativos);
      }
      if (from < 5) {
        await m.addColumn(pedidosEnviados, pedidosEnviados.appPedidoId);
        await m.addColumn(pedidosEnviados, pedidosEnviados.numeroPedidoSap);
        await m.addColumn(pedidosEnviados, pedidosEnviados.status);
        await m.addColumn(pedidosEnviados, pedidosEnviados.obsCentral);
      }
    }
  );

  // --- MÉTODOS DE CLIENTE ---
  Future<List<Cliente>> getTodosClientes() => select(clientes).get();
  Future<void> insereCliente(ClientesCompanion cliente) => into(clientes).insert(cliente);
  Future<List<Cliente>> searchClientes(String query) {
    return (select(clientes)
          ..where((c) => c.nome.like('%$query%') | c.cpfCnpj.like('%$query%') | c.numeroCliente.like('%$query%')))
        .get();
  }
  Future<void> apagarTodosClientes() => delete(clientes).go();
  Future<void> inserirClientesEmMassa(List<ClientesCompanion> novosClientes) async {
    await batch((batch) {
      batch.insertAll(clientes, novosClientes, mode: InsertMode.insertOrReplace);
    });
  }
  Future<int> countClientes() async {
    final count = clientes.id.count();
    final query = selectOnly(clientes)..addColumns([count]);
    return await query.map((row) => row.read(count) ?? 0).getSingle();
  }
  // Adicionado: Método para verificar se um cliente existe pelo CPF/CNPJ
  Future<bool> clienteExistsByCpfCnpj(String cpfCnpj) async {
    final query = select(clientes)..where((c) => c.cpfCnpj.equals(cpfCnpj));
    final result = await query.get();
    return result.isNotEmpty;
  }


  // --- MÉTODOS DE PRÉ-CADASTRO ---
  Future<void> inserePreCadastro(PreCadastrosCompanion preCadastro) => into(preCadastros).insert(preCadastro);
  Future<List<PreCadastro>> getTodosPreCadastros() => select(preCadastros).get();
  Future<List<PreCadastro>> searchPreCadastros(String query) {
    return (select(preCadastros)
          ..where((c) => c.nome.like('%$query%') | c.cpfCnpj.like('%$query%') | c.numeroCliente.like('%$query%')))
        .get();
  }
  Future<void> apagarTodosPreCadastros() => delete(preCadastros).go();

  // --- MÉTODOS DE ENDEREÇOS ALTERNATIVOS ---
  Future<List<EnderecoAlternativo>> getTodosEnderecosAlternativos() => select(enderecosAlternativos).get();
  Future<List<EnderecoAlternativo>> searchEnderecosAlternativos(String query) {
    return (select(enderecosAlternativos)
          ..where((e) => e.enderecoFormatado.like('%$query%') | e.numeroCliente.like('%$query%') | e.cpfCnpj.like('%$query%')))
        .get();
  }
  Future<List<EnderecoAlternativo>> getEnderecosPorCpfCnpj(String cpfCnpj) {
    return (select(enderecosAlternativos)..where((e) => e.cpfCnpj.equals(cpfCnpj))).get();
  }
  Future<void> apagarTodosEnderecos() => delete(enderecosAlternativos).go();
  Future<void> inserirEnderecosEmMassa(List<EnderecosAlternativosCompanion> novosEnderecos) async {
    await batch((batch) {
      batch.insertAll(enderecosAlternativos, novosEnderecos, mode: InsertMode.insertOrReplace);
    });
  }
   Future<int> countEnderecos() async {
    final count = enderecosAlternativos.id.count();
    final query = selectOnly(enderecosAlternativos)..addColumns([count]);
    return await query.map((row) => row.read(count) ?? 0).getSingle();
  }


  // --- MÉTODOS DE PRODUTO ---
  Future<Produto?> getProdutoPorCod(String cod) {
    return (select(produtos)..where((p) => p.referencia.equals(cod))).getSingleOrNull();
  }
  
  Future<List<Produto>> getTodosProdutos() => select(produtos).get();
  Future<List<Produto>> searchProdutos(String query) {
    return (select(produtos)
          ..where((p) => p.descricao.like('%$query%') | p.referencia.like('%$query%')))
        .get();
  }
  Future<void> apagarTodosProdutos() => delete(produtos).go();
  Future<void> inserirProdutosEmMassa(List<ProdutosCompanion> novosProdutos) async {
    await batch((batch) {
      batch.insertAll(produtos, novosProdutos, mode: InsertMode.insertOrReplace);
    });
  }
  Future<int> countProdutos() async {
    final count = produtos.id.count();
    final query = selectOnly(produtos)..addColumns([count]);
    return await query.map((row) => row.read(count) ?? 0).getSingle();
  }

  // --- MÉTODOS DE PEDIDOS ---
  Future<List<PedidoPendente>> getTodosPedidosPendentes() => (select(pedidosPendentes)..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
  Future<List<PedidoEnviado>> getTodosPedidosEnviados() => (select(pedidosEnviados)..orderBy([(t) => OrderingTerm.desc(t.dataEnvio)])).get();
  
  Future<List<PedidoEnviado>> searchPedidosEnviados(String codCliente) {
    return (select(pedidosEnviados)..where((p) => p.pedidoJson.like('%"cod_cliente": "$codCliente"%'))).get();
  }

  Future<int> countPedidosPendentes() async {
    final count = pedidosPendentes.id.count();
    final query = selectOnly(pedidosPendentes)..addColumns([count]);
    return await query.map((row) => row.read(count) ?? 0).getSingle();
  }

  Future<void> inserePedidoPendente(String json) {
    final companion = PedidosPendentesCompanion.insert(pedidoJson: json);
    return into(pedidosPendentes).insert(companion);
  }

  Future<void> deletaPedidoPendente(int id) {
    return (delete(pedidosPendentes)..where((tbl) => tbl.id.equals(id))).go();
  }
  
  Future<void> inserePedidoEnviado(String json, String appPedidoId) {
    final companion = PedidosEnviadosCompanion.insert(
      pedidoJson: json,
      appPedidoId: Value(appPedidoId),
      dataEnvio: DateTime.now(),
    );
    return into(pedidosEnviados).insert(companion);
  }

  Future<void> updateStatusPedidoEnviado(String appPedidoId, String numeroPedidoSap, String status, String obsCentral) {
    return (update(pedidosEnviados)..where((tbl) => tbl.appPedidoId.equals(appPedidoId))).write(
      PedidosEnviadosCompanion(
        numeroPedidoSap: Value(numeroPedidoSap),
        status: Value(status),
        obsCentral: Value(obsCentral),
      ),
    );
  }

  Future<void> apagarTodosPedidosEnviados() => delete(pedidosEnviados).go();
  Future<void> apagarTodosPedidosPendentes() => delete(pedidosPendentes).go();
 
  Future<void> populateClientesFromAPI(List<dynamic> data) async {
    await apagarTodosClientes();
    final companions = data.map((clienteData) {
      return ClientesCompanion.insert(
        numeroCliente: clienteData['NumeroCliente']?.toString() ?? '',
        cpfCnpj: Value(clienteData['CPF']?.toString() ?? ''),
        nome: clienteData['Nome1']?.toString() ?? '',
        enderecoCompleto: Value('${clienteData['Rua'] ?? ''} ${clienteData['NumeroEndereco'] ?? ''}, ${clienteData['Bairro'] ?? ''} - ${clienteData['Cidade'] ?? ''}'),
        telefone1: Value(clienteData['Telefone1']?.toString()),
        telefone2: Value(clienteData['Telefone2']?.toString()),
        email: Value(clienteData['Email']?.toString()),
      );
    }).toList();
    await inserirClientesEmMassa(companions);
  }

  Future<void> populateProdutosFromAPI(List<dynamic> data) async {
    await apagarTodosProdutos();
    final companions = data.map((produtoData) {
      return ProdutosCompanion.insert(
        referencia: produtoData['Referencia']?.toString() ?? '',
        descricao: produtoData['Descricao']?.toString() ?? '',
        valor: (produtoData['Valor'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
    await inserirProdutosEmMassa(companions);
  }

  Future<void> populateEnderecosFromAPI(List<dynamic> data) async {
    await apagarTodosEnderecos();
    final companions = data.map((enderecoData) {
      return EnderecosAlternativosCompanion.insert(
        cpfCnpj: enderecoData['CPF']?.toString() ?? '',
        numeroCliente: enderecoData['NumeroCliente']?.toString() ?? '',
        enderecoFormatado: '${enderecoData['Rua'] ?? ''} ${enderecoData['NumeroEndereco'] ?? ''}, ${enderecoData['Bairro'] ?? ''} - ${enderecoData['Cidade'] ?? ''}',
      );
    }).toList();
    await inserirEnderecosEmMassa(companions);
  }

  // --- MÉTODOS PARA O DASHBOARD ---
  Future<int> countPedidosEnviados() async {
    final count = pedidosEnviados.id.count();
    final query = selectOnly(pedidosEnviados)..addColumns([count]);
    return await query.map((row) => row.read(count) ?? 0).getSingle();
  }

  Future<double> sumTotalPedidosEnviados() async {
    double total = 0;
    final pedidos = await select(pedidosEnviados).get();
    for (var pedido in pedidos) {
      final data = jsonDecode(pedido.pedidoJson);
      total += (data['total'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }

  Future<List<RankingItem>> getTopProdutosVendidos({int limit = 5}) async {
    final pedidos = await getTodosPedidosEnviados();
    final Map<String, int> contagemProdutos = {};

    for (var pedido in pedidos) {
      final pedidoData = jsonDecode(pedido.pedidoJson);
      final List<dynamic> itensJson = (pedidoData['itens'] is String)
        ? jsonDecode(pedidoData['itens'])
        : pedidoData['itens'];

      for (var itemMap in itensJson) {
        final descricao = itemMap['descricao'] as String? ?? 'N/A';
        contagemProdutos.update(descricao, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    final sortedProdutos = contagemProdutos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedProdutos.take(limit).map((e) => RankingItem(nome: e.key, contagem: e.value)).toList();
  }
 
  Future<List<RankingItem>> getTopClientes({int limit = 5}) async {
    final pedidos = await getTodosPedidosEnviados();
    final Map<String, int> contagemClientes = {};
    for (var pedido in pedidos) {
      final pedidoData = jsonDecode(pedido.pedidoJson);
      final nomeCliente = pedidoData['cliente'] as String? ?? 'N/A';
      contagemClientes.update(nomeCliente, (value) => value + 1, ifAbsent: () => 1);
    }
    
    final sortedClientes = contagemClientes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return sortedClientes.take(limit).map((e) => RankingItem(nome: e.key, contagem: e.value)).toList();
  }

  Future<Map<DateTime, int>> getPedidosNosUltimosDias({int dias = 7}) async {
    final hoje = DateTime.now();
    final dataLimite = hoje.subtract(Duration(days: dias - 1));
    final query = select(pedidosEnviados)
      ..where((p) => p.dataEnvio.isBiggerOrEqualValue(DateTime(dataLimite.year, dataLimite.month, dataLimite.day)));
      
    final pedidos = await query.get();
    final Map<DateTime, int> contagemPorDia = {};

    for (int i = 0; i < dias; i++) {
      final dia = DateTime(hoje.year, hoje.month, hoje.day).subtract(Duration(days: i));
      contagemPorDia[dia] = 0;
    }
    
    for (var pedido in pedidos) {
      final diaPedido = DateTime(pedido.dataEnvio.year, pedido.dataEnvio.month, pedido.dataEnvio.day);
      if (contagemPorDia.containsKey(diaPedido)) {
        contagemPorDia.update(diaPedido, (value) => value + 1);
      }
    }
    return contagemPorDia;
  }
}

