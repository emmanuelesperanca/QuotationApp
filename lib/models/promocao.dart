class Promocao {
  final String promocode;
  final String titulo;
  final List<ItemPromocao> itens;

  Promocao({
    required this.promocode,
    required this.titulo,
    required this.itens,
  });
}

class ItemPromocao {
  final String cod;
  final String descricao;
  final int qtd; // Quantidade para exibição no card
  final int qtdDigitacao; // Quantidade real a ser adicionada ao pedido
  final double valorUnitario;
  final double desconto; // Desconto para exibição no card
  final double descontoDigitacao; // Desconto real a ser aplicado
  final bool isFamiliaDeProdutos; // Gatilho para o popup de variações

  ItemPromocao({
    required this.cod,
    required this.descricao,
    required this.qtd,
    required this.qtdDigitacao,
    required this.valorUnitario,
    required this.desconto,
    required this.descontoDigitacao,
    this.isFamiliaDeProdutos = false,
  });
}

