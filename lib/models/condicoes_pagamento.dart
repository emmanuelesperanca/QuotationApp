class CondicaoPagamento {
  final String codigo;
  final String descricao;
  final String categoria;
  final bool permiteParcelamento;
  final int? parcelasMaximas;
  final bool temEntrada;
  final String? observacoes;

  const CondicaoPagamento({
    required this.codigo,
    required this.descricao,
    required this.categoria,
    this.permiteParcelamento = false,
    this.parcelasMaximas,
    this.temEntrada = false,
    this.observacoes,
  });
}

class CondicoesPagamento {
  static const List<CondicaoPagamento> todasCondicoes = [
    // À VISTA
    CondicaoPagamento(
      codigo: 'BRPX',
      descricao: 'PIX à Vista / Antecipado',
      categoria: 'À Vista',
    ),
    CondicaoPagamento(
      codigo: 'BR04',
      descricao: 'Dinheiro',
      categoria: 'À Vista',
    ),
    CondicaoPagamento(
      codigo: 'BR05',
      descricao: 'Depósito',
      categoria: 'À Vista',
    ),
    CondicaoPagamento(
      codigo: 'BRC9',
      descricao: '30 dias via depósito',
      categoria: 'À Vista',
      observacoes: '30 dias',
    ),
    CondicaoPagamento(
      codigo: 'BR76',
      descricao: 'Crédito',
      categoria: 'À Vista',
    ),

    // CARTÃO (CARTÕES E LINKS DE PAGAMENTO)
    CondicaoPagamento(
      codigo: 'BR77',
      descricao: 'Cartão de Crédito Manual',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 21,
    ),
    CondicaoPagamento(
      codigo: 'BR78',
      descricao: 'Cartão de Débito',
      categoria: 'Cartão',
    ),
    CondicaoPagamento(
      codigo: 'BRCC',
      descricao: 'Credit Card',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 12,
    ),
    CondicaoPagamento(
      codigo: 'ETCC',
      descricao: 'Clear Correct Credit card payment via DELEGO',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 12,
    ),
    CondicaoPagamento(
      codigo: 'BRL1',
      descricao: 'Link de Pagamento manual 1x',
      categoria: 'Cartão',
    ),
    CondicaoPagamento(
      codigo: 'BRL2',
      descricao: 'Link de Pagamento manual 2x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 2,
    ),
    CondicaoPagamento(
      codigo: 'BRL3',
      descricao: 'Link de Pagamento manual 3x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 3,
    ),
    CondicaoPagamento(
      codigo: 'BRL4',
      descricao: 'Link de Pagamento manual 4x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 4,
    ),
    CondicaoPagamento(
      codigo: 'BRL5',
      descricao: 'Link de Pagamento manual 5x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 5,
    ),
    CondicaoPagamento(
      codigo: 'BRL6',
      descricao: 'Link de Pagamento manual 6x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 6,
    ),
    CondicaoPagamento(
      codigo: 'BRL7',
      descricao: 'Link de Pagamento manual 7x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 7,
    ),
    CondicaoPagamento(
      codigo: 'BRL8',
      descricao: 'Link de Pagamento manual 8x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 8,
    ),
    CondicaoPagamento(
      codigo: 'BRL9',
      descricao: 'Link de Pagamento manual 9x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 9,
    ),
    CondicaoPagamento(
      codigo: 'BRLA',
      descricao: 'Link de Pagamento manual 10x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 10,
    ),
    CondicaoPagamento(
      codigo: 'BRLB',
      descricao: 'Link de Pagamento manual 11x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 11,
    ),
    CondicaoPagamento(
      codigo: 'BRLC',
      descricao: 'Link de Pagamento manual 12x',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 12,
    ),
    CondicaoPagamento(
      codigo: 'BRPS',
      descricao: 'Link de Pagamento - Cartão de Crédito',
      categoria: 'Cartão',
      permiteParcelamento: true,
      parcelasMaximas: 12,
    ),

    // DIRETO EM DIAS
    CondicaoPagamento(
      codigo: 'BR56',
      descricao: '7 Dias Direto',
      categoria: 'Prazo Direto',
    ),
    CondicaoPagamento(
      codigo: 'BR42',
      descricao: '21 Dias Direto',
      categoria: 'Prazo Direto',
    ),
    CondicaoPagamento(
      codigo: 'BR02',
      descricao: '30 Dias Direto',
      categoria: 'Prazo Direto',
    ),
    CondicaoPagamento(
      codigo: 'BR03',
      descricao: '60 Dias Direto',
      categoria: 'Prazo Direto',
    ),
    CondicaoPagamento(
      codigo: 'BR33',
      descricao: '90 Dias Direto',
      categoria: 'Prazo Direto',
    ),
    CondicaoPagamento(
      codigo: 'BR34',
      descricao: '120 Dias Direto',
      categoria: 'Prazo Direto',
    ),
    CondicaoPagamento(
      codigo: 'BR35',
      descricao: '150 Dias Direto',
      categoria: 'Prazo Direto',
    ),
    CondicaoPagamento(
      codigo: 'BRCN',
      descricao: '365 Dias - PagAcordosComerciais',
      categoria: 'Prazo Direto',
    ),

    // BOLETO (COM ENTRADA, SEM ENTRADA E OUTROS)
    CondicaoPagamento(
      codigo: 'BR06',
      descricao: 'Entrada + 1 (7+30)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 2,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR08',
      descricao: 'Entrada + 2 (7+30+30)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 3,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR09',
      descricao: 'Entrada + 3 (7+30+30+30)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 4,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR10',
      descricao: 'Entrada + 4 (7+30+30+30+30)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 5,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR11',
      descricao: 'Entrada + 5 (7+30+30+30+30+30)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 6,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR12',
      descricao: 'Entrada + 6 (7+30+30+30+30...)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 7,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR13',
      descricao: 'Entrada + 7 (7+30+30+30+30...)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 8,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR14',
      descricao: 'Entrada + 8 (7+30+30+30...)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 9,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR15',
      descricao: 'Entrada + 9 (7+30+30+30+30...)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 10,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR07',
      descricao: 'Entrada + 10 (7+30+30+30+30...)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 11,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR16',
      descricao: 'Entrada + 11 (7+30+30+30+30...)',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 12,
      temEntrada: true,
    ),
    CondicaoPagamento(
      codigo: 'BR19',
      descricao: 'S/ Entrada 2x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 2,
    ),
    CondicaoPagamento(
      codigo: 'BR20',
      descricao: 'S/ Entrada 3x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 3,
    ),
    CondicaoPagamento(
      codigo: 'BR21',
      descricao: 'S/ Entrada 4x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 4,
    ),
    CondicaoPagamento(
      codigo: 'BR22',
      descricao: 'S/ Entrada 5x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 5,
    ),
    CondicaoPagamento(
      codigo: 'BR25',
      descricao: 'S/ Entrada 6x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 6,
    ),
    CondicaoPagamento(
      codigo: 'BR26',
      descricao: 'S/ Entrada 7x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 7,
    ),
    CondicaoPagamento(
      codigo: 'BR27',
      descricao: 'S/ Entrada 8x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 8,
    ),
    CondicaoPagamento(
      codigo: 'BR28',
      descricao: 'S/ Entrada 9x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 9,
    ),
    CondicaoPagamento(
      codigo: 'BR18',
      descricao: 'S/ Entrada 10x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 10,
    ),
    CondicaoPagamento(
      codigo: 'BR23',
      descricao: 'S/ Entrada 11x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 11,
    ),
    CondicaoPagamento(
      codigo: 'BR24',
      descricao: 'S/ Entrada 12x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 12,
    ),
    CondicaoPagamento(
      codigo: 'BR94',
      descricao: 'S/ Entrada 14x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 14,
    ),
    CondicaoPagamento(
      codigo: 'BRBY',
      descricao: 'S/ Entrada 15x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 15,
    ),
    CondicaoPagamento(
      codigo: 'BR96',
      descricao: 'S/ Entrada 18x30 Dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 18,
    ),
    CondicaoPagamento(
      codigo: 'BR57',
      descricao: 'Clube do Boleto',
      categoria: 'Boleto',
    ),
    CondicaoPagamento(
      codigo: 'BRBD',
      descricao: '12x - primeira pra 60 dias',
      categoria: 'Boleto',
      permiteParcelamento: true,
      parcelasMaximas: 12,
    ),

    // PARCELAMENTOS ESPECIAIS
    CondicaoPagamento(
      codigo: 'BRD7',
      descricao: '21 parcelas',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 21,
    ),
    CondicaoPagamento(
      codigo: 'BRE2',
      descricao: '21 parcelas (60+30+30...)',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 21,
    ),
    CondicaoPagamento(
      codigo: 'BRA0',
      descricao: '24 parcelas',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 24,
    ),
    CondicaoPagamento(
      codigo: 'BRD2',
      descricao: '24 parcelas (60+30+30...)',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 24,
    ),
    CondicaoPagamento(
      codigo: 'BRD9',
      descricao: '30 parcelas',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 30,
    ),
    CondicaoPagamento(
      codigo: 'BRD5',
      descricao: '35 parcelas (60+30+30...)',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 35,
    ),
    CondicaoPagamento(
      codigo: 'BRC4',
      descricao: '36x sem entrada',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 36,
    ),
    CondicaoPagamento(
      codigo: 'BRD3',
      descricao: '36 parcelas (60+30+30...)',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 36,
    ),
    CondicaoPagamento(
      codigo: 'BRDC',
      descricao: '48 parcelas (30+60+90...)',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 48,
    ),
    CondicaoPagamento(
      codigo: 'BRDD',
      descricao: '60 parcelas (30+60+90...)',
      categoria: 'Parcelamento Especial',
      permiteParcelamento: true,
      parcelasMaximas: 60,
    ),

    // CASHBACK
    CondicaoPagamento(
      codigo: 'BRLE',
      descricao: 'Cashback 24x - dia 20',
      categoria: 'Cashback',
      permiteParcelamento: true,
      parcelasMaximas: 24,
    ),
    CondicaoPagamento(
      codigo: 'BRLF',
      descricao: 'Cashback 36x - dia 20',
      categoria: 'Cashback',
      permiteParcelamento: true,
      parcelasMaximas: 36,
    ),
    CondicaoPagamento(
      codigo: 'BRLG',
      descricao: 'Cashback 35x - dia 20',
      categoria: 'Cashback',
      permiteParcelamento: true,
      parcelasMaximas: 35,
    ),

    // CONDIÇÕES ESPECIAIS
    CondicaoPagamento(
      codigo: 'BR29',
      descricao: 'Troca Antecipada',
      categoria: 'Especial',
    ),
    CondicaoPagamento(
      codigo: 'BR45',
      descricao: 'Troca',
      categoria: 'Especial',
    ),
    CondicaoPagamento(
      codigo: 'BRDE',
      descricao: 'Troca S/ Boleto',
      categoria: 'Especial',
    ),
    CondicaoPagamento(
      codigo: 'BR91',
      descricao: 'Free of Charge – FOC',
      categoria: 'Especial',
    ),
    CondicaoPagamento(
      codigo: 'BRCP',
      descricao: 'Clear Wallet',
      categoria: 'Especial',
    ),
    CondicaoPagamento(
      codigo: 'BRON',
      descricao: 'Pagamento Online',
      categoria: 'Especial',
    ),
    CondicaoPagamento(
      codigo: 'BRLD',
      descricao: '18 Parcelas (60+30+30...)',
      categoria: 'Especial',
      permiteParcelamento: true,
      parcelasMaximas: 18,
    ),
  ];

  static List<String> get categorias => [
        'À Vista',
        'Cartão',
        'Prazo Direto',
        'Boleto',
        'Parcelamento Especial',
        'Cashback',
        'Especial',
      ];

  static List<CondicaoPagamento> getCondicoesPorCategoria(String categoria) {
    return todasCondicoes.where((c) => c.categoria == categoria).toList();
  }

  static CondicaoPagamento? getCondicaoPorCodigo(String codigo) {
    try {
      return todasCondicoes.firstWhere((c) => c.codigo == codigo);
    } catch (e) {
      return null;
    }
  }
}
