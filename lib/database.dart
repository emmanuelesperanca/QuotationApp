import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:order_simulator/api_service.dart';
import 'package:order_simulator/models/item_pedido.dart';
import 'dart:convert';


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
        // As remoções de colunas não são suportadas diretamente de forma simples em todas as plataformas.
        // A recriação da tabela é uma abordagem segura para garantir a consistência do esquema.
        await m.recreateAllViews();
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
  Future<int> countClientes() async => (await select(clientes).get()).length;

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
  Future<int> countEnderecos() async => (await select(enderecosAlternativos).get()).length;


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
  Future<int> countProdutos() async => (await select(produtos).get()).length;

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


  // --- NOVOS MÉTODOS PARA SINCRONIZAÇÃO VIA API ---
  Future<void> populateClientesFromAPI(Function(int count) onProgress) async {
    await apagarTodosClientes();
    int skip = 0;
    const batchSize = 2000;
    int totalFetched = 0;
    while (true) {
      final data = await ApiService.getBaseData('clientes', skip: skip);
      if (data == null || data.isEmpty) break;
      
      final companions = data.map((row) => ClientesCompanion.insert(
        numeroCliente: row['NumeroCliente']?.toString() ?? '',
        cpfCnpj: Value(row['CPF']?.toString() ?? row['CNPJ']?.toString()),
        nome: row['Nome1']?.toString() ?? '',
        enderecoCompleto: Value('${row['Rua'] ?? ''}, ${row['NumeroEndereco'] ?? ''} - ${row['Bairro'] ?? ''}, ${row['Cidade'] ?? ''}'),
        telefone1: Value(row['Telefone1']?.toString()),
        telefone2: Value(row['Telefone2']?.toString()),
        email: Value(row['Email']?.toString()),
      )).toList();
      
      await inserirClientesEmMassa(companions);
      totalFetched += companions.length;
      onProgress(totalFetched);

      if (data.length < batchSize) break;
      skip += batchSize;
    }
  }

  Future<void> populateProdutosFromAPI(Function(int count) onProgress) async {
    await apagarTodosProdutos();
    int skip = 0;
    const batchSize = 2000;
    int totalFetched = 0;
    while (true) {
      final data = await ApiService.getBaseData('produtos', skip: skip);
      if (data == null || data.isEmpty) break;

      final companions = data.map((row) => ProdutosCompanion.insert(
        referencia: row['Referencia']?.toString() ?? '',
        descricao: row['Descricao']?.toString() ?? '',
        valor: (row['Valor'] as num?)?.toDouble() ?? 0.0,
      )).toList();
      
      await inserirProdutosEmMassa(companions);
      totalFetched += companions.length;
      onProgress(totalFetched);

      if (data.length < batchSize) break;
      skip += batchSize;
    }
  }

  Future<void> populateEnderecosFromAPI(Function(int count) onProgress) async {
    await apagarTodosEnderecos();
    int skip = 0;
    const batchSize = 2000;
    int totalFetched = 0;
    while (true) {
      final data = await ApiService.getBaseData('enderecos', skip: skip);
      if (data == null || data.isEmpty) break;

      final companions = data.map((row) => EnderecosAlternativosCompanion.insert(
        cpfCnpj: row['CPF']?.toString() ?? row['CNPJ']?.toString() ?? '',
        numeroCliente: row['NumeroCliente']?.toString() ?? '',
        enderecoFormatado: '${row['Rua'] ?? ''}, ${row['NumeroEndereco'] ?? ''} - ${row['Bairro'] ?? ''}, ${row['Cidade'] ?? ''}',
      )).toList();
      
      await inserirEnderecosEmMassa(companions);
      totalFetched += companions.length;
      onProgress(totalFetched);

      if (data.length < batchSize) break;
      skip += batchSize;
    }
  }

  // --- MÉTODOS PARA O DASHBOARD ---
  Future<int> getTotalPedidosEnviados() async {
    final countExp = pedidosEnviados.id.count();
    final query = selectOnly(pedidosEnviados)..addColumns([countExp]);
    return await query.map((row) => row.read(countExp)).getSingle() ?? 0;
  }

  Future<double> getValorTotalFaturado() async {
    final pedidos = await select(pedidosEnviados).get();
    double total = 0.0;
    for (var pedido in pedidos) {
      try {
        final data = jsonDecode(pedido.pedidoJson);
        total += (data['total'] as num?)?.toDouble() ?? 0.0;
      } catch (e) {
        debugPrint("Erro ao decodificar JSON do pedido ${pedido.id}: $e");
      }
    }
    return total;
  }

  Future<Map<String, int>> getTopProdutos() async {
    final pedidos = await select(pedidosEnviados).get();
    final Map<String, int> contagemProdutos = {};

    for (var pedido in pedidos) {
      try {
        final data = jsonDecode(pedido.pedidoJson);
        final List<dynamic> itensJson = (data['itens'] is String)
            ? jsonDecode(data['itens'])
            : data['itens'];
        
        for (var itemJson in itensJson) {
          final item = ItemPedido.fromJson(itemJson);
          contagemProdutos.update(item.descricao, (value) => value + item.qtd, ifAbsent: () => item.qtd);
        }
      } catch (e) {
        debugPrint("Erro ao processar itens do pedido ${pedido.id}: $e");
      }
    }

    final sortedEntries = contagemProdutos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(5));
  }

  Future<Map<String, int>> getTopClientes() async {
    final pedidos = await select(pedidosEnviados).get();
    final Map<String, int> contagemClientes = {};

    for (var pedido in pedidos) {
      try {
        final data = jsonDecode(pedido.pedidoJson);
        final nomeCliente = data['cliente'] as String?;
        if (nomeCliente != null) {
          contagemClientes.update(nomeCliente, (value) => value + 1, ifAbsent: () => 1);
        }
      } catch (e) {
        debugPrint("Erro ao processar cliente do pedido ${pedido.id}: $e");
      }
    }

    final sortedEntries = contagemClientes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(5));
  }

  Future<Map<DateTime, int>> getPedidosUltimos7Dias() async {
    final hoje = DateTime.now();
    final dataLimite = hoje.subtract(const Duration(days: 6));
    
    final query = select(pedidosEnviados)
      ..where((tbl) => tbl.dataEnvio.isBiggerOrEqualValue(DateTime(dataLimite.year, dataLimite.month, dataLimite.day)));

    final pedidos = await query.get();
    final Map<DateTime, int> contagemPorDia = {};

    for (int i = 0; i < 7; i++) {
      final dia = DateTime(hoje.year, hoje.month, hoje.day).subtract(Duration(days: i));
      contagemPorDia[dia] = 0;
    }

    for (var pedido in pedidos) {
      final diaPedido = DateTime(pedido.dataEnvio.year, pedido.dataEnvio.month, pedido.dataEnvio.day);
      contagemPorDia.update(diaPedido, (value) => value + 1, ifAbsent: () => 1);
    }

    return contagemPorDia;
  }
}

