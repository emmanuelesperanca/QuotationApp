import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/theme_notifier.dart';
import '../pedido/tela_de_pedido.dart';
import '../pre_cadastro/tela_pre_cadastro_cliente.dart';
import '../visualizacoes/tela_visualizacoes.dart';
import '../configuracoes/tela_configuracoes.dart';
import '../ajuda/tela_ajuda.dart';
import '../login/tela_login.dart';
import 'branding_page.dart';

class MainLayout extends StatefulWidget {
  final AppDatabase database;
  const MainLayout({super.key, required this.database});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const BrandingPage(),
      TelaDePedido(database: widget.database),
      TelaPreCadastroCliente(database: widget.database),
      TelaVisualizacoes(database: widget.database),
      const TelaConfiguracoes(),
      const TelaAjuda(),
    ];
  }

  void _logoff(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => TelaLogin(database: widget.database)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final appData = Provider.of<AppDataNotifier>(context);
    final auth = Provider.of<AuthNotifier>(context, listen: false);
    final currentTheme = themeNotifier.currentTheme;
    final isHomePage = _selectedIndex == 0;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey<int>(_selectedIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(isHomePage ? currentTheme.mainBgAsset : currentTheme.innerBgAsset),
                  fit: BoxFit.cover,
                  onError: (e,s) => const AssetImage('assets/images/straumann_main.jpg'), // Fallback
                ),
              ),
            ),
          ),
          Row(
            children: [
              // ATUALIZADO: NavigationRail agora está dentro de uma Column
              Container(
                color: Colors.black.withOpacity(isHomePage ? 0.2 : 0.4),
                child: Column(
                  children: [
                    Expanded(
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                        backgroundColor: Colors.transparent,
                        minWidth: 100,
                        labelType: NavigationRailLabelType.all,
                        indicatorColor: currentTheme.primaryColor,
                        leading: Column(
                          children: [
                            const SizedBox(height: 20),
                            Image.asset('assets/images/logo_white.png', width: 60, errorBuilder: (c, e, s) => const Icon(Icons.business, size: 60)),
                            const SizedBox(height: 8),
                            const Text("A Straumann Group App", style: TextStyle(fontSize: 8)),
                            const SizedBox(height: 40),
                          ],
                        ),
                        destinations: [
                          const NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Página Inicial')),
                          const NavigationRailDestination(icon: Icon(Icons.add_shopping_cart_outlined), selectedIcon: Icon(Icons.add_shopping_cart), label: Text('Criar Pedido')),
                          const NavigationRailDestination(icon: Icon(Icons.person_add_alt_1_outlined), selectedIcon: Icon(Icons.person_add_alt_1), label: Text('Pré-Cadastro')),
                          NavigationRailDestination(
                            icon: Badge(
                              label: Text(appData.pendingOrderCount.toString()),
                              isLabelVisible: appData.pendingOrderCount > 0,
                              child: const Icon(Icons.bar_chart_outlined)
                            ),
                            selectedIcon: Badge(
                              label: Text(appData.pendingOrderCount.toString()),
                              isLabelVisible: appData.pendingOrderCount > 0,
                              child: const Icon(Icons.bar_chart)
                            ),
                            label: const Text('Visualizações')
                          ),
                          const NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Configurações')),
                          const NavigationRailDestination(icon: Icon(Icons.help_outline), selectedIcon: Icon(Icons.help), label: Text('Ajuda')),
                        ],
                      ),
                    ),
                    // ATUALIZADO: Seção de Logoff
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: PopupMenuButton<String>(
                        tooltip: "Opções de Utilizador",
                        onSelected: (value) {
                          if (value == 'logoff') {
                            _logoff(context);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            enabled: false, // Não clicável
                            child: Text(auth.username ?? 'Utilizador', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem<String>(
                            value: 'logoff',
                            child: ListTile(
                              leading: Icon(Icons.logout),
                              title: Text('Logoff'),
                            ),
                          ),
                        ],
                        child: const Icon(Icons.account_circle, size: 40),
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
