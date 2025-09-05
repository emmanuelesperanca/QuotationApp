import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'models/promocao.dart';

// Importa o conector de forma condicional.
import 'connection/native.dart' if (dart.library.html) 'connection/web.dart';

part 'database.g.dart';

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

@DataClassName('ProdutoCategoria')
class ProdutoCategorias extends Table {
  TextColumn get material => text().named('Material')();
  TextColumn get phl4 => text().named('PHL4').nullable()();
  TextColumn get phl5 => text().named('PHL5').nullable()();
  TextColumn get phl6 => text().named('PHL6').nullable()();
  TextColumn get brandTopNode => text().named('BrandTopNode').nullable()();
  @override
  Set<Column> get primaryKey => {material};
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

class RankingItem {
  final String nome;
  final int contagem;
  RankingItem({required this.nome, required this.contagem});
}

class ProdutoComCategoria {
  final Produto produto;
  final ProdutoCategoria? categoria;
  ProdutoComCategoria({required this.produto, this.categoria});
}


// --- O BANCO DE DADOS ---
@DriftDatabase(tables: [Clientes, Produtos, PedidosPendentes, PedidosEnviados, PreCadastros, EnderecosAlternativos, ProdutoCategorias])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 6;

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
      if (from < 6) {
        await m.createTable(produtoCategorias);
      }
    }
  );

  // --- MÉTODOS DE CLIENTE ---
  Future<List<Cliente>> getTodosClientes() => select(clientes).get();
  Future<List<Cliente>> searchClientes(String query) {
    return (select(clientes)
          ..where((c) => c.nome.like('%$query%') | c.cpfCnpj.like('%$query%') | c.numeroCliente.like('%$query%')))
        .get();
  }
  Future<void> apagarTodosClientes() => delete(clientes).go();
  Future<int> countClientes() async {
    final countExp = clientes.id.count();
    final query = selectOnly(clientes)..addColumns([countExp]);
    return (await query.getSingle()).read(countExp) ?? 0;
  }
   Future<bool> clienteExistsByCpfCnpj(String cpfCnpj) async {
    final result = await (select(clientes)..where((tbl) => tbl.cpfCnpj.equals(cpfCnpj))).get();
    return result.isNotEmpty;
  }
  Future<void> populateClientesFromAPI(List<dynamic> data) async {
    await batch((batch) {
      final companions = data.map((row) => ClientesCompanion.insert(
        numeroCliente: row['NumeroCliente']?.toString() ?? '',
        cpfCnpj: Value(row['CPF']?.toString() ?? row['CNPJ']?.toString()),
        nome: row['Nome1']?.toString() ?? 'N/A',
        enderecoCompleto: Value('${row['Rua']} ${row['NumeroEndereco']}, ${row['Bairro']} - ${row['Cidade']}'),
        telefone1: Value(row['Telefone1']?.toString()),
        telefone2: Value(row['Telefone2']?.toString()),
        email: Value(row['Email']?.toString()),
      )).toList();
      batch.insertAll(clientes, companions, mode: InsertMode.insertOrReplace);
    });
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

  // --- MÉTODOS DE ENDEREÇOS ---
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
   Future<int> countEnderecos() async {
    final countExp = enderecosAlternativos.id.count();
    final query = selectOnly(enderecosAlternativos)..addColumns([countExp]);
    return (await query.getSingle()).read(countExp) ?? 0;
  }
  Future<void> populateEnderecosFromAPI(List<dynamic> data) async {
    await batch((batch) {
      final companions = data.map((row) => EnderecosAlternativosCompanion.insert(
        cpfCnpj: row['CPF']?.toString() ?? row['CNPJ']?.toString() ?? '',
        numeroCliente: row['NumeroCliente']?.toString() ?? '',
        enderecoFormatado: '${row['Rua']} ${row['NumeroEndereco']}, ${row['Bairro']} - ${row['Cidade']}',
      )).toList();
      batch.insertAll(enderecosAlternativos, companions, mode: InsertMode.insertOrReplace);
    });
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
  Future<List<Produto>> searchProdutosPorFamilia(String familia) {
    return (select(produtos)..where((p) => p.descricao.like('$familia%'))).get();
  }
  Future<void> apagarTodosProdutos() => delete(produtos).go();
   Future<int> countProdutos() async {
    final countExp = produtos.id.count();
    final query = selectOnly(produtos)..addColumns([countExp]);
    return (await query.getSingle()).read(countExp) ?? 0;
  }
  Future<void> populateProdutosFromAPI(List<dynamic> data) async {
    await batch((batch) {
      final companions = data.map((row) => ProdutosCompanion.insert(
        referencia: row['Referencia']?.toString() ?? '',
        descricao: row['Descricao']?.toString() ?? 'N/A',
        valor: (row['Valor'] as num?)?.toDouble() ?? 0.0,
      )).toList();
      batch.insertAll(produtos, companions, mode: InsertMode.insertOrReplace);
    });
  }

  // --- MÉTODOS PARA CATEGORIAS ---
  Future<List<ProdutoCategoria>> getTodasCategorias() => select(produtoCategorias).get();
  Future<List<ProdutoCategoria>> searchCategorias(String query) {
    return (select(produtoCategorias)
          ..where((c) => c.material.like('%$query%') | c.brandTopNode.like('%$query%')))
        .get();
  }
  Future<void> apagarTodasCategorias() => delete(produtoCategorias).go();
  Future<int> countCategorias() async {
    final countExp = produtoCategorias.material.count();
    final query = selectOnly(produtoCategorias)..addColumns([countExp]);
    return (await query.getSingle()).read(countExp) ?? 0;
  }
  Future<void> populateCategoriasFromAPI(List<dynamic> data) async {
    await batch((batch) {
      final companions = data.map((row) => ProdutoCategoriasCompanion.insert(
        material: row['Material']?.toString() ?? '',
        phl4: Value(row['PHL4: Platform/Type']?.toString()),
        phl5: Value(row['PHL5: Retention/Interphase']?.toString()),
        phl6: Value(row['PHL6: Material / Surface / Detail']?.toString()),
        brandTopNode: Value(row['Brand Top Node']?.toString()),
      )).toList();
      batch.insertAll(produtoCategorias, companions, mode: InsertMode.insertOrReplace);
    });
  }


  // --- MÉTODOS DE PEDIDOS E DASHBOARD ---
  Future<List<PedidoPendente>> getTodosPedidosPendentes() => (select(pedidosPendentes)..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
  Future<List<PedidoEnviado>> getTodosPedidosEnviados() => (select(pedidosEnviados)..orderBy([(t) => OrderingTerm.desc(t.dataEnvio)])).get();
  Future<List<PedidoEnviado>> searchPedidosEnviados(String codCliente) {
    return (select(pedidosEnviados)..where((p) => p.pedidoJson.like('%"cod_cliente": "$codCliente"%'))).get();
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
  Future<void> apagarTodosPedidosPendentes() => delete(pedidosPendentes).go();
  Future<void> apagarTodosPedidosEnviados() => delete(pedidosEnviados).go();
  Future<int> countPedidosPendentes() async {
    final count = pedidosPendentes.id.count();
    final query = selectOnly(pedidosPendentes)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
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
  Future<int> countPedidosEnviados() async {
    final countExp = pedidosEnviados.id.count();
    final query = selectOnly(pedidosEnviados)..addColumns([countExp]);
    return (await query.getSingle()).read(countExp) ?? 0;
  }
  Future<double> sumTotalPedidosEnviados() async {
    final pedidos = await (select(pedidosEnviados)).get();
    double total = 0.0;
    for (var pedido in pedidos) {
      final data = jsonDecode(pedido.pedidoJson);
      total += (data['total'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }
  Future<List<RankingItem>> getTopProdutosVendidos(int limit) async {
    final pedidos = await (select(pedidosEnviados)).get();
    final Map<String, int> contagem = {};

    for (var pedido in pedidos) {
      final data = jsonDecode(pedido.pedidoJson);
      if (data['itens'] is String) {
        final List<dynamic> itens = jsonDecode(data['itens']);
        for (var item in itens) {
          final descricao = item['descricao'] as String? ?? 'N/A';
          contagem[descricao] = (contagem[descricao] ?? 0) + (item['qtd'] as int? ?? 0);
        }
      }
    }
    
    final sortedItems = contagem.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedItems.take(limit).map((e) => RankingItem(nome: e.key, contagem: e.value)).toList();
  }
  Future<List<RankingItem>> getTopClientes(int limit) async {
    final pedidos = await (select(pedidosEnviados)).get();
    final Map<String, int> contagem = {};

    for (var pedido in pedidos) {
        final data = jsonDecode(pedido.pedidoJson);
        final cliente = data['cliente'] as String? ?? 'N/A';
        contagem[cliente] = (contagem[cliente] ?? 0) + 1;
    }

    final sortedItems = contagem.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedItems.take(limit).map((e) => RankingItem(nome: e.key, contagem: e.value)).toList();
  }
  Future<Map<String, int>> getPedidosNosUltimosDias(int days) async {
    final hoje = DateTime.now();
    final Map<String, int> contagemDias = {};
    for (int i = days -1; i >= 0; i--) {
      final dia = hoje.subtract(Duration(days: i));
      contagemDias['${dia.day}/${dia.month}'] = 0;
    }

    final query = select(pedidosEnviados)..where((tbl) => tbl.dataEnvio.isBetweenValues(hoje.subtract(Duration(days: days)), hoje));
    final pedidos = await query.get();

    for (var pedido in pedidos) {
        final dia = pedido.dataEnvio;
        final diaFormatado = '${dia.day}/${dia.month}';
        contagemDias[diaFormatado] = (contagemDias[diaFormatado] ?? 0) + 1;
    }
    return contagemDias;
  }
}

