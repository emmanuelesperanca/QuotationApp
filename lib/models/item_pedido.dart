class ItemPedido {
  final String cod;
  final String descricao;
  final double valorUnitario;
  int qtd;
  double desconto;
  bool isSelected;
  final bool isPromocional; // NOVO: Identifica se o item veio de uma promoção

  ItemPedido({
    required this.cod,
    required this.descricao,
    required this.valorUnitario,
    this.qtd = 1,
    this.desconto = 0.0,
    this.isSelected = false,
    this.isPromocional = false, // NOVO: Valor padrão é falso
  });

  // Converte o objeto para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'cod': cod,
      'descricao': descricao,
      'valorUnitario': valorUnitario,
      'qtd': qtd,
      'desconto': desconto,
    };
  }

  // --- CORREÇÃO ADICIONADA ---
  // Construtor de fábrica para criar um ItemPedido a partir de um mapa JSON
  factory ItemPedido.fromJson(Map<String, dynamic> json) {
    return ItemPedido(
      cod: json['cod'] ?? 'N/A',
      descricao: json['descricao'] ?? 'Descrição não encontrada',
      valorUnitario: (json['valorUnitario'] as num?)?.toDouble() ?? 0.0,
      qtd: (json['qtd'] as int?) ?? 1,
      // Garante que o desconto é tratado como um número (double)
      desconto: (json['desconto'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double get valorFinal => qtd * valorUnitario * (1 - desconto / 100);
}
