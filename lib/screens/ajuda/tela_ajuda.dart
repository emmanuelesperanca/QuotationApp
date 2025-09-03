import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaAjuda extends StatefulWidget {
  const TelaAjuda({super.key});

  @override
  State<TelaAjuda> createState() => _TelaAjudaState();
}

class _TelaAjudaState extends State<TelaAjuda> {
  String _appVersion = 'A carregar...';
  String _deviceUUID = 'A carregar...';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
        _deviceUUID = prefs.getString('deviceUUID') ?? 'Não definido';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Ajuda & Suporte'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: const [
                Text(
                  'Guia Rápido do App "Order to Smile"',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _HelpTopic(
                  icon: Icons.add_shopping_cart,
                  title: 'Como criar um pedido?',
                  content: '1. Na tela inicial, toque em "Criar Pedido".\n'
                      '2. Busque e selecione o cliente pelo nome, CPF/CNPJ ou código.\n'
                      '3. Adicione produtos usando a busca ou a lista completa.\n'
                      '4. Na tabela de itens, ajuste quantidades e descontos conforme necessário.\n'
                      '5. Preencha os campos de pagamento, entrega e observação.\n'
                      '6. Toque em "Enviar Pedido".',
                ),
                 _HelpTopic(
                  icon: Icons.sync,
                  title: 'Como funciona a sincronização online?',
                  content: 'As bases de Clientes, Produtos e Endereços são sincronizadas a partir de uma base de dados central.\n\n'
                      '- Para atualizar manualmente, vá à tela da base desejada (ex: "Base de Clientes") e toque em "Atualizar Base Online".\n'
                      '- A aplicação tentará sincronizar automaticamente a cada hora.\n'
                      '- Se a sincronização for interrompida ou falhar, a aplicação continuará a usar a última base de dados descarregada com sucesso.',
                ),
                 _HelpTopic(
                  icon: Icons.pending_actions,
                  title: 'O que são Pedidos Pendentes?',
                  content: 'São pedidos que não puderam ser enviados para o sistema no momento da criação, geralmente por falta de ligação à internet.\n\n'
                      'Eles ficam guardados em segurança no dispositivo e podem ser reenviados mais tarde, quando a ligação for restabelecida. Para isso, vá a "Visualizações" > "Pedidos Pendentes" e toque no botão de reenvio.',
                ),
                _HelpTopic(
                  icon: Icons.person_add_alt_1,
                  title: 'Como funciona o Pré-Cadastro?',
                  content: 'Se um cliente não estiver na base de dados, você pode pré-cadastrá-lo para criar um pedido.\n\n'
                      '1. Vá a "Pré-Cadastro" e preencha os dados do cliente.\n'
                      '2. Ao criar um pedido, marque a opção "Cliente em Pré-Cadastro?" para o encontrar na busca.',
                ),
                 _HelpTopic(
                  icon: Icons.bar_chart,
                  title: 'Para que serve o Dashboard?',
                  content: 'O Dashboard oferece uma visão geral e rápida da sua atividade de vendas. Lá você pode ver:\n'
                      '- O total de pedidos enviados e o valor total faturado.\n'
                      '- Quais os produtos mais vendidos.\n'
                      '- Quais os seus principais clientes.\n'
                      '- Um gráfico com a sua atividade nos últimos 7 dias.',
                ),
                _HelpTopic(
                  icon: Icons.warning_amber_rounded,
                  title: 'Resolução de Problemas Comuns',
                  content: '- O botão "Enviar Pedido" está desativado: Verifique se selecionou um cliente e se confirmou o número de telefone dele.\n\n'
                      '- A sincronização falhou: Verifique a sua ligação à internet. Se o problema persistir, pode ser uma instabilidade temporária no sistema. Tente novamente mais tarde.\n\n'
                      '- O cliente não aparece na busca: Verifique se está a procurar na base correta (clientes normais ou de pré-cadastro).',
                ),
              ],
            ),
          ),
          // Rodapé com informações de diagnóstico
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text('Versão do App: $_appVersion', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 4),
                Text('ID do Dispositivo: $_deviceUUID', style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para os tópicos de ajuda
class _HelpTopic extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _HelpTopic({required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black45,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          ListTile(
            title: Text(content),
          ),
        ],
      ),
    );
  }
}

