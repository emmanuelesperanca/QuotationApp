import 'package:flutter/material.dart';

class TelaAjuda extends StatelessWidget {
  const TelaAjuda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Ajuda'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text(
            'Guia Rápido do Aplicativo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Card(
            color: Colors.black45,
            child: ExpansionTile(
              leading: Icon(Icons.add_shopping_cart),
              title: Text('Como criar um pedido?'),
              children: [
                ListTile(
                  title: Text(
                    '1. Na tela inicial, toque em "Criar Pedido".\n'
                    '2. Busque e selecione o cliente pelo nome, CPF/CNPJ ou código.\n'
                    '3. Adicione produtos usando a busca ou a lista completa.\n'
                    '4. Na tabela de itens, ajuste quantidades e descontos conforme necessário.\n'
                    '5. Preencha os campos de pagamento, entrega e observação.\n'
                    '6. Toque em "Enviar Pedido".',
                  ),
                ),
              ],
            ),
          ),
          Card(
            color: Colors.black45,
            child: ExpansionTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Como visualizar dados?'),
              children: [
                ListTile(
                  title: Text(
                    'Na tela inicial, toque em "Visualizações". Lá você poderá ver:\n'
                    '- Pedidos Pendentes: Pedidos que não foram enviados por falta de internet.\n'
                    '- Base de Produtos: A lista de produtos carregada no aplicativo.\n'
                    '- Base de Clientes: A lista de clientes carregada no aplicativo.\n'
                    '- Histórico: Todos os pedidos que já foram enviados com sucesso.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
