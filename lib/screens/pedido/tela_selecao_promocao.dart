import 'package:flutter/material.dart';
import '../../models/promocao.dart';

class TelaSelecaoPromocao extends StatelessWidget {
  const TelaSelecaoPromocao({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados de exemplo - no futuro, virão do banco de dados
    final List<Promocao> _promocoes = [
      Promocao(
        promocode: '4400677310',
        titulo: 'Compre 20 implantes Zigoma S e 15 intermediários com 40% de desconto e ganhe 1 KIT Cirúrgico Zigoma S',
        itens: [
          ItemPromocao(cod: '109.1086', descricao: 'IMPLANTE ZYGOMA-S GM 3.5X30', qtd: 20, qtdDigitacao: 20, valorUnitario: 1092.00, desconto: 40.0, descontoDigitacao: 45.931),
          ItemPromocao(cod: '115.243', descricao: 'MINI PILAR CONICO GM ALT. 0.8', qtd: 20, qtdDigitacao: 20, valorUnitario: 224.00, desconto: 40.0, descontoDigitacao: 49.0),
          ItemPromocao(cod: 'BRKITNDT75', descricao: 'KIT ZIGOMA-S', qtd: 1, qtdDigitacao: 1, valorUnitario: 8493.00, desconto: 100.0, descontoDigitacao: 80.0),
        ],
      ),
      Promocao(
        promocode: '4400676910',
        titulo: 'Compre 20 implantes e Ganhe 20 implantes + 2 KIT VPS',
        itens: [
          ItemPromocao(cod: '140.943', descricao: 'IMPLANTE HELIX GM 3.5X8 ACQUA', qtd: 20, qtdDigitacao: 0, valorUnitario: 417.00, desconto: 100.0, descontoDigitacao: 100.0),
          ItemPromocao(cod: '140.943', descricao: 'IMPLANTE HELIX GM 3.5X8 ACQUA', qtd: 20, qtdDigitacao: 40, valorUnitario: 417.00, desconto: 0.0, descontoDigitacao: 53.388),
          ItemPromocao(cod: '184.182', descricao: 'Kit Neodent VPS 600mL + Light', qtd: 2, qtdDigitacao: 2, valorUnitario: 471.00, desconto: 100.0, descontoDigitacao: 40.0),
        ],
      ),
       Promocao(
        promocode: '4400606510',
        titulo: 'Compre 60 implantes com 50% de desconto e ganhe 2 Kits',
        itens: [
          ItemPromocao(
            cod: '140.943', // Código base, não será usado
            descricao: 'IMPLANTE HELIX GM ACQUA', // Descrição da família
            qtd: 60,
            qtdDigitacao: 60,
            valorUnitario: 417.00, 
            desconto: 50.0,
            descontoDigitacao: 50.0,
            isFamiliaDeProdutos: true, // Indica que é uma família
          ),
          ItemPromocao(cod: 'BRKITNDT31', descricao: 'Kit Protético GM', qtd: 1, qtdDigitacao: 1, valorUnitario: 2386.00, desconto: 100.0, descontoDigitacao: 100.0),
          ItemPromocao(cod: '110.303', descricao: 'KIT CIRURGICO COMPACTO HELIX GM COMPLETO', qtd: 1, qtdDigitacao: 1, valorUnitario: 5830.00, desconto: 100.0, descontoDigitacao: 100.0),
        ],
      ),
    ];

    return AlertDialog(
      title: const Text('Selecione uma Promoção'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: _promocoes.length,
          itemBuilder: (context, index) {
            final promocao = _promocoes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                title: Text(promocao.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Promocode: ${promocao.promocode}'),
                children: [
                  // Mostra apenas os itens que aparecem no card (qtd > 0)
                  ...promocao.itens.where((item) => item.qtd > 0).map((item) {
                    return ListTile(
                      title: Text(item.descricao),
                      subtitle: Text('Cód: ${item.cod} | Qtd: ${item.qtd} | Desc: ${item.desconto}%'),
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(promocao);
                      },
                      child: const Text('Aplicar esta Promoção'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

