import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../database.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/theme_notifier.dart';
import '../../services/config_service.dart';
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
  bool _configCheckScheduled = false; // Flag para evitar múltiplas verificações

  @override
  void initState() {
    super.initState();
    _pages = [
      BrandingPage(onNavigate: (index) => setState(() => _selectedIndex = index)),
      TelaDePedido(database: widget.database),
      TelaPreCadastroCliente(database: widget.database),
      TelaVisualizacoes(database: widget.database),
      TelaConfiguracoes(database: widget.database),
      const TelaAjuda(),
    ];
    
    // Agenda verificação de configuração remota apenas uma vez
    _scheduleConfigCheck();
  }

  void _scheduleConfigCheck() {
    if (!_configCheckScheduled) {
      _configCheckScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ConfigService.checkRemoteConfig(context);
        }
      });
    }
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

    return PopScope(
      canPop: false, // Previne o pop automático
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        // Se está na página inicial (dashboard), pergunta se quer sair
        if (_selectedIndex == 0) {
          final shouldExit = await _showExitDialog(context);
          if (shouldExit == true) {
            // Fecha o app
            SystemNavigator.pop();
          }
        } else {
          // Se está em outra página, volta para o dashboard
          setState(() {
            _selectedIndex = 0;
          });
          
          // Feedback visual opcional
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voltou ao menu principal'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Detecta se é tablet ou celular usando LayoutBuilder (mais seguro)
          final isTablet = constraints.maxWidth > 600;
          final isMobile = !isTablet; // Inverso de isTablet

          return Scaffold(
          body: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey<int>(_selectedIndex),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        isHomePage 
                          ? currentTheme.getMainBgAsset(isMobile)
                          : currentTheme.getInnerBgAsset(isMobile)
                      ),
                      fit: BoxFit.cover,
                      onError: (e,s) => const AssetImage('assets/images/straumann_main.jpg'), // Fallback
                    ),
                  ),
                ),
              ),
              // Layout para tablet (NavigationRail lateral)
              if (isTablet) ...[
                Row(
                  children: [
                    Container(
                      color: Colors.black.withOpacity(isHomePage ? 0.2 : 0.6),
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
                              destinations: _getNavigationDestinations(appData),
                            ),
                          ),
                          _buildUserMenu(auth, context),
                        ],
                      ),
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(
                      child: _pages[_selectedIndex],
                    ),
                  ],
                ),
              ] else ...[
                // Layout para celular (conteúdo em tela cheia)
                _pages[_selectedIndex],
              ],
            ],
          ),
          // BottomNavigationBar apenas para celular
          bottomNavigationBar: !isTablet ? _buildBottomNavigation(currentTheme, appData) : null,
          // AppBar apenas para celular
          appBar: !isTablet ? _buildMobileAppBar(currentTheme, auth) : null,
        );
      },
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Sair do App'),
            ],
          ),
          content: const Text(
            'Deseja realmente fechar o Order to Smile?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  List<NavigationRailDestination> _getNavigationDestinations(AppDataNotifier appData) {
    return [
      const NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Página Inicial')),
      const NavigationRailDestination(icon: Icon(Icons.add_shopping_cart_outlined), selectedIcon: Icon(Icons.add_shopping_cart), label: Text('Criar Pedido')),
      const NavigationRailDestination(icon: Icon(Icons.person_add_alt_1_outlined), selectedIcon: Icon(Icons.person_add_alt_1), label: Text('Formulário de Contato')),
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
    ];
  }

  Widget _buildUserMenu(AuthNotifier auth, BuildContext context) {
    return Padding(
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
            enabled: false,
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
    );
  }

  PreferredSizeWidget _buildMobileAppBar(currentTheme, AuthNotifier auth) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.8),
      foregroundColor: Colors.white,
      title: Row(
        children: [
          Image.asset('assets/images/logo_white.png', height: 32, errorBuilder: (c, e, s) => const Icon(Icons.business, size: 32)),
          const SizedBox(width: 8),
          const Text("Order to Smile", style: TextStyle(fontSize: 16)),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: "Opções de Utilizador",
          onSelected: (value) {
            if (value == 'logoff') {
              _logoff(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false,
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
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.account_circle, size: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(currentTheme, AppDataNotifier appData) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black.withOpacity(0.9),
      selectedItemColor: currentTheme.primaryColor,
      unselectedItemColor: Colors.white70,
      selectedFontSize: 12,
      unselectedFontSize: 10,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_shopping_cart_outlined),
          activeIcon: Icon(Icons.add_shopping_cart),
          label: 'Pedido',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_add_alt_1_outlined),
          activeIcon: Icon(Icons.person_add_alt_1),
          label: 'Contato',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(appData.pendingOrderCount.toString()),
            isLabelVisible: appData.pendingOrderCount > 0,
            child: const Icon(Icons.bar_chart_outlined)
          ),
          activeIcon: Badge(
            label: Text(appData.pendingOrderCount.toString()),
            isLabelVisible: appData.pendingOrderCount > 0,
            child: const Icon(Icons.bar_chart)
          ),
          label: 'Dados',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Config',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.help_outline),
          activeIcon: Icon(Icons.help),
          label: 'Ajuda',
        ),
      ],
    );
  }
}

