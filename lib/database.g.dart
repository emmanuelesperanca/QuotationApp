// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClientesTable extends Clientes with TableInfo<$ClientesTable, Cliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _numeroClienteMeta =
      const VerificationMeta('numeroCliente');
  @override
  late final GeneratedColumn<String> numeroCliente = GeneratedColumn<String>(
      'NumeroCliente', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cpfCnpjMeta =
      const VerificationMeta('cpfCnpj');
  @override
  late final GeneratedColumn<String> cpfCnpj = GeneratedColumn<String>(
      'CPF_CNPJ', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'Nome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enderecoCompletoMeta =
      const VerificationMeta('enderecoCompleto');
  @override
  late final GeneratedColumn<String> enderecoCompleto = GeneratedColumn<String>(
      'EnderecoCompleto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telefone1Meta =
      const VerificationMeta('telefone1');
  @override
  late final GeneratedColumn<String> telefone1 = GeneratedColumn<String>(
      'Telefone1', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telefone2Meta =
      const VerificationMeta('telefone2');
  @override
  late final GeneratedColumn<String> telefone2 = GeneratedColumn<String>(
      'Telefone2', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'Email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preCadastroMeta =
      const VerificationMeta('preCadastro');
  @override
  late final GeneratedColumn<String> preCadastro = GeneratedColumn<String>(
      'pre_cadastro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        numeroCliente,
        cpfCnpj,
        nome,
        enderecoCompleto,
        telefone1,
        telefone2,
        email,
        preCadastro
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(Insertable<Cliente> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('NumeroCliente')) {
      context.handle(
          _numeroClienteMeta,
          numeroCliente.isAcceptableOrUnknown(
              data['NumeroCliente']!, _numeroClienteMeta));
    } else if (isInserting) {
      context.missing(_numeroClienteMeta);
    }
    if (data.containsKey('CPF_CNPJ')) {
      context.handle(_cpfCnpjMeta,
          cpfCnpj.isAcceptableOrUnknown(data['CPF_CNPJ']!, _cpfCnpjMeta));
    }
    if (data.containsKey('Nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['Nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('EnderecoCompleto')) {
      context.handle(
          _enderecoCompletoMeta,
          enderecoCompleto.isAcceptableOrUnknown(
              data['EnderecoCompleto']!, _enderecoCompletoMeta));
    }
    if (data.containsKey('Telefone1')) {
      context.handle(_telefone1Meta,
          telefone1.isAcceptableOrUnknown(data['Telefone1']!, _telefone1Meta));
    }
    if (data.containsKey('Telefone2')) {
      context.handle(_telefone2Meta,
          telefone2.isAcceptableOrUnknown(data['Telefone2']!, _telefone2Meta));
    }
    if (data.containsKey('Email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['Email']!, _emailMeta));
    }
    if (data.containsKey('pre_cadastro')) {
      context.handle(
          _preCadastroMeta,
          preCadastro.isAcceptableOrUnknown(
              data['pre_cadastro']!, _preCadastroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cliente(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      numeroCliente: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}NumeroCliente'])!,
      cpfCnpj: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}CPF_CNPJ']),
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Nome'])!,
      enderecoCompleto: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}EnderecoCompleto']),
      telefone1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Telefone1']),
      telefone2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Telefone2']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Email']),
      preCadastro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pre_cadastro']),
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class Cliente extends DataClass implements Insertable<Cliente> {
  final int id;
  final String numeroCliente;
  final String? cpfCnpj;
  final String nome;
  final String? enderecoCompleto;
  final String? telefone1;
  final String? telefone2;
  final String? email;
  final String? preCadastro;
  const Cliente(
      {required this.id,
      required this.numeroCliente,
      this.cpfCnpj,
      required this.nome,
      this.enderecoCompleto,
      this.telefone1,
      this.telefone2,
      this.email,
      this.preCadastro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['NumeroCliente'] = Variable<String>(numeroCliente);
    if (!nullToAbsent || cpfCnpj != null) {
      map['CPF_CNPJ'] = Variable<String>(cpfCnpj);
    }
    map['Nome'] = Variable<String>(nome);
    if (!nullToAbsent || enderecoCompleto != null) {
      map['EnderecoCompleto'] = Variable<String>(enderecoCompleto);
    }
    if (!nullToAbsent || telefone1 != null) {
      map['Telefone1'] = Variable<String>(telefone1);
    }
    if (!nullToAbsent || telefone2 != null) {
      map['Telefone2'] = Variable<String>(telefone2);
    }
    if (!nullToAbsent || email != null) {
      map['Email'] = Variable<String>(email);
    }
    if (!nullToAbsent || preCadastro != null) {
      map['pre_cadastro'] = Variable<String>(preCadastro);
    }
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      numeroCliente: Value(numeroCliente),
      cpfCnpj: cpfCnpj == null && nullToAbsent
          ? const Value.absent()
          : Value(cpfCnpj),
      nome: Value(nome),
      enderecoCompleto: enderecoCompleto == null && nullToAbsent
          ? const Value.absent()
          : Value(enderecoCompleto),
      telefone1: telefone1 == null && nullToAbsent
          ? const Value.absent()
          : Value(telefone1),
      telefone2: telefone2 == null && nullToAbsent
          ? const Value.absent()
          : Value(telefone2),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      preCadastro: preCadastro == null && nullToAbsent
          ? const Value.absent()
          : Value(preCadastro),
    );
  }

  factory Cliente.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cliente(
      id: serializer.fromJson<int>(json['id']),
      numeroCliente: serializer.fromJson<String>(json['numeroCliente']),
      cpfCnpj: serializer.fromJson<String?>(json['cpfCnpj']),
      nome: serializer.fromJson<String>(json['nome']),
      enderecoCompleto: serializer.fromJson<String?>(json['enderecoCompleto']),
      telefone1: serializer.fromJson<String?>(json['telefone1']),
      telefone2: serializer.fromJson<String?>(json['telefone2']),
      email: serializer.fromJson<String?>(json['email']),
      preCadastro: serializer.fromJson<String?>(json['preCadastro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'numeroCliente': serializer.toJson<String>(numeroCliente),
      'cpfCnpj': serializer.toJson<String?>(cpfCnpj),
      'nome': serializer.toJson<String>(nome),
      'enderecoCompleto': serializer.toJson<String?>(enderecoCompleto),
      'telefone1': serializer.toJson<String?>(telefone1),
      'telefone2': serializer.toJson<String?>(telefone2),
      'email': serializer.toJson<String?>(email),
      'preCadastro': serializer.toJson<String?>(preCadastro),
    };
  }

  Cliente copyWith(
          {int? id,
          String? numeroCliente,
          Value<String?> cpfCnpj = const Value.absent(),
          String? nome,
          Value<String?> enderecoCompleto = const Value.absent(),
          Value<String?> telefone1 = const Value.absent(),
          Value<String?> telefone2 = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> preCadastro = const Value.absent()}) =>
      Cliente(
        id: id ?? this.id,
        numeroCliente: numeroCliente ?? this.numeroCliente,
        cpfCnpj: cpfCnpj.present ? cpfCnpj.value : this.cpfCnpj,
        nome: nome ?? this.nome,
        enderecoCompleto: enderecoCompleto.present
            ? enderecoCompleto.value
            : this.enderecoCompleto,
        telefone1: telefone1.present ? telefone1.value : this.telefone1,
        telefone2: telefone2.present ? telefone2.value : this.telefone2,
        email: email.present ? email.value : this.email,
        preCadastro: preCadastro.present ? preCadastro.value : this.preCadastro,
      );
  Cliente copyWithCompanion(ClientesCompanion data) {
    return Cliente(
      id: data.id.present ? data.id.value : this.id,
      numeroCliente: data.numeroCliente.present
          ? data.numeroCliente.value
          : this.numeroCliente,
      cpfCnpj: data.cpfCnpj.present ? data.cpfCnpj.value : this.cpfCnpj,
      nome: data.nome.present ? data.nome.value : this.nome,
      enderecoCompleto: data.enderecoCompleto.present
          ? data.enderecoCompleto.value
          : this.enderecoCompleto,
      telefone1: data.telefone1.present ? data.telefone1.value : this.telefone1,
      telefone2: data.telefone2.present ? data.telefone2.value : this.telefone2,
      email: data.email.present ? data.email.value : this.email,
      preCadastro:
          data.preCadastro.present ? data.preCadastro.value : this.preCadastro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cliente(')
          ..write('id: $id, ')
          ..write('numeroCliente: $numeroCliente, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('nome: $nome, ')
          ..write('enderecoCompleto: $enderecoCompleto, ')
          ..write('telefone1: $telefone1, ')
          ..write('telefone2: $telefone2, ')
          ..write('email: $email, ')
          ..write('preCadastro: $preCadastro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, numeroCliente, cpfCnpj, nome,
      enderecoCompleto, telefone1, telefone2, email, preCadastro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cliente &&
          other.id == this.id &&
          other.numeroCliente == this.numeroCliente &&
          other.cpfCnpj == this.cpfCnpj &&
          other.nome == this.nome &&
          other.enderecoCompleto == this.enderecoCompleto &&
          other.telefone1 == this.telefone1 &&
          other.telefone2 == this.telefone2 &&
          other.email == this.email &&
          other.preCadastro == this.preCadastro);
}

class ClientesCompanion extends UpdateCompanion<Cliente> {
  final Value<int> id;
  final Value<String> numeroCliente;
  final Value<String?> cpfCnpj;
  final Value<String> nome;
  final Value<String?> enderecoCompleto;
  final Value<String?> telefone1;
  final Value<String?> telefone2;
  final Value<String?> email;
  final Value<String?> preCadastro;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.numeroCliente = const Value.absent(),
    this.cpfCnpj = const Value.absent(),
    this.nome = const Value.absent(),
    this.enderecoCompleto = const Value.absent(),
    this.telefone1 = const Value.absent(),
    this.telefone2 = const Value.absent(),
    this.email = const Value.absent(),
    this.preCadastro = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String numeroCliente,
    this.cpfCnpj = const Value.absent(),
    required String nome,
    this.enderecoCompleto = const Value.absent(),
    this.telefone1 = const Value.absent(),
    this.telefone2 = const Value.absent(),
    this.email = const Value.absent(),
    this.preCadastro = const Value.absent(),
  })  : numeroCliente = Value(numeroCliente),
        nome = Value(nome);
  static Insertable<Cliente> custom({
    Expression<int>? id,
    Expression<String>? numeroCliente,
    Expression<String>? cpfCnpj,
    Expression<String>? nome,
    Expression<String>? enderecoCompleto,
    Expression<String>? telefone1,
    Expression<String>? telefone2,
    Expression<String>? email,
    Expression<String>? preCadastro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numeroCliente != null) 'NumeroCliente': numeroCliente,
      if (cpfCnpj != null) 'CPF_CNPJ': cpfCnpj,
      if (nome != null) 'Nome': nome,
      if (enderecoCompleto != null) 'EnderecoCompleto': enderecoCompleto,
      if (telefone1 != null) 'Telefone1': telefone1,
      if (telefone2 != null) 'Telefone2': telefone2,
      if (email != null) 'Email': email,
      if (preCadastro != null) 'pre_cadastro': preCadastro,
    });
  }

  ClientesCompanion copyWith(
      {Value<int>? id,
      Value<String>? numeroCliente,
      Value<String?>? cpfCnpj,
      Value<String>? nome,
      Value<String?>? enderecoCompleto,
      Value<String?>? telefone1,
      Value<String?>? telefone2,
      Value<String?>? email,
      Value<String?>? preCadastro}) {
    return ClientesCompanion(
      id: id ?? this.id,
      numeroCliente: numeroCliente ?? this.numeroCliente,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      nome: nome ?? this.nome,
      enderecoCompleto: enderecoCompleto ?? this.enderecoCompleto,
      telefone1: telefone1 ?? this.telefone1,
      telefone2: telefone2 ?? this.telefone2,
      email: email ?? this.email,
      preCadastro: preCadastro ?? this.preCadastro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (numeroCliente.present) {
      map['NumeroCliente'] = Variable<String>(numeroCliente.value);
    }
    if (cpfCnpj.present) {
      map['CPF_CNPJ'] = Variable<String>(cpfCnpj.value);
    }
    if (nome.present) {
      map['Nome'] = Variable<String>(nome.value);
    }
    if (enderecoCompleto.present) {
      map['EnderecoCompleto'] = Variable<String>(enderecoCompleto.value);
    }
    if (telefone1.present) {
      map['Telefone1'] = Variable<String>(telefone1.value);
    }
    if (telefone2.present) {
      map['Telefone2'] = Variable<String>(telefone2.value);
    }
    if (email.present) {
      map['Email'] = Variable<String>(email.value);
    }
    if (preCadastro.present) {
      map['pre_cadastro'] = Variable<String>(preCadastro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('numeroCliente: $numeroCliente, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('nome: $nome, ')
          ..write('enderecoCompleto: $enderecoCompleto, ')
          ..write('telefone1: $telefone1, ')
          ..write('telefone2: $telefone2, ')
          ..write('email: $email, ')
          ..write('preCadastro: $preCadastro')
          ..write(')'))
        .toString();
  }
}

class $ProdutosTable extends Produtos with TableInfo<$ProdutosTable, Produto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProdutosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _referenciaMeta =
      const VerificationMeta('referencia');
  @override
  late final GeneratedColumn<String> referencia = GeneratedColumn<String>(
      'Referencia', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _descricaoMeta =
      const VerificationMeta('descricao');
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
      'Descricao', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
      'Valor', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, referencia, descricao, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produtos';
  @override
  VerificationContext validateIntegrity(Insertable<Produto> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('Referencia')) {
      context.handle(
          _referenciaMeta,
          referencia.isAcceptableOrUnknown(
              data['Referencia']!, _referenciaMeta));
    } else if (isInserting) {
      context.missing(_referenciaMeta);
    }
    if (data.containsKey('Descricao')) {
      context.handle(_descricaoMeta,
          descricao.isAcceptableOrUnknown(data['Descricao']!, _descricaoMeta));
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('Valor')) {
      context.handle(
          _valorMeta, valor.isAcceptableOrUnknown(data['Valor']!, _valorMeta));
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Produto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Produto(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      referencia: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Referencia'])!,
      descricao: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Descricao'])!,
      valor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}Valor'])!,
    );
  }

  @override
  $ProdutosTable createAlias(String alias) {
    return $ProdutosTable(attachedDatabase, alias);
  }
}

class Produto extends DataClass implements Insertable<Produto> {
  final int id;
  final String referencia;
  final String descricao;
  final double valor;
  const Produto(
      {required this.id,
      required this.referencia,
      required this.descricao,
      required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['Referencia'] = Variable<String>(referencia);
    map['Descricao'] = Variable<String>(descricao);
    map['Valor'] = Variable<double>(valor);
    return map;
  }

  ProdutosCompanion toCompanion(bool nullToAbsent) {
    return ProdutosCompanion(
      id: Value(id),
      referencia: Value(referencia),
      descricao: Value(descricao),
      valor: Value(valor),
    );
  }

  factory Produto.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Produto(
      id: serializer.fromJson<int>(json['id']),
      referencia: serializer.fromJson<String>(json['referencia']),
      descricao: serializer.fromJson<String>(json['descricao']),
      valor: serializer.fromJson<double>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'referencia': serializer.toJson<String>(referencia),
      'descricao': serializer.toJson<String>(descricao),
      'valor': serializer.toJson<double>(valor),
    };
  }

  Produto copyWith(
          {int? id, String? referencia, String? descricao, double? valor}) =>
      Produto(
        id: id ?? this.id,
        referencia: referencia ?? this.referencia,
        descricao: descricao ?? this.descricao,
        valor: valor ?? this.valor,
      );
  Produto copyWithCompanion(ProdutosCompanion data) {
    return Produto(
      id: data.id.present ? data.id.value : this.id,
      referencia:
          data.referencia.present ? data.referencia.value : this.referencia,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Produto(')
          ..write('id: $id, ')
          ..write('referencia: $referencia, ')
          ..write('descricao: $descricao, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, referencia, descricao, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Produto &&
          other.id == this.id &&
          other.referencia == this.referencia &&
          other.descricao == this.descricao &&
          other.valor == this.valor);
}

class ProdutosCompanion extends UpdateCompanion<Produto> {
  final Value<int> id;
  final Value<String> referencia;
  final Value<String> descricao;
  final Value<double> valor;
  const ProdutosCompanion({
    this.id = const Value.absent(),
    this.referencia = const Value.absent(),
    this.descricao = const Value.absent(),
    this.valor = const Value.absent(),
  });
  ProdutosCompanion.insert({
    this.id = const Value.absent(),
    required String referencia,
    required String descricao,
    required double valor,
  })  : referencia = Value(referencia),
        descricao = Value(descricao),
        valor = Value(valor);
  static Insertable<Produto> custom({
    Expression<int>? id,
    Expression<String>? referencia,
    Expression<String>? descricao,
    Expression<double>? valor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (referencia != null) 'Referencia': referencia,
      if (descricao != null) 'Descricao': descricao,
      if (valor != null) 'Valor': valor,
    });
  }

  ProdutosCompanion copyWith(
      {Value<int>? id,
      Value<String>? referencia,
      Value<String>? descricao,
      Value<double>? valor}) {
    return ProdutosCompanion(
      id: id ?? this.id,
      referencia: referencia ?? this.referencia,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (referencia.present) {
      map['Referencia'] = Variable<String>(referencia.value);
    }
    if (descricao.present) {
      map['Descricao'] = Variable<String>(descricao.value);
    }
    if (valor.present) {
      map['Valor'] = Variable<double>(valor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProdutosCompanion(')
          ..write('id: $id, ')
          ..write('referencia: $referencia, ')
          ..write('descricao: $descricao, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }
}

class $PedidosPendentesTable extends PedidosPendentes
    with TableInfo<$PedidosPendentesTable, PedidoPendente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PedidosPendentesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _pedidoJsonMeta =
      const VerificationMeta('pedidoJson');
  @override
  late final GeneratedColumn<String> pedidoJson = GeneratedColumn<String>(
      'pedido_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, pedidoJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pedidos_pendentes';
  @override
  VerificationContext validateIntegrity(Insertable<PedidoPendente> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pedido_json')) {
      context.handle(
          _pedidoJsonMeta,
          pedidoJson.isAcceptableOrUnknown(
              data['pedido_json']!, _pedidoJsonMeta));
    } else if (isInserting) {
      context.missing(_pedidoJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PedidoPendente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PedidoPendente(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      pedidoJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pedido_json'])!,
    );
  }

  @override
  $PedidosPendentesTable createAlias(String alias) {
    return $PedidosPendentesTable(attachedDatabase, alias);
  }
}

class PedidoPendente extends DataClass implements Insertable<PedidoPendente> {
  final int id;
  final String pedidoJson;
  const PedidoPendente({required this.id, required this.pedidoJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pedido_json'] = Variable<String>(pedidoJson);
    return map;
  }

  PedidosPendentesCompanion toCompanion(bool nullToAbsent) {
    return PedidosPendentesCompanion(
      id: Value(id),
      pedidoJson: Value(pedidoJson),
    );
  }

  factory PedidoPendente.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PedidoPendente(
      id: serializer.fromJson<int>(json['id']),
      pedidoJson: serializer.fromJson<String>(json['pedidoJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pedidoJson': serializer.toJson<String>(pedidoJson),
    };
  }

  PedidoPendente copyWith({int? id, String? pedidoJson}) => PedidoPendente(
        id: id ?? this.id,
        pedidoJson: pedidoJson ?? this.pedidoJson,
      );
  PedidoPendente copyWithCompanion(PedidosPendentesCompanion data) {
    return PedidoPendente(
      id: data.id.present ? data.id.value : this.id,
      pedidoJson:
          data.pedidoJson.present ? data.pedidoJson.value : this.pedidoJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PedidoPendente(')
          ..write('id: $id, ')
          ..write('pedidoJson: $pedidoJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pedidoJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PedidoPendente &&
          other.id == this.id &&
          other.pedidoJson == this.pedidoJson);
}

class PedidosPendentesCompanion extends UpdateCompanion<PedidoPendente> {
  final Value<int> id;
  final Value<String> pedidoJson;
  const PedidosPendentesCompanion({
    this.id = const Value.absent(),
    this.pedidoJson = const Value.absent(),
  });
  PedidosPendentesCompanion.insert({
    this.id = const Value.absent(),
    required String pedidoJson,
  }) : pedidoJson = Value(pedidoJson);
  static Insertable<PedidoPendente> custom({
    Expression<int>? id,
    Expression<String>? pedidoJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedidoJson != null) 'pedido_json': pedidoJson,
    });
  }

  PedidosPendentesCompanion copyWith(
      {Value<int>? id, Value<String>? pedidoJson}) {
    return PedidosPendentesCompanion(
      id: id ?? this.id,
      pedidoJson: pedidoJson ?? this.pedidoJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pedidoJson.present) {
      map['pedido_json'] = Variable<String>(pedidoJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PedidosPendentesCompanion(')
          ..write('id: $id, ')
          ..write('pedidoJson: $pedidoJson')
          ..write(')'))
        .toString();
  }
}

class $PedidosEnviadosTable extends PedidosEnviados
    with TableInfo<$PedidosEnviadosTable, PedidoEnviado> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PedidosEnviadosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _appPedidoIdMeta =
      const VerificationMeta('appPedidoId');
  @override
  late final GeneratedColumn<String> appPedidoId = GeneratedColumn<String>(
      'app_pedido_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pedidoJsonMeta =
      const VerificationMeta('pedidoJson');
  @override
  late final GeneratedColumn<String> pedidoJson = GeneratedColumn<String>(
      'pedido_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataEnvioMeta =
      const VerificationMeta('dataEnvio');
  @override
  late final GeneratedColumn<DateTime> dataEnvio = GeneratedColumn<DateTime>(
      'data_envio', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _numeroPedidoSapMeta =
      const VerificationMeta('numeroPedidoSap');
  @override
  late final GeneratedColumn<String> numeroPedidoSap = GeneratedColumn<String>(
      'numero_pedido_sap', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _obsCentralMeta =
      const VerificationMeta('obsCentral');
  @override
  late final GeneratedColumn<String> obsCentral = GeneratedColumn<String>(
      'obs_central', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        appPedidoId,
        pedidoJson,
        dataEnvio,
        numeroPedidoSap,
        status,
        obsCentral
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pedidos_enviados';
  @override
  VerificationContext validateIntegrity(Insertable<PedidoEnviado> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('app_pedido_id')) {
      context.handle(
          _appPedidoIdMeta,
          appPedidoId.isAcceptableOrUnknown(
              data['app_pedido_id']!, _appPedidoIdMeta));
    }
    if (data.containsKey('pedido_json')) {
      context.handle(
          _pedidoJsonMeta,
          pedidoJson.isAcceptableOrUnknown(
              data['pedido_json']!, _pedidoJsonMeta));
    } else if (isInserting) {
      context.missing(_pedidoJsonMeta);
    }
    if (data.containsKey('data_envio')) {
      context.handle(_dataEnvioMeta,
          dataEnvio.isAcceptableOrUnknown(data['data_envio']!, _dataEnvioMeta));
    } else if (isInserting) {
      context.missing(_dataEnvioMeta);
    }
    if (data.containsKey('numero_pedido_sap')) {
      context.handle(
          _numeroPedidoSapMeta,
          numeroPedidoSap.isAcceptableOrUnknown(
              data['numero_pedido_sap']!, _numeroPedidoSapMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('obs_central')) {
      context.handle(
          _obsCentralMeta,
          obsCentral.isAcceptableOrUnknown(
              data['obs_central']!, _obsCentralMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PedidoEnviado map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PedidoEnviado(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      appPedidoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_pedido_id']),
      pedidoJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pedido_json'])!,
      dataEnvio: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}data_envio'])!,
      numeroPedidoSap: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}numero_pedido_sap']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status']),
      obsCentral: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}obs_central']),
    );
  }

  @override
  $PedidosEnviadosTable createAlias(String alias) {
    return $PedidosEnviadosTable(attachedDatabase, alias);
  }
}

class PedidoEnviado extends DataClass implements Insertable<PedidoEnviado> {
  final int id;
  final String? appPedidoId;
  final String pedidoJson;
  final DateTime dataEnvio;
  final String? numeroPedidoSap;
  final String? status;
  final String? obsCentral;
  const PedidoEnviado(
      {required this.id,
      this.appPedidoId,
      required this.pedidoJson,
      required this.dataEnvio,
      this.numeroPedidoSap,
      this.status,
      this.obsCentral});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || appPedidoId != null) {
      map['app_pedido_id'] = Variable<String>(appPedidoId);
    }
    map['pedido_json'] = Variable<String>(pedidoJson);
    map['data_envio'] = Variable<DateTime>(dataEnvio);
    if (!nullToAbsent || numeroPedidoSap != null) {
      map['numero_pedido_sap'] = Variable<String>(numeroPedidoSap);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || obsCentral != null) {
      map['obs_central'] = Variable<String>(obsCentral);
    }
    return map;
  }

  PedidosEnviadosCompanion toCompanion(bool nullToAbsent) {
    return PedidosEnviadosCompanion(
      id: Value(id),
      appPedidoId: appPedidoId == null && nullToAbsent
          ? const Value.absent()
          : Value(appPedidoId),
      pedidoJson: Value(pedidoJson),
      dataEnvio: Value(dataEnvio),
      numeroPedidoSap: numeroPedidoSap == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroPedidoSap),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
      obsCentral: obsCentral == null && nullToAbsent
          ? const Value.absent()
          : Value(obsCentral),
    );
  }

  factory PedidoEnviado.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PedidoEnviado(
      id: serializer.fromJson<int>(json['id']),
      appPedidoId: serializer.fromJson<String?>(json['appPedidoId']),
      pedidoJson: serializer.fromJson<String>(json['pedidoJson']),
      dataEnvio: serializer.fromJson<DateTime>(json['dataEnvio']),
      numeroPedidoSap: serializer.fromJson<String?>(json['numeroPedidoSap']),
      status: serializer.fromJson<String?>(json['status']),
      obsCentral: serializer.fromJson<String?>(json['obsCentral']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'appPedidoId': serializer.toJson<String?>(appPedidoId),
      'pedidoJson': serializer.toJson<String>(pedidoJson),
      'dataEnvio': serializer.toJson<DateTime>(dataEnvio),
      'numeroPedidoSap': serializer.toJson<String?>(numeroPedidoSap),
      'status': serializer.toJson<String?>(status),
      'obsCentral': serializer.toJson<String?>(obsCentral),
    };
  }

  PedidoEnviado copyWith(
          {int? id,
          Value<String?> appPedidoId = const Value.absent(),
          String? pedidoJson,
          DateTime? dataEnvio,
          Value<String?> numeroPedidoSap = const Value.absent(),
          Value<String?> status = const Value.absent(),
          Value<String?> obsCentral = const Value.absent()}) =>
      PedidoEnviado(
        id: id ?? this.id,
        appPedidoId: appPedidoId.present ? appPedidoId.value : this.appPedidoId,
        pedidoJson: pedidoJson ?? this.pedidoJson,
        dataEnvio: dataEnvio ?? this.dataEnvio,
        numeroPedidoSap: numeroPedidoSap.present
            ? numeroPedidoSap.value
            : this.numeroPedidoSap,
        status: status.present ? status.value : this.status,
        obsCentral: obsCentral.present ? obsCentral.value : this.obsCentral,
      );
  PedidoEnviado copyWithCompanion(PedidosEnviadosCompanion data) {
    return PedidoEnviado(
      id: data.id.present ? data.id.value : this.id,
      appPedidoId:
          data.appPedidoId.present ? data.appPedidoId.value : this.appPedidoId,
      pedidoJson:
          data.pedidoJson.present ? data.pedidoJson.value : this.pedidoJson,
      dataEnvio: data.dataEnvio.present ? data.dataEnvio.value : this.dataEnvio,
      numeroPedidoSap: data.numeroPedidoSap.present
          ? data.numeroPedidoSap.value
          : this.numeroPedidoSap,
      status: data.status.present ? data.status.value : this.status,
      obsCentral:
          data.obsCentral.present ? data.obsCentral.value : this.obsCentral,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PedidoEnviado(')
          ..write('id: $id, ')
          ..write('appPedidoId: $appPedidoId, ')
          ..write('pedidoJson: $pedidoJson, ')
          ..write('dataEnvio: $dataEnvio, ')
          ..write('numeroPedidoSap: $numeroPedidoSap, ')
          ..write('status: $status, ')
          ..write('obsCentral: $obsCentral')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, appPedidoId, pedidoJson, dataEnvio,
      numeroPedidoSap, status, obsCentral);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PedidoEnviado &&
          other.id == this.id &&
          other.appPedidoId == this.appPedidoId &&
          other.pedidoJson == this.pedidoJson &&
          other.dataEnvio == this.dataEnvio &&
          other.numeroPedidoSap == this.numeroPedidoSap &&
          other.status == this.status &&
          other.obsCentral == this.obsCentral);
}

class PedidosEnviadosCompanion extends UpdateCompanion<PedidoEnviado> {
  final Value<int> id;
  final Value<String?> appPedidoId;
  final Value<String> pedidoJson;
  final Value<DateTime> dataEnvio;
  final Value<String?> numeroPedidoSap;
  final Value<String?> status;
  final Value<String?> obsCentral;
  const PedidosEnviadosCompanion({
    this.id = const Value.absent(),
    this.appPedidoId = const Value.absent(),
    this.pedidoJson = const Value.absent(),
    this.dataEnvio = const Value.absent(),
    this.numeroPedidoSap = const Value.absent(),
    this.status = const Value.absent(),
    this.obsCentral = const Value.absent(),
  });
  PedidosEnviadosCompanion.insert({
    this.id = const Value.absent(),
    this.appPedidoId = const Value.absent(),
    required String pedidoJson,
    required DateTime dataEnvio,
    this.numeroPedidoSap = const Value.absent(),
    this.status = const Value.absent(),
    this.obsCentral = const Value.absent(),
  })  : pedidoJson = Value(pedidoJson),
        dataEnvio = Value(dataEnvio);
  static Insertable<PedidoEnviado> custom({
    Expression<int>? id,
    Expression<String>? appPedidoId,
    Expression<String>? pedidoJson,
    Expression<DateTime>? dataEnvio,
    Expression<String>? numeroPedidoSap,
    Expression<String>? status,
    Expression<String>? obsCentral,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appPedidoId != null) 'app_pedido_id': appPedidoId,
      if (pedidoJson != null) 'pedido_json': pedidoJson,
      if (dataEnvio != null) 'data_envio': dataEnvio,
      if (numeroPedidoSap != null) 'numero_pedido_sap': numeroPedidoSap,
      if (status != null) 'status': status,
      if (obsCentral != null) 'obs_central': obsCentral,
    });
  }

  PedidosEnviadosCompanion copyWith(
      {Value<int>? id,
      Value<String?>? appPedidoId,
      Value<String>? pedidoJson,
      Value<DateTime>? dataEnvio,
      Value<String?>? numeroPedidoSap,
      Value<String?>? status,
      Value<String?>? obsCentral}) {
    return PedidosEnviadosCompanion(
      id: id ?? this.id,
      appPedidoId: appPedidoId ?? this.appPedidoId,
      pedidoJson: pedidoJson ?? this.pedidoJson,
      dataEnvio: dataEnvio ?? this.dataEnvio,
      numeroPedidoSap: numeroPedidoSap ?? this.numeroPedidoSap,
      status: status ?? this.status,
      obsCentral: obsCentral ?? this.obsCentral,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (appPedidoId.present) {
      map['app_pedido_id'] = Variable<String>(appPedidoId.value);
    }
    if (pedidoJson.present) {
      map['pedido_json'] = Variable<String>(pedidoJson.value);
    }
    if (dataEnvio.present) {
      map['data_envio'] = Variable<DateTime>(dataEnvio.value);
    }
    if (numeroPedidoSap.present) {
      map['numero_pedido_sap'] = Variable<String>(numeroPedidoSap.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (obsCentral.present) {
      map['obs_central'] = Variable<String>(obsCentral.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PedidosEnviadosCompanion(')
          ..write('id: $id, ')
          ..write('appPedidoId: $appPedidoId, ')
          ..write('pedidoJson: $pedidoJson, ')
          ..write('dataEnvio: $dataEnvio, ')
          ..write('numeroPedidoSap: $numeroPedidoSap, ')
          ..write('status: $status, ')
          ..write('obsCentral: $obsCentral')
          ..write(')'))
        .toString();
  }
}

class $PreCadastrosTable extends PreCadastros
    with TableInfo<$PreCadastrosTable, PreCadastro> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreCadastrosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _numeroClienteMeta =
      const VerificationMeta('numeroCliente');
  @override
  late final GeneratedColumn<String> numeroCliente = GeneratedColumn<String>(
      'NumeroCliente', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cpfCnpjMeta =
      const VerificationMeta('cpfCnpj');
  @override
  late final GeneratedColumn<String> cpfCnpj = GeneratedColumn<String>(
      'CPF_CNPJ', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'Nome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enderecoCompletoMeta =
      const VerificationMeta('enderecoCompleto');
  @override
  late final GeneratedColumn<String> enderecoCompleto = GeneratedColumn<String>(
      'EnderecoCompleto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telefone1Meta =
      const VerificationMeta('telefone1');
  @override
  late final GeneratedColumn<String> telefone1 = GeneratedColumn<String>(
      'Telefone1', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _telefone2Meta =
      const VerificationMeta('telefone2');
  @override
  late final GeneratedColumn<String> telefone2 = GeneratedColumn<String>(
      'Telefone2', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'Email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preCadastroMeta =
      const VerificationMeta('preCadastro');
  @override
  late final GeneratedColumn<String> preCadastro = GeneratedColumn<String>(
      'pre_cadastro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        numeroCliente,
        cpfCnpj,
        nome,
        enderecoCompleto,
        telefone1,
        telefone2,
        email,
        preCadastro
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pre_cadastros';
  @override
  VerificationContext validateIntegrity(Insertable<PreCadastro> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('NumeroCliente')) {
      context.handle(
          _numeroClienteMeta,
          numeroCliente.isAcceptableOrUnknown(
              data['NumeroCliente']!, _numeroClienteMeta));
    } else if (isInserting) {
      context.missing(_numeroClienteMeta);
    }
    if (data.containsKey('CPF_CNPJ')) {
      context.handle(_cpfCnpjMeta,
          cpfCnpj.isAcceptableOrUnknown(data['CPF_CNPJ']!, _cpfCnpjMeta));
    }
    if (data.containsKey('Nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['Nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('EnderecoCompleto')) {
      context.handle(
          _enderecoCompletoMeta,
          enderecoCompleto.isAcceptableOrUnknown(
              data['EnderecoCompleto']!, _enderecoCompletoMeta));
    }
    if (data.containsKey('Telefone1')) {
      context.handle(_telefone1Meta,
          telefone1.isAcceptableOrUnknown(data['Telefone1']!, _telefone1Meta));
    }
    if (data.containsKey('Telefone2')) {
      context.handle(_telefone2Meta,
          telefone2.isAcceptableOrUnknown(data['Telefone2']!, _telefone2Meta));
    }
    if (data.containsKey('Email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['Email']!, _emailMeta));
    }
    if (data.containsKey('pre_cadastro')) {
      context.handle(
          _preCadastroMeta,
          preCadastro.isAcceptableOrUnknown(
              data['pre_cadastro']!, _preCadastroMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreCadastro map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreCadastro(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      numeroCliente: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}NumeroCliente'])!,
      cpfCnpj: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}CPF_CNPJ']),
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Nome'])!,
      enderecoCompleto: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}EnderecoCompleto']),
      telefone1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Telefone1']),
      telefone2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Telefone2']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Email']),
      preCadastro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pre_cadastro']),
    );
  }

  @override
  $PreCadastrosTable createAlias(String alias) {
    return $PreCadastrosTable(attachedDatabase, alias);
  }
}

class PreCadastro extends DataClass implements Insertable<PreCadastro> {
  final int id;
  final String numeroCliente;
  final String? cpfCnpj;
  final String nome;
  final String? enderecoCompleto;
  final String? telefone1;
  final String? telefone2;
  final String? email;
  final String? preCadastro;
  const PreCadastro(
      {required this.id,
      required this.numeroCliente,
      this.cpfCnpj,
      required this.nome,
      this.enderecoCompleto,
      this.telefone1,
      this.telefone2,
      this.email,
      this.preCadastro});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['NumeroCliente'] = Variable<String>(numeroCliente);
    if (!nullToAbsent || cpfCnpj != null) {
      map['CPF_CNPJ'] = Variable<String>(cpfCnpj);
    }
    map['Nome'] = Variable<String>(nome);
    if (!nullToAbsent || enderecoCompleto != null) {
      map['EnderecoCompleto'] = Variable<String>(enderecoCompleto);
    }
    if (!nullToAbsent || telefone1 != null) {
      map['Telefone1'] = Variable<String>(telefone1);
    }
    if (!nullToAbsent || telefone2 != null) {
      map['Telefone2'] = Variable<String>(telefone2);
    }
    if (!nullToAbsent || email != null) {
      map['Email'] = Variable<String>(email);
    }
    if (!nullToAbsent || preCadastro != null) {
      map['pre_cadastro'] = Variable<String>(preCadastro);
    }
    return map;
  }

  PreCadastrosCompanion toCompanion(bool nullToAbsent) {
    return PreCadastrosCompanion(
      id: Value(id),
      numeroCliente: Value(numeroCliente),
      cpfCnpj: cpfCnpj == null && nullToAbsent
          ? const Value.absent()
          : Value(cpfCnpj),
      nome: Value(nome),
      enderecoCompleto: enderecoCompleto == null && nullToAbsent
          ? const Value.absent()
          : Value(enderecoCompleto),
      telefone1: telefone1 == null && nullToAbsent
          ? const Value.absent()
          : Value(telefone1),
      telefone2: telefone2 == null && nullToAbsent
          ? const Value.absent()
          : Value(telefone2),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      preCadastro: preCadastro == null && nullToAbsent
          ? const Value.absent()
          : Value(preCadastro),
    );
  }

  factory PreCadastro.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreCadastro(
      id: serializer.fromJson<int>(json['id']),
      numeroCliente: serializer.fromJson<String>(json['numeroCliente']),
      cpfCnpj: serializer.fromJson<String?>(json['cpfCnpj']),
      nome: serializer.fromJson<String>(json['nome']),
      enderecoCompleto: serializer.fromJson<String?>(json['enderecoCompleto']),
      telefone1: serializer.fromJson<String?>(json['telefone1']),
      telefone2: serializer.fromJson<String?>(json['telefone2']),
      email: serializer.fromJson<String?>(json['email']),
      preCadastro: serializer.fromJson<String?>(json['preCadastro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'numeroCliente': serializer.toJson<String>(numeroCliente),
      'cpfCnpj': serializer.toJson<String?>(cpfCnpj),
      'nome': serializer.toJson<String>(nome),
      'enderecoCompleto': serializer.toJson<String?>(enderecoCompleto),
      'telefone1': serializer.toJson<String?>(telefone1),
      'telefone2': serializer.toJson<String?>(telefone2),
      'email': serializer.toJson<String?>(email),
      'preCadastro': serializer.toJson<String?>(preCadastro),
    };
  }

  PreCadastro copyWith(
          {int? id,
          String? numeroCliente,
          Value<String?> cpfCnpj = const Value.absent(),
          String? nome,
          Value<String?> enderecoCompleto = const Value.absent(),
          Value<String?> telefone1 = const Value.absent(),
          Value<String?> telefone2 = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> preCadastro = const Value.absent()}) =>
      PreCadastro(
        id: id ?? this.id,
        numeroCliente: numeroCliente ?? this.numeroCliente,
        cpfCnpj: cpfCnpj.present ? cpfCnpj.value : this.cpfCnpj,
        nome: nome ?? this.nome,
        enderecoCompleto: enderecoCompleto.present
            ? enderecoCompleto.value
            : this.enderecoCompleto,
        telefone1: telefone1.present ? telefone1.value : this.telefone1,
        telefone2: telefone2.present ? telefone2.value : this.telefone2,
        email: email.present ? email.value : this.email,
        preCadastro: preCadastro.present ? preCadastro.value : this.preCadastro,
      );
  PreCadastro copyWithCompanion(PreCadastrosCompanion data) {
    return PreCadastro(
      id: data.id.present ? data.id.value : this.id,
      numeroCliente: data.numeroCliente.present
          ? data.numeroCliente.value
          : this.numeroCliente,
      cpfCnpj: data.cpfCnpj.present ? data.cpfCnpj.value : this.cpfCnpj,
      nome: data.nome.present ? data.nome.value : this.nome,
      enderecoCompleto: data.enderecoCompleto.present
          ? data.enderecoCompleto.value
          : this.enderecoCompleto,
      telefone1: data.telefone1.present ? data.telefone1.value : this.telefone1,
      telefone2: data.telefone2.present ? data.telefone2.value : this.telefone2,
      email: data.email.present ? data.email.value : this.email,
      preCadastro:
          data.preCadastro.present ? data.preCadastro.value : this.preCadastro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreCadastro(')
          ..write('id: $id, ')
          ..write('numeroCliente: $numeroCliente, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('nome: $nome, ')
          ..write('enderecoCompleto: $enderecoCompleto, ')
          ..write('telefone1: $telefone1, ')
          ..write('telefone2: $telefone2, ')
          ..write('email: $email, ')
          ..write('preCadastro: $preCadastro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, numeroCliente, cpfCnpj, nome,
      enderecoCompleto, telefone1, telefone2, email, preCadastro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreCadastro &&
          other.id == this.id &&
          other.numeroCliente == this.numeroCliente &&
          other.cpfCnpj == this.cpfCnpj &&
          other.nome == this.nome &&
          other.enderecoCompleto == this.enderecoCompleto &&
          other.telefone1 == this.telefone1 &&
          other.telefone2 == this.telefone2 &&
          other.email == this.email &&
          other.preCadastro == this.preCadastro);
}

class PreCadastrosCompanion extends UpdateCompanion<PreCadastro> {
  final Value<int> id;
  final Value<String> numeroCliente;
  final Value<String?> cpfCnpj;
  final Value<String> nome;
  final Value<String?> enderecoCompleto;
  final Value<String?> telefone1;
  final Value<String?> telefone2;
  final Value<String?> email;
  final Value<String?> preCadastro;
  const PreCadastrosCompanion({
    this.id = const Value.absent(),
    this.numeroCliente = const Value.absent(),
    this.cpfCnpj = const Value.absent(),
    this.nome = const Value.absent(),
    this.enderecoCompleto = const Value.absent(),
    this.telefone1 = const Value.absent(),
    this.telefone2 = const Value.absent(),
    this.email = const Value.absent(),
    this.preCadastro = const Value.absent(),
  });
  PreCadastrosCompanion.insert({
    this.id = const Value.absent(),
    required String numeroCliente,
    this.cpfCnpj = const Value.absent(),
    required String nome,
    this.enderecoCompleto = const Value.absent(),
    this.telefone1 = const Value.absent(),
    this.telefone2 = const Value.absent(),
    this.email = const Value.absent(),
    this.preCadastro = const Value.absent(),
  })  : numeroCliente = Value(numeroCliente),
        nome = Value(nome);
  static Insertable<PreCadastro> custom({
    Expression<int>? id,
    Expression<String>? numeroCliente,
    Expression<String>? cpfCnpj,
    Expression<String>? nome,
    Expression<String>? enderecoCompleto,
    Expression<String>? telefone1,
    Expression<String>? telefone2,
    Expression<String>? email,
    Expression<String>? preCadastro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numeroCliente != null) 'NumeroCliente': numeroCliente,
      if (cpfCnpj != null) 'CPF_CNPJ': cpfCnpj,
      if (nome != null) 'Nome': nome,
      if (enderecoCompleto != null) 'EnderecoCompleto': enderecoCompleto,
      if (telefone1 != null) 'Telefone1': telefone1,
      if (telefone2 != null) 'Telefone2': telefone2,
      if (email != null) 'Email': email,
      if (preCadastro != null) 'pre_cadastro': preCadastro,
    });
  }

  PreCadastrosCompanion copyWith(
      {Value<int>? id,
      Value<String>? numeroCliente,
      Value<String?>? cpfCnpj,
      Value<String>? nome,
      Value<String?>? enderecoCompleto,
      Value<String?>? telefone1,
      Value<String?>? telefone2,
      Value<String?>? email,
      Value<String?>? preCadastro}) {
    return PreCadastrosCompanion(
      id: id ?? this.id,
      numeroCliente: numeroCliente ?? this.numeroCliente,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      nome: nome ?? this.nome,
      enderecoCompleto: enderecoCompleto ?? this.enderecoCompleto,
      telefone1: telefone1 ?? this.telefone1,
      telefone2: telefone2 ?? this.telefone2,
      email: email ?? this.email,
      preCadastro: preCadastro ?? this.preCadastro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (numeroCliente.present) {
      map['NumeroCliente'] = Variable<String>(numeroCliente.value);
    }
    if (cpfCnpj.present) {
      map['CPF_CNPJ'] = Variable<String>(cpfCnpj.value);
    }
    if (nome.present) {
      map['Nome'] = Variable<String>(nome.value);
    }
    if (enderecoCompleto.present) {
      map['EnderecoCompleto'] = Variable<String>(enderecoCompleto.value);
    }
    if (telefone1.present) {
      map['Telefone1'] = Variable<String>(telefone1.value);
    }
    if (telefone2.present) {
      map['Telefone2'] = Variable<String>(telefone2.value);
    }
    if (email.present) {
      map['Email'] = Variable<String>(email.value);
    }
    if (preCadastro.present) {
      map['pre_cadastro'] = Variable<String>(preCadastro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreCadastrosCompanion(')
          ..write('id: $id, ')
          ..write('numeroCliente: $numeroCliente, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('nome: $nome, ')
          ..write('enderecoCompleto: $enderecoCompleto, ')
          ..write('telefone1: $telefone1, ')
          ..write('telefone2: $telefone2, ')
          ..write('email: $email, ')
          ..write('preCadastro: $preCadastro')
          ..write(')'))
        .toString();
  }
}

class $EnderecosAlternativosTable extends EnderecosAlternativos
    with TableInfo<$EnderecosAlternativosTable, EnderecoAlternativo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnderecosAlternativosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _cpfCnpjMeta =
      const VerificationMeta('cpfCnpj');
  @override
  late final GeneratedColumn<String> cpfCnpj = GeneratedColumn<String>(
      'CPF_CNPJ', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numeroClienteMeta =
      const VerificationMeta('numeroCliente');
  @override
  late final GeneratedColumn<String> numeroCliente = GeneratedColumn<String>(
      'NumeroCliente', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _enderecoFormatadoMeta =
      const VerificationMeta('enderecoFormatado');
  @override
  late final GeneratedColumn<String> enderecoFormatado =
      GeneratedColumn<String>('EnderecoFormatado', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, cpfCnpj, numeroCliente, enderecoFormatado];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'enderecos_alternativos';
  @override
  VerificationContext validateIntegrity(
      Insertable<EnderecoAlternativo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('CPF_CNPJ')) {
      context.handle(_cpfCnpjMeta,
          cpfCnpj.isAcceptableOrUnknown(data['CPF_CNPJ']!, _cpfCnpjMeta));
    } else if (isInserting) {
      context.missing(_cpfCnpjMeta);
    }
    if (data.containsKey('NumeroCliente')) {
      context.handle(
          _numeroClienteMeta,
          numeroCliente.isAcceptableOrUnknown(
              data['NumeroCliente']!, _numeroClienteMeta));
    } else if (isInserting) {
      context.missing(_numeroClienteMeta);
    }
    if (data.containsKey('EnderecoFormatado')) {
      context.handle(
          _enderecoFormatadoMeta,
          enderecoFormatado.isAcceptableOrUnknown(
              data['EnderecoFormatado']!, _enderecoFormatadoMeta));
    } else if (isInserting) {
      context.missing(_enderecoFormatadoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnderecoAlternativo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnderecoAlternativo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      cpfCnpj: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}CPF_CNPJ'])!,
      numeroCliente: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}NumeroCliente'])!,
      enderecoFormatado: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}EnderecoFormatado'])!,
    );
  }

  @override
  $EnderecosAlternativosTable createAlias(String alias) {
    return $EnderecosAlternativosTable(attachedDatabase, alias);
  }
}

class EnderecoAlternativo extends DataClass
    implements Insertable<EnderecoAlternativo> {
  final int id;
  final String cpfCnpj;
  final String numeroCliente;
  final String enderecoFormatado;
  const EnderecoAlternativo(
      {required this.id,
      required this.cpfCnpj,
      required this.numeroCliente,
      required this.enderecoFormatado});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['CPF_CNPJ'] = Variable<String>(cpfCnpj);
    map['NumeroCliente'] = Variable<String>(numeroCliente);
    map['EnderecoFormatado'] = Variable<String>(enderecoFormatado);
    return map;
  }

  EnderecosAlternativosCompanion toCompanion(bool nullToAbsent) {
    return EnderecosAlternativosCompanion(
      id: Value(id),
      cpfCnpj: Value(cpfCnpj),
      numeroCliente: Value(numeroCliente),
      enderecoFormatado: Value(enderecoFormatado),
    );
  }

  factory EnderecoAlternativo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnderecoAlternativo(
      id: serializer.fromJson<int>(json['id']),
      cpfCnpj: serializer.fromJson<String>(json['cpfCnpj']),
      numeroCliente: serializer.fromJson<String>(json['numeroCliente']),
      enderecoFormatado: serializer.fromJson<String>(json['enderecoFormatado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cpfCnpj': serializer.toJson<String>(cpfCnpj),
      'numeroCliente': serializer.toJson<String>(numeroCliente),
      'enderecoFormatado': serializer.toJson<String>(enderecoFormatado),
    };
  }

  EnderecoAlternativo copyWith(
          {int? id,
          String? cpfCnpj,
          String? numeroCliente,
          String? enderecoFormatado}) =>
      EnderecoAlternativo(
        id: id ?? this.id,
        cpfCnpj: cpfCnpj ?? this.cpfCnpj,
        numeroCliente: numeroCliente ?? this.numeroCliente,
        enderecoFormatado: enderecoFormatado ?? this.enderecoFormatado,
      );
  EnderecoAlternativo copyWithCompanion(EnderecosAlternativosCompanion data) {
    return EnderecoAlternativo(
      id: data.id.present ? data.id.value : this.id,
      cpfCnpj: data.cpfCnpj.present ? data.cpfCnpj.value : this.cpfCnpj,
      numeroCliente: data.numeroCliente.present
          ? data.numeroCliente.value
          : this.numeroCliente,
      enderecoFormatado: data.enderecoFormatado.present
          ? data.enderecoFormatado.value
          : this.enderecoFormatado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnderecoAlternativo(')
          ..write('id: $id, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('numeroCliente: $numeroCliente, ')
          ..write('enderecoFormatado: $enderecoFormatado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cpfCnpj, numeroCliente, enderecoFormatado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnderecoAlternativo &&
          other.id == this.id &&
          other.cpfCnpj == this.cpfCnpj &&
          other.numeroCliente == this.numeroCliente &&
          other.enderecoFormatado == this.enderecoFormatado);
}

class EnderecosAlternativosCompanion
    extends UpdateCompanion<EnderecoAlternativo> {
  final Value<int> id;
  final Value<String> cpfCnpj;
  final Value<String> numeroCliente;
  final Value<String> enderecoFormatado;
  const EnderecosAlternativosCompanion({
    this.id = const Value.absent(),
    this.cpfCnpj = const Value.absent(),
    this.numeroCliente = const Value.absent(),
    this.enderecoFormatado = const Value.absent(),
  });
  EnderecosAlternativosCompanion.insert({
    this.id = const Value.absent(),
    required String cpfCnpj,
    required String numeroCliente,
    required String enderecoFormatado,
  })  : cpfCnpj = Value(cpfCnpj),
        numeroCliente = Value(numeroCliente),
        enderecoFormatado = Value(enderecoFormatado);
  static Insertable<EnderecoAlternativo> custom({
    Expression<int>? id,
    Expression<String>? cpfCnpj,
    Expression<String>? numeroCliente,
    Expression<String>? enderecoFormatado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cpfCnpj != null) 'CPF_CNPJ': cpfCnpj,
      if (numeroCliente != null) 'NumeroCliente': numeroCliente,
      if (enderecoFormatado != null) 'EnderecoFormatado': enderecoFormatado,
    });
  }

  EnderecosAlternativosCompanion copyWith(
      {Value<int>? id,
      Value<String>? cpfCnpj,
      Value<String>? numeroCliente,
      Value<String>? enderecoFormatado}) {
    return EnderecosAlternativosCompanion(
      id: id ?? this.id,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      numeroCliente: numeroCliente ?? this.numeroCliente,
      enderecoFormatado: enderecoFormatado ?? this.enderecoFormatado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cpfCnpj.present) {
      map['CPF_CNPJ'] = Variable<String>(cpfCnpj.value);
    }
    if (numeroCliente.present) {
      map['NumeroCliente'] = Variable<String>(numeroCliente.value);
    }
    if (enderecoFormatado.present) {
      map['EnderecoFormatado'] = Variable<String>(enderecoFormatado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnderecosAlternativosCompanion(')
          ..write('id: $id, ')
          ..write('cpfCnpj: $cpfCnpj, ')
          ..write('numeroCliente: $numeroCliente, ')
          ..write('enderecoFormatado: $enderecoFormatado')
          ..write(')'))
        .toString();
  }
}

class $ProdutoCategoriasTable extends ProdutoCategorias
    with TableInfo<$ProdutoCategoriasTable, ProdutoCategoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProdutoCategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _materialMeta =
      const VerificationMeta('material');
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
      'Material', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phl4Meta = const VerificationMeta('phl4');
  @override
  late final GeneratedColumn<String> phl4 = GeneratedColumn<String>(
      'PHL4', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phl5Meta = const VerificationMeta('phl5');
  @override
  late final GeneratedColumn<String> phl5 = GeneratedColumn<String>(
      'PHL5', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phl6Meta = const VerificationMeta('phl6');
  @override
  late final GeneratedColumn<String> phl6 = GeneratedColumn<String>(
      'PHL6', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _brandTopNodeMeta =
      const VerificationMeta('brandTopNode');
  @override
  late final GeneratedColumn<String> brandTopNode = GeneratedColumn<String>(
      'BrandTopNode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [material, phl4, phl5, phl6, brandTopNode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produto_categorias';
  @override
  VerificationContext validateIntegrity(Insertable<ProdutoCategoria> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('Material')) {
      context.handle(_materialMeta,
          material.isAcceptableOrUnknown(data['Material']!, _materialMeta));
    } else if (isInserting) {
      context.missing(_materialMeta);
    }
    if (data.containsKey('PHL4')) {
      context.handle(
          _phl4Meta, phl4.isAcceptableOrUnknown(data['PHL4']!, _phl4Meta));
    }
    if (data.containsKey('PHL5')) {
      context.handle(
          _phl5Meta, phl5.isAcceptableOrUnknown(data['PHL5']!, _phl5Meta));
    }
    if (data.containsKey('PHL6')) {
      context.handle(
          _phl6Meta, phl6.isAcceptableOrUnknown(data['PHL6']!, _phl6Meta));
    }
    if (data.containsKey('BrandTopNode')) {
      context.handle(
          _brandTopNodeMeta,
          brandTopNode.isAcceptableOrUnknown(
              data['BrandTopNode']!, _brandTopNodeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {material};
  @override
  ProdutoCategoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProdutoCategoria(
      material: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}Material'])!,
      phl4: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}PHL4']),
      phl5: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}PHL5']),
      phl6: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}PHL6']),
      brandTopNode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}BrandTopNode']),
    );
  }

  @override
  $ProdutoCategoriasTable createAlias(String alias) {
    return $ProdutoCategoriasTable(attachedDatabase, alias);
  }
}

class ProdutoCategoria extends DataClass
    implements Insertable<ProdutoCategoria> {
  final String material;
  final String? phl4;
  final String? phl5;
  final String? phl6;
  final String? brandTopNode;
  const ProdutoCategoria(
      {required this.material,
      this.phl4,
      this.phl5,
      this.phl6,
      this.brandTopNode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['Material'] = Variable<String>(material);
    if (!nullToAbsent || phl4 != null) {
      map['PHL4'] = Variable<String>(phl4);
    }
    if (!nullToAbsent || phl5 != null) {
      map['PHL5'] = Variable<String>(phl5);
    }
    if (!nullToAbsent || phl6 != null) {
      map['PHL6'] = Variable<String>(phl6);
    }
    if (!nullToAbsent || brandTopNode != null) {
      map['BrandTopNode'] = Variable<String>(brandTopNode);
    }
    return map;
  }

  ProdutoCategoriasCompanion toCompanion(bool nullToAbsent) {
    return ProdutoCategoriasCompanion(
      material: Value(material),
      phl4: phl4 == null && nullToAbsent ? const Value.absent() : Value(phl4),
      phl5: phl5 == null && nullToAbsent ? const Value.absent() : Value(phl5),
      phl6: phl6 == null && nullToAbsent ? const Value.absent() : Value(phl6),
      brandTopNode: brandTopNode == null && nullToAbsent
          ? const Value.absent()
          : Value(brandTopNode),
    );
  }

  factory ProdutoCategoria.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProdutoCategoria(
      material: serializer.fromJson<String>(json['material']),
      phl4: serializer.fromJson<String?>(json['phl4']),
      phl5: serializer.fromJson<String?>(json['phl5']),
      phl6: serializer.fromJson<String?>(json['phl6']),
      brandTopNode: serializer.fromJson<String?>(json['brandTopNode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'material': serializer.toJson<String>(material),
      'phl4': serializer.toJson<String?>(phl4),
      'phl5': serializer.toJson<String?>(phl5),
      'phl6': serializer.toJson<String?>(phl6),
      'brandTopNode': serializer.toJson<String?>(brandTopNode),
    };
  }

  ProdutoCategoria copyWith(
          {String? material,
          Value<String?> phl4 = const Value.absent(),
          Value<String?> phl5 = const Value.absent(),
          Value<String?> phl6 = const Value.absent(),
          Value<String?> brandTopNode = const Value.absent()}) =>
      ProdutoCategoria(
        material: material ?? this.material,
        phl4: phl4.present ? phl4.value : this.phl4,
        phl5: phl5.present ? phl5.value : this.phl5,
        phl6: phl6.present ? phl6.value : this.phl6,
        brandTopNode:
            brandTopNode.present ? brandTopNode.value : this.brandTopNode,
      );
  ProdutoCategoria copyWithCompanion(ProdutoCategoriasCompanion data) {
    return ProdutoCategoria(
      material: data.material.present ? data.material.value : this.material,
      phl4: data.phl4.present ? data.phl4.value : this.phl4,
      phl5: data.phl5.present ? data.phl5.value : this.phl5,
      phl6: data.phl6.present ? data.phl6.value : this.phl6,
      brandTopNode: data.brandTopNode.present
          ? data.brandTopNode.value
          : this.brandTopNode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProdutoCategoria(')
          ..write('material: $material, ')
          ..write('phl4: $phl4, ')
          ..write('phl5: $phl5, ')
          ..write('phl6: $phl6, ')
          ..write('brandTopNode: $brandTopNode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(material, phl4, phl5, phl6, brandTopNode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProdutoCategoria &&
          other.material == this.material &&
          other.phl4 == this.phl4 &&
          other.phl5 == this.phl5 &&
          other.phl6 == this.phl6 &&
          other.brandTopNode == this.brandTopNode);
}

class ProdutoCategoriasCompanion extends UpdateCompanion<ProdutoCategoria> {
  final Value<String> material;
  final Value<String?> phl4;
  final Value<String?> phl5;
  final Value<String?> phl6;
  final Value<String?> brandTopNode;
  final Value<int> rowid;
  const ProdutoCategoriasCompanion({
    this.material = const Value.absent(),
    this.phl4 = const Value.absent(),
    this.phl5 = const Value.absent(),
    this.phl6 = const Value.absent(),
    this.brandTopNode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProdutoCategoriasCompanion.insert({
    required String material,
    this.phl4 = const Value.absent(),
    this.phl5 = const Value.absent(),
    this.phl6 = const Value.absent(),
    this.brandTopNode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : material = Value(material);
  static Insertable<ProdutoCategoria> custom({
    Expression<String>? material,
    Expression<String>? phl4,
    Expression<String>? phl5,
    Expression<String>? phl6,
    Expression<String>? brandTopNode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (material != null) 'Material': material,
      if (phl4 != null) 'PHL4': phl4,
      if (phl5 != null) 'PHL5': phl5,
      if (phl6 != null) 'PHL6': phl6,
      if (brandTopNode != null) 'BrandTopNode': brandTopNode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProdutoCategoriasCompanion copyWith(
      {Value<String>? material,
      Value<String?>? phl4,
      Value<String?>? phl5,
      Value<String?>? phl6,
      Value<String?>? brandTopNode,
      Value<int>? rowid}) {
    return ProdutoCategoriasCompanion(
      material: material ?? this.material,
      phl4: phl4 ?? this.phl4,
      phl5: phl5 ?? this.phl5,
      phl6: phl6 ?? this.phl6,
      brandTopNode: brandTopNode ?? this.brandTopNode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (material.present) {
      map['Material'] = Variable<String>(material.value);
    }
    if (phl4.present) {
      map['PHL4'] = Variable<String>(phl4.value);
    }
    if (phl5.present) {
      map['PHL5'] = Variable<String>(phl5.value);
    }
    if (phl6.present) {
      map['PHL6'] = Variable<String>(phl6.value);
    }
    if (brandTopNode.present) {
      map['BrandTopNode'] = Variable<String>(brandTopNode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProdutoCategoriasCompanion(')
          ..write('material: $material, ')
          ..write('phl4: $phl4, ')
          ..write('phl5: $phl5, ')
          ..write('phl6: $phl6, ')
          ..write('brandTopNode: $brandTopNode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $ProdutosTable produtos = $ProdutosTable(this);
  late final $PedidosPendentesTable pedidosPendentes =
      $PedidosPendentesTable(this);
  late final $PedidosEnviadosTable pedidosEnviados =
      $PedidosEnviadosTable(this);
  late final $PreCadastrosTable preCadastros = $PreCadastrosTable(this);
  late final $EnderecosAlternativosTable enderecosAlternativos =
      $EnderecosAlternativosTable(this);
  late final $ProdutoCategoriasTable produtoCategorias =
      $ProdutoCategoriasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        clientes,
        produtos,
        pedidosPendentes,
        pedidosEnviados,
        preCadastros,
        enderecosAlternativos,
        produtoCategorias
      ];
}

typedef $$ClientesTableCreateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  required String numeroCliente,
  Value<String?> cpfCnpj,
  required String nome,
  Value<String?> enderecoCompleto,
  Value<String?> telefone1,
  Value<String?> telefone2,
  Value<String?> email,
  Value<String?> preCadastro,
});
typedef $$ClientesTableUpdateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  Value<String> numeroCliente,
  Value<String?> cpfCnpj,
  Value<String> nome,
  Value<String?> enderecoCompleto,
  Value<String?> telefone1,
  Value<String?> telefone2,
  Value<String?> email,
  Value<String?> preCadastro,
});

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeroCliente => $composableBuilder(
      column: $table.numeroCliente, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get enderecoCompleto => $composableBuilder(
      column: $table.enderecoCompleto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefone1 => $composableBuilder(
      column: $table.telefone1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefone2 => $composableBuilder(
      column: $table.telefone2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preCadastro => $composableBuilder(
      column: $table.preCadastro, builder: (column) => ColumnFilters(column));
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numeroCliente => $composableBuilder(
      column: $table.numeroCliente,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get enderecoCompleto => $composableBuilder(
      column: $table.enderecoCompleto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefone1 => $composableBuilder(
      column: $table.telefone1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefone2 => $composableBuilder(
      column: $table.telefone2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preCadastro => $composableBuilder(
      column: $table.preCadastro, builder: (column) => ColumnOrderings(column));
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get numeroCliente => $composableBuilder(
      column: $table.numeroCliente, builder: (column) => column);

  GeneratedColumn<String> get cpfCnpj =>
      $composableBuilder(column: $table.cpfCnpj, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get enderecoCompleto => $composableBuilder(
      column: $table.enderecoCompleto, builder: (column) => column);

  GeneratedColumn<String> get telefone1 =>
      $composableBuilder(column: $table.telefone1, builder: (column) => column);

  GeneratedColumn<String> get telefone2 =>
      $composableBuilder(column: $table.telefone2, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get preCadastro => $composableBuilder(
      column: $table.preCadastro, builder: (column) => column);
}

class $$ClientesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientesTable,
    Cliente,
    $$ClientesTableFilterComposer,
    $$ClientesTableOrderingComposer,
    $$ClientesTableAnnotationComposer,
    $$ClientesTableCreateCompanionBuilder,
    $$ClientesTableUpdateCompanionBuilder,
    (Cliente, BaseReferences<_$AppDatabase, $ClientesTable, Cliente>),
    Cliente,
    PrefetchHooks Function()> {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> numeroCliente = const Value.absent(),
            Value<String?> cpfCnpj = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String?> enderecoCompleto = const Value.absent(),
            Value<String?> telefone1 = const Value.absent(),
            Value<String?> telefone2 = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> preCadastro = const Value.absent(),
          }) =>
              ClientesCompanion(
            id: id,
            numeroCliente: numeroCliente,
            cpfCnpj: cpfCnpj,
            nome: nome,
            enderecoCompleto: enderecoCompleto,
            telefone1: telefone1,
            telefone2: telefone2,
            email: email,
            preCadastro: preCadastro,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String numeroCliente,
            Value<String?> cpfCnpj = const Value.absent(),
            required String nome,
            Value<String?> enderecoCompleto = const Value.absent(),
            Value<String?> telefone1 = const Value.absent(),
            Value<String?> telefone2 = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> preCadastro = const Value.absent(),
          }) =>
              ClientesCompanion.insert(
            id: id,
            numeroCliente: numeroCliente,
            cpfCnpj: cpfCnpj,
            nome: nome,
            enderecoCompleto: enderecoCompleto,
            telefone1: telefone1,
            telefone2: telefone2,
            email: email,
            preCadastro: preCadastro,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClientesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientesTable,
    Cliente,
    $$ClientesTableFilterComposer,
    $$ClientesTableOrderingComposer,
    $$ClientesTableAnnotationComposer,
    $$ClientesTableCreateCompanionBuilder,
    $$ClientesTableUpdateCompanionBuilder,
    (Cliente, BaseReferences<_$AppDatabase, $ClientesTable, Cliente>),
    Cliente,
    PrefetchHooks Function()>;
typedef $$ProdutosTableCreateCompanionBuilder = ProdutosCompanion Function({
  Value<int> id,
  required String referencia,
  required String descricao,
  required double valor,
});
typedef $$ProdutosTableUpdateCompanionBuilder = ProdutosCompanion Function({
  Value<int> id,
  Value<String> referencia,
  Value<String> descricao,
  Value<double> valor,
});

class $$ProdutosTableFilterComposer
    extends Composer<_$AppDatabase, $ProdutosTable> {
  $$ProdutosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referencia => $composableBuilder(
      column: $table.referencia, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnFilters(column));
}

class $$ProdutosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProdutosTable> {
  $$ProdutosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referencia => $composableBuilder(
      column: $table.referencia, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descricao => $composableBuilder(
      column: $table.descricao, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get valor => $composableBuilder(
      column: $table.valor, builder: (column) => ColumnOrderings(column));
}

class $$ProdutosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProdutosTable> {
  $$ProdutosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get referencia => $composableBuilder(
      column: $table.referencia, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<double> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$ProdutosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProdutosTable,
    Produto,
    $$ProdutosTableFilterComposer,
    $$ProdutosTableOrderingComposer,
    $$ProdutosTableAnnotationComposer,
    $$ProdutosTableCreateCompanionBuilder,
    $$ProdutosTableUpdateCompanionBuilder,
    (Produto, BaseReferences<_$AppDatabase, $ProdutosTable, Produto>),
    Produto,
    PrefetchHooks Function()> {
  $$ProdutosTableTableManager(_$AppDatabase db, $ProdutosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProdutosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProdutosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProdutosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> referencia = const Value.absent(),
            Value<String> descricao = const Value.absent(),
            Value<double> valor = const Value.absent(),
          }) =>
              ProdutosCompanion(
            id: id,
            referencia: referencia,
            descricao: descricao,
            valor: valor,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String referencia,
            required String descricao,
            required double valor,
          }) =>
              ProdutosCompanion.insert(
            id: id,
            referencia: referencia,
            descricao: descricao,
            valor: valor,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProdutosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProdutosTable,
    Produto,
    $$ProdutosTableFilterComposer,
    $$ProdutosTableOrderingComposer,
    $$ProdutosTableAnnotationComposer,
    $$ProdutosTableCreateCompanionBuilder,
    $$ProdutosTableUpdateCompanionBuilder,
    (Produto, BaseReferences<_$AppDatabase, $ProdutosTable, Produto>),
    Produto,
    PrefetchHooks Function()>;
typedef $$PedidosPendentesTableCreateCompanionBuilder
    = PedidosPendentesCompanion Function({
  Value<int> id,
  required String pedidoJson,
});
typedef $$PedidosPendentesTableUpdateCompanionBuilder
    = PedidosPendentesCompanion Function({
  Value<int> id,
  Value<String> pedidoJson,
});

class $$PedidosPendentesTableFilterComposer
    extends Composer<_$AppDatabase, $PedidosPendentesTable> {
  $$PedidosPendentesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pedidoJson => $composableBuilder(
      column: $table.pedidoJson, builder: (column) => ColumnFilters(column));
}

class $$PedidosPendentesTableOrderingComposer
    extends Composer<_$AppDatabase, $PedidosPendentesTable> {
  $$PedidosPendentesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pedidoJson => $composableBuilder(
      column: $table.pedidoJson, builder: (column) => ColumnOrderings(column));
}

class $$PedidosPendentesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PedidosPendentesTable> {
  $$PedidosPendentesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pedidoJson => $composableBuilder(
      column: $table.pedidoJson, builder: (column) => column);
}

class $$PedidosPendentesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PedidosPendentesTable,
    PedidoPendente,
    $$PedidosPendentesTableFilterComposer,
    $$PedidosPendentesTableOrderingComposer,
    $$PedidosPendentesTableAnnotationComposer,
    $$PedidosPendentesTableCreateCompanionBuilder,
    $$PedidosPendentesTableUpdateCompanionBuilder,
    (
      PedidoPendente,
      BaseReferences<_$AppDatabase, $PedidosPendentesTable, PedidoPendente>
    ),
    PedidoPendente,
    PrefetchHooks Function()> {
  $$PedidosPendentesTableTableManager(
      _$AppDatabase db, $PedidosPendentesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PedidosPendentesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PedidosPendentesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PedidosPendentesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> pedidoJson = const Value.absent(),
          }) =>
              PedidosPendentesCompanion(
            id: id,
            pedidoJson: pedidoJson,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String pedidoJson,
          }) =>
              PedidosPendentesCompanion.insert(
            id: id,
            pedidoJson: pedidoJson,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PedidosPendentesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PedidosPendentesTable,
    PedidoPendente,
    $$PedidosPendentesTableFilterComposer,
    $$PedidosPendentesTableOrderingComposer,
    $$PedidosPendentesTableAnnotationComposer,
    $$PedidosPendentesTableCreateCompanionBuilder,
    $$PedidosPendentesTableUpdateCompanionBuilder,
    (
      PedidoPendente,
      BaseReferences<_$AppDatabase, $PedidosPendentesTable, PedidoPendente>
    ),
    PedidoPendente,
    PrefetchHooks Function()>;
typedef $$PedidosEnviadosTableCreateCompanionBuilder = PedidosEnviadosCompanion
    Function({
  Value<int> id,
  Value<String?> appPedidoId,
  required String pedidoJson,
  required DateTime dataEnvio,
  Value<String?> numeroPedidoSap,
  Value<String?> status,
  Value<String?> obsCentral,
});
typedef $$PedidosEnviadosTableUpdateCompanionBuilder = PedidosEnviadosCompanion
    Function({
  Value<int> id,
  Value<String?> appPedidoId,
  Value<String> pedidoJson,
  Value<DateTime> dataEnvio,
  Value<String?> numeroPedidoSap,
  Value<String?> status,
  Value<String?> obsCentral,
});

class $$PedidosEnviadosTableFilterComposer
    extends Composer<_$AppDatabase, $PedidosEnviadosTable> {
  $$PedidosEnviadosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appPedidoId => $composableBuilder(
      column: $table.appPedidoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pedidoJson => $composableBuilder(
      column: $table.pedidoJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dataEnvio => $composableBuilder(
      column: $table.dataEnvio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeroPedidoSap => $composableBuilder(
      column: $table.numeroPedidoSap,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get obsCentral => $composableBuilder(
      column: $table.obsCentral, builder: (column) => ColumnFilters(column));
}

class $$PedidosEnviadosTableOrderingComposer
    extends Composer<_$AppDatabase, $PedidosEnviadosTable> {
  $$PedidosEnviadosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appPedidoId => $composableBuilder(
      column: $table.appPedidoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pedidoJson => $composableBuilder(
      column: $table.pedidoJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dataEnvio => $composableBuilder(
      column: $table.dataEnvio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numeroPedidoSap => $composableBuilder(
      column: $table.numeroPedidoSap,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get obsCentral => $composableBuilder(
      column: $table.obsCentral, builder: (column) => ColumnOrderings(column));
}

class $$PedidosEnviadosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PedidosEnviadosTable> {
  $$PedidosEnviadosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get appPedidoId => $composableBuilder(
      column: $table.appPedidoId, builder: (column) => column);

  GeneratedColumn<String> get pedidoJson => $composableBuilder(
      column: $table.pedidoJson, builder: (column) => column);

  GeneratedColumn<DateTime> get dataEnvio =>
      $composableBuilder(column: $table.dataEnvio, builder: (column) => column);

  GeneratedColumn<String> get numeroPedidoSap => $composableBuilder(
      column: $table.numeroPedidoSap, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get obsCentral => $composableBuilder(
      column: $table.obsCentral, builder: (column) => column);
}

class $$PedidosEnviadosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PedidosEnviadosTable,
    PedidoEnviado,
    $$PedidosEnviadosTableFilterComposer,
    $$PedidosEnviadosTableOrderingComposer,
    $$PedidosEnviadosTableAnnotationComposer,
    $$PedidosEnviadosTableCreateCompanionBuilder,
    $$PedidosEnviadosTableUpdateCompanionBuilder,
    (
      PedidoEnviado,
      BaseReferences<_$AppDatabase, $PedidosEnviadosTable, PedidoEnviado>
    ),
    PedidoEnviado,
    PrefetchHooks Function()> {
  $$PedidosEnviadosTableTableManager(
      _$AppDatabase db, $PedidosEnviadosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PedidosEnviadosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PedidosEnviadosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PedidosEnviadosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> appPedidoId = const Value.absent(),
            Value<String> pedidoJson = const Value.absent(),
            Value<DateTime> dataEnvio = const Value.absent(),
            Value<String?> numeroPedidoSap = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<String?> obsCentral = const Value.absent(),
          }) =>
              PedidosEnviadosCompanion(
            id: id,
            appPedidoId: appPedidoId,
            pedidoJson: pedidoJson,
            dataEnvio: dataEnvio,
            numeroPedidoSap: numeroPedidoSap,
            status: status,
            obsCentral: obsCentral,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> appPedidoId = const Value.absent(),
            required String pedidoJson,
            required DateTime dataEnvio,
            Value<String?> numeroPedidoSap = const Value.absent(),
            Value<String?> status = const Value.absent(),
            Value<String?> obsCentral = const Value.absent(),
          }) =>
              PedidosEnviadosCompanion.insert(
            id: id,
            appPedidoId: appPedidoId,
            pedidoJson: pedidoJson,
            dataEnvio: dataEnvio,
            numeroPedidoSap: numeroPedidoSap,
            status: status,
            obsCentral: obsCentral,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PedidosEnviadosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PedidosEnviadosTable,
    PedidoEnviado,
    $$PedidosEnviadosTableFilterComposer,
    $$PedidosEnviadosTableOrderingComposer,
    $$PedidosEnviadosTableAnnotationComposer,
    $$PedidosEnviadosTableCreateCompanionBuilder,
    $$PedidosEnviadosTableUpdateCompanionBuilder,
    (
      PedidoEnviado,
      BaseReferences<_$AppDatabase, $PedidosEnviadosTable, PedidoEnviado>
    ),
    PedidoEnviado,
    PrefetchHooks Function()>;
typedef $$PreCadastrosTableCreateCompanionBuilder = PreCadastrosCompanion
    Function({
  Value<int> id,
  required String numeroCliente,
  Value<String?> cpfCnpj,
  required String nome,
  Value<String?> enderecoCompleto,
  Value<String?> telefone1,
  Value<String?> telefone2,
  Value<String?> email,
  Value<String?> preCadastro,
});
typedef $$PreCadastrosTableUpdateCompanionBuilder = PreCadastrosCompanion
    Function({
  Value<int> id,
  Value<String> numeroCliente,
  Value<String?> cpfCnpj,
  Value<String> nome,
  Value<String?> enderecoCompleto,
  Value<String?> telefone1,
  Value<String?> telefone2,
  Value<String?> email,
  Value<String?> preCadastro,
});

class $$PreCadastrosTableFilterComposer
    extends Composer<_$AppDatabase, $PreCadastrosTable> {
  $$PreCadastrosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeroCliente => $composableBuilder(
      column: $table.numeroCliente, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get enderecoCompleto => $composableBuilder(
      column: $table.enderecoCompleto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefone1 => $composableBuilder(
      column: $table.telefone1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefone2 => $composableBuilder(
      column: $table.telefone2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preCadastro => $composableBuilder(
      column: $table.preCadastro, builder: (column) => ColumnFilters(column));
}

class $$PreCadastrosTableOrderingComposer
    extends Composer<_$AppDatabase, $PreCadastrosTable> {
  $$PreCadastrosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numeroCliente => $composableBuilder(
      column: $table.numeroCliente,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nome => $composableBuilder(
      column: $table.nome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get enderecoCompleto => $composableBuilder(
      column: $table.enderecoCompleto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefone1 => $composableBuilder(
      column: $table.telefone1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefone2 => $composableBuilder(
      column: $table.telefone2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preCadastro => $composableBuilder(
      column: $table.preCadastro, builder: (column) => ColumnOrderings(column));
}

class $$PreCadastrosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreCadastrosTable> {
  $$PreCadastrosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get numeroCliente => $composableBuilder(
      column: $table.numeroCliente, builder: (column) => column);

  GeneratedColumn<String> get cpfCnpj =>
      $composableBuilder(column: $table.cpfCnpj, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get enderecoCompleto => $composableBuilder(
      column: $table.enderecoCompleto, builder: (column) => column);

  GeneratedColumn<String> get telefone1 =>
      $composableBuilder(column: $table.telefone1, builder: (column) => column);

  GeneratedColumn<String> get telefone2 =>
      $composableBuilder(column: $table.telefone2, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get preCadastro => $composableBuilder(
      column: $table.preCadastro, builder: (column) => column);
}

class $$PreCadastrosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PreCadastrosTable,
    PreCadastro,
    $$PreCadastrosTableFilterComposer,
    $$PreCadastrosTableOrderingComposer,
    $$PreCadastrosTableAnnotationComposer,
    $$PreCadastrosTableCreateCompanionBuilder,
    $$PreCadastrosTableUpdateCompanionBuilder,
    (
      PreCadastro,
      BaseReferences<_$AppDatabase, $PreCadastrosTable, PreCadastro>
    ),
    PreCadastro,
    PrefetchHooks Function()> {
  $$PreCadastrosTableTableManager(_$AppDatabase db, $PreCadastrosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreCadastrosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreCadastrosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreCadastrosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> numeroCliente = const Value.absent(),
            Value<String?> cpfCnpj = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String?> enderecoCompleto = const Value.absent(),
            Value<String?> telefone1 = const Value.absent(),
            Value<String?> telefone2 = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> preCadastro = const Value.absent(),
          }) =>
              PreCadastrosCompanion(
            id: id,
            numeroCliente: numeroCliente,
            cpfCnpj: cpfCnpj,
            nome: nome,
            enderecoCompleto: enderecoCompleto,
            telefone1: telefone1,
            telefone2: telefone2,
            email: email,
            preCadastro: preCadastro,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String numeroCliente,
            Value<String?> cpfCnpj = const Value.absent(),
            required String nome,
            Value<String?> enderecoCompleto = const Value.absent(),
            Value<String?> telefone1 = const Value.absent(),
            Value<String?> telefone2 = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> preCadastro = const Value.absent(),
          }) =>
              PreCadastrosCompanion.insert(
            id: id,
            numeroCliente: numeroCliente,
            cpfCnpj: cpfCnpj,
            nome: nome,
            enderecoCompleto: enderecoCompleto,
            telefone1: telefone1,
            telefone2: telefone2,
            email: email,
            preCadastro: preCadastro,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PreCadastrosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PreCadastrosTable,
    PreCadastro,
    $$PreCadastrosTableFilterComposer,
    $$PreCadastrosTableOrderingComposer,
    $$PreCadastrosTableAnnotationComposer,
    $$PreCadastrosTableCreateCompanionBuilder,
    $$PreCadastrosTableUpdateCompanionBuilder,
    (
      PreCadastro,
      BaseReferences<_$AppDatabase, $PreCadastrosTable, PreCadastro>
    ),
    PreCadastro,
    PrefetchHooks Function()>;
typedef $$EnderecosAlternativosTableCreateCompanionBuilder
    = EnderecosAlternativosCompanion Function({
  Value<int> id,
  required String cpfCnpj,
  required String numeroCliente,
  required String enderecoFormatado,
});
typedef $$EnderecosAlternativosTableUpdateCompanionBuilder
    = EnderecosAlternativosCompanion Function({
  Value<int> id,
  Value<String> cpfCnpj,
  Value<String> numeroCliente,
  Value<String> enderecoFormatado,
});

class $$EnderecosAlternativosTableFilterComposer
    extends Composer<_$AppDatabase, $EnderecosAlternativosTable> {
  $$EnderecosAlternativosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeroCliente => $composableBuilder(
      column: $table.numeroCliente, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get enderecoFormatado => $composableBuilder(
      column: $table.enderecoFormatado,
      builder: (column) => ColumnFilters(column));
}

class $$EnderecosAlternativosTableOrderingComposer
    extends Composer<_$AppDatabase, $EnderecosAlternativosTable> {
  $$EnderecosAlternativosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cpfCnpj => $composableBuilder(
      column: $table.cpfCnpj, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get numeroCliente => $composableBuilder(
      column: $table.numeroCliente,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get enderecoFormatado => $composableBuilder(
      column: $table.enderecoFormatado,
      builder: (column) => ColumnOrderings(column));
}

class $$EnderecosAlternativosTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnderecosAlternativosTable> {
  $$EnderecosAlternativosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cpfCnpj =>
      $composableBuilder(column: $table.cpfCnpj, builder: (column) => column);

  GeneratedColumn<String> get numeroCliente => $composableBuilder(
      column: $table.numeroCliente, builder: (column) => column);

  GeneratedColumn<String> get enderecoFormatado => $composableBuilder(
      column: $table.enderecoFormatado, builder: (column) => column);
}

class $$EnderecosAlternativosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EnderecosAlternativosTable,
    EnderecoAlternativo,
    $$EnderecosAlternativosTableFilterComposer,
    $$EnderecosAlternativosTableOrderingComposer,
    $$EnderecosAlternativosTableAnnotationComposer,
    $$EnderecosAlternativosTableCreateCompanionBuilder,
    $$EnderecosAlternativosTableUpdateCompanionBuilder,
    (
      EnderecoAlternativo,
      BaseReferences<_$AppDatabase, $EnderecosAlternativosTable,
          EnderecoAlternativo>
    ),
    EnderecoAlternativo,
    PrefetchHooks Function()> {
  $$EnderecosAlternativosTableTableManager(
      _$AppDatabase db, $EnderecosAlternativosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnderecosAlternativosTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$EnderecosAlternativosTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnderecosAlternativosTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> cpfCnpj = const Value.absent(),
            Value<String> numeroCliente = const Value.absent(),
            Value<String> enderecoFormatado = const Value.absent(),
          }) =>
              EnderecosAlternativosCompanion(
            id: id,
            cpfCnpj: cpfCnpj,
            numeroCliente: numeroCliente,
            enderecoFormatado: enderecoFormatado,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String cpfCnpj,
            required String numeroCliente,
            required String enderecoFormatado,
          }) =>
              EnderecosAlternativosCompanion.insert(
            id: id,
            cpfCnpj: cpfCnpj,
            numeroCliente: numeroCliente,
            enderecoFormatado: enderecoFormatado,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EnderecosAlternativosTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $EnderecosAlternativosTable,
        EnderecoAlternativo,
        $$EnderecosAlternativosTableFilterComposer,
        $$EnderecosAlternativosTableOrderingComposer,
        $$EnderecosAlternativosTableAnnotationComposer,
        $$EnderecosAlternativosTableCreateCompanionBuilder,
        $$EnderecosAlternativosTableUpdateCompanionBuilder,
        (
          EnderecoAlternativo,
          BaseReferences<_$AppDatabase, $EnderecosAlternativosTable,
              EnderecoAlternativo>
        ),
        EnderecoAlternativo,
        PrefetchHooks Function()>;
typedef $$ProdutoCategoriasTableCreateCompanionBuilder
    = ProdutoCategoriasCompanion Function({
  required String material,
  Value<String?> phl4,
  Value<String?> phl5,
  Value<String?> phl6,
  Value<String?> brandTopNode,
  Value<int> rowid,
});
typedef $$ProdutoCategoriasTableUpdateCompanionBuilder
    = ProdutoCategoriasCompanion Function({
  Value<String> material,
  Value<String?> phl4,
  Value<String?> phl5,
  Value<String?> phl6,
  Value<String?> brandTopNode,
  Value<int> rowid,
});

class $$ProdutoCategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $ProdutoCategoriasTable> {
  $$ProdutoCategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get material => $composableBuilder(
      column: $table.material, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phl4 => $composableBuilder(
      column: $table.phl4, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phl5 => $composableBuilder(
      column: $table.phl5, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phl6 => $composableBuilder(
      column: $table.phl6, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brandTopNode => $composableBuilder(
      column: $table.brandTopNode, builder: (column) => ColumnFilters(column));
}

class $$ProdutoCategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $ProdutoCategoriasTable> {
  $$ProdutoCategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get material => $composableBuilder(
      column: $table.material, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phl4 => $composableBuilder(
      column: $table.phl4, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phl5 => $composableBuilder(
      column: $table.phl5, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phl6 => $composableBuilder(
      column: $table.phl6, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brandTopNode => $composableBuilder(
      column: $table.brandTopNode,
      builder: (column) => ColumnOrderings(column));
}

class $$ProdutoCategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProdutoCategoriasTable> {
  $$ProdutoCategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumn<String> get phl4 =>
      $composableBuilder(column: $table.phl4, builder: (column) => column);

  GeneratedColumn<String> get phl5 =>
      $composableBuilder(column: $table.phl5, builder: (column) => column);

  GeneratedColumn<String> get phl6 =>
      $composableBuilder(column: $table.phl6, builder: (column) => column);

  GeneratedColumn<String> get brandTopNode => $composableBuilder(
      column: $table.brandTopNode, builder: (column) => column);
}

class $$ProdutoCategoriasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProdutoCategoriasTable,
    ProdutoCategoria,
    $$ProdutoCategoriasTableFilterComposer,
    $$ProdutoCategoriasTableOrderingComposer,
    $$ProdutoCategoriasTableAnnotationComposer,
    $$ProdutoCategoriasTableCreateCompanionBuilder,
    $$ProdutoCategoriasTableUpdateCompanionBuilder,
    (
      ProdutoCategoria,
      BaseReferences<_$AppDatabase, $ProdutoCategoriasTable, ProdutoCategoria>
    ),
    ProdutoCategoria,
    PrefetchHooks Function()> {
  $$ProdutoCategoriasTableTableManager(
      _$AppDatabase db, $ProdutoCategoriasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProdutoCategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProdutoCategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProdutoCategoriasTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> material = const Value.absent(),
            Value<String?> phl4 = const Value.absent(),
            Value<String?> phl5 = const Value.absent(),
            Value<String?> phl6 = const Value.absent(),
            Value<String?> brandTopNode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProdutoCategoriasCompanion(
            material: material,
            phl4: phl4,
            phl5: phl5,
            phl6: phl6,
            brandTopNode: brandTopNode,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String material,
            Value<String?> phl4 = const Value.absent(),
            Value<String?> phl5 = const Value.absent(),
            Value<String?> phl6 = const Value.absent(),
            Value<String?> brandTopNode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProdutoCategoriasCompanion.insert(
            material: material,
            phl4: phl4,
            phl5: phl5,
            phl6: phl6,
            brandTopNode: brandTopNode,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProdutoCategoriasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProdutoCategoriasTable,
    ProdutoCategoria,
    $$ProdutoCategoriasTableFilterComposer,
    $$ProdutoCategoriasTableOrderingComposer,
    $$ProdutoCategoriasTableAnnotationComposer,
    $$ProdutoCategoriasTableCreateCompanionBuilder,
    $$ProdutoCategoriasTableUpdateCompanionBuilder,
    (
      ProdutoCategoria,
      BaseReferences<_$AppDatabase, $ProdutoCategoriasTable, ProdutoCategoria>
    ),
    ProdutoCategoria,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$ProdutosTableTableManager get produtos =>
      $$ProdutosTableTableManager(_db, _db.produtos);
  $$PedidosPendentesTableTableManager get pedidosPendentes =>
      $$PedidosPendentesTableTableManager(_db, _db.pedidosPendentes);
  $$PedidosEnviadosTableTableManager get pedidosEnviados =>
      $$PedidosEnviadosTableTableManager(_db, _db.pedidosEnviados);
  $$PreCadastrosTableTableManager get preCadastros =>
      $$PreCadastrosTableTableManager(_db, _db.preCadastros);
  $$EnderecosAlternativosTableTableManager get enderecosAlternativos =>
      $$EnderecosAlternativosTableTableManager(_db, _db.enderecosAlternativos);
  $$ProdutoCategoriasTableTableManager get produtoCategorias =>
      $$ProdutoCategoriasTableTableManager(_db, _db.produtoCategorias);
}
