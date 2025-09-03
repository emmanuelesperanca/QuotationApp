import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/theme_notifier.dart';
import '../../widgets/navigation_card.dart';

// Classe auxiliar para organizar os dados de cada cartão
class VisualizacaoCardData {
  final String title;
  final IconData icon;
  final String routeName;
  final int badgeCount;

  VisualizacaoCardData({
    required this.title,
    required this.icon,
    required this.routeName,
    this.badgeCount = 0,
  });
}

class TelaVisualizacoes extends StatelessWidget {
  final AppDatabase database;
  const TelaVisualizacoes({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appData = Provider.of<AppDataNotifier>(context);

    // Lista dinâmica com as informações para cada cartão de navegação
    final List<VisualizacaoCardData> cards = [
       VisualizacaoCardData(
        title: 'Dashboard',
        icon: Icons.dashboard,
        routeName: '/dashboard',
      ),
      VisualizacaoCardData(
        title: 'Pedidos Pendentes',
        icon: Icons.pending_actions,
        routeName: '/pedidos_pendentes',
        badgeCount: appData.pendingOrderCount,
      ),
      VisualizacaoCardData(
        title: 'Base de Pré-Cadastro',
        icon: Icons.person_search,
        routeName: '/base_pre_cadastro',
      ),
      VisualizacaoCardData(
        title: 'Base de Produtos',
        icon: Icons.inventory_2,
        routeName: '/base_produtos',
      ),
      VisualizacaoCardData(
        title: 'Base de Clientes',
        icon: Icons.people,
        routeName: '/base_clientes',
      ),
      VisualizacaoCardData(
        title: 'Base de Endereços Alternativos',
        icon: Icons.location_on,
        routeName: '/base_enderecos_alternativos',
      ),
      VisualizacaoCardData(
        title: 'Histórico',
        icon: Icons.history,
        routeName: '/historico',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Visualizações'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300.0,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.2,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final cardData = cards[index];
            return NavigationCard(
              title: cardData.title,
              icon: cardData.icon,
              theme: themeNotifier.currentTheme,
              onTap: () => Navigator.pushNamed(context, cardData.routeName),
              badgeCount: cardData.badgeCount,
            );
          },
        ),
      ),
    );
  }
}
