import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_data_notifier.dart';
import '../../providers/auth_notifier.dart';
import '../../services/csv_service.dart';

class BrandingPage extends StatelessWidget {
  final Function(int)? onNavigate;
  
  const BrandingPage({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          
          return Stack(
            children: [
              // Dashboard para tablet/desktop
              if (!isMobile)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header com título e saudação
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildWelcomeHeaderTablet(context),
                            Text(
                              "Order to Smile",
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [const Shadow(blurRadius: 10, color: Colors.black54)]
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        
                        // Cards de navegação rápida para tablet
                        const Text(
                          "Acesso Rápido",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.2,
                            children: [
                              _buildQuickActionCardTablet(
                                context,
                                title: "Novo Pedido",
                                subtitle: "Criar um novo pedido",
                                icon: Icons.add_shopping_cart,
                                color: Colors.green,
                                onTap: () => _navigateToPage(context, 1),
                              ),
                              _buildQuickActionCardTablet(
                                context,
                                title: "Formulário",
                                subtitle: "Contato de cliente",
                                icon: Icons.person_add_alt_1,
                                color: Colors.blue,
                                onTap: () => _navigateToPage(context, 2),
                              ),
                              _buildQuickActionCardTablet(
                                context,
                                title: "Visualizações",
                                subtitle: "Dados e relatórios",
                                icon: Icons.bar_chart,
                                color: Colors.orange,
                                onTap: () => _navigateToPage(context, 3),
                                showBadge: true,
                              ),
                              _buildQuickActionCardTablet(
                                context,
                                title: "Configurações",
                                subtitle: "Ajustes do sistema",
                                icon: Icons.settings,
                                color: Colors.purple,
                                onTap: () => _navigateToPage(context, 4),
                              ),
                              _buildQuickActionCardTablet(
                                context,
                                title: "Carregar CSV",
                                subtitle: "Bases do CSV local",
                                icon: Icons.folder_open,
                                color: Colors.indigo,
                                onTap: () => _loadAllFromCsv(context),
                              ),
                            ],
                          ),
                        ),
                        
                        // Rodapé com informações
                        _buildBottomInfoTablet(context),
                      ],
                    ),
                  ),
                ),
              
              // Dashboard mobile
              if (isMobile)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header com saudação
                        _buildWelcomeHeader(context),
                        const SizedBox(height: 24),
                        
                        // Cards de navegação rápida
                        const Text(
                          "Acesso Rápido",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.1,
                            children: [
                              _buildQuickActionCard(
                                context,
                                title: "Novo Pedido",
                                icon: Icons.add_shopping_cart,
                                color: Colors.green,
                                onTap: () => _navigateToPage(context, 1),
                              ),
                              _buildQuickActionCard(
                                context,
                                title: "Contato",
                                icon: Icons.person_add_alt_1,
                                color: Colors.blue,
                                onTap: () => _navigateToPage(context, 2),
                              ),
                              _buildQuickActionCard(
                                context,
                                title: "Dados",
                                icon: Icons.bar_chart,
                                color: Colors.orange,
                                onTap: () => _navigateToPage(context, 3),
                                showBadge: true,
                              ),
                              _buildQuickActionCard(
                                context,
                                title: "Configurações",
                                icon: Icons.settings,
                                color: Colors.purple,
                                onTap: () => _navigateToPage(context, 4),
                              ),
                              _buildQuickActionCard(
                                context,
                                title: "Carregar CSV",
                                icon: Icons.folder_open,
                                color: Colors.indigo,
                                onTap: () => _loadAllFromCsv(context),
                              ),
                            ],
                          ),
                        ),
                        
                        // Informações úteis na parte inferior
                        _buildBottomInfo(context),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final auth = Provider.of<AuthNotifier>(context);
    final userName = auth.username ?? 'Utilizador';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Olá, $userName!",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Bem-vindo ao Order to Smile",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Powered by Straumann Group",
            style: GoogleFonts.leagueSpartan(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    final appData = Provider.of<AppDataNotifier>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (showBadge && appData.pendingOrderCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${appData.pendingOrderCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Utilize os cards acima para navegar rapidamente pelo app",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, int pageIndex) {
    if (onNavigate != null) {
      onNavigate!(pageIndex);
    }
  }

  Widget _buildWelcomeHeaderTablet(BuildContext context) {
    final auth = Provider.of<AuthNotifier>(context);
    final userName = auth.username ?? 'Utilizador';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Olá, $userName!",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bem-vindo ao Order to Smile",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Powered by Straumann Group",
            style: GoogleFonts.leagueSpartan(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCardTablet(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    final appData = Provider.of<AppDataNotifier>(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (showBadge && appData.pendingOrderCount > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${appData.pendingOrderCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfoTablet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Use os cards de acesso rápido para navegar pelas principais funcionalidades do sistema. Para mais opções, utilize o menu lateral.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para carregar todas as bases do CSV
  Future<void> _loadAllFromCsv(BuildContext context) async {
    final appData = Provider.of<AppDataNotifier>(context, listen: false);
    
    // Verifica se CSVs estão disponíveis
    final csvDisponivel = await CsvService.csvDisponivel();
    if (!csvDisponivel) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arquivos CSV não encontrados'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Mostra loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Configurando bases para CSV e carregando dados...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    }

    try {
      // Salva preferências para usar CSV em todas as bases
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('clientes_usar_csv', true);
      await prefs.setBool('produtos_usar_csv', true);
      await prefs.setBool('enderecos_usar_csv', true);

      // Carrega dados do CSV em paralelo
      await Future.wait([
        _loadClientesFromCsv(appData),
        _loadProdutosFromCsv(appData),
        _loadEnderecosFromCsv(appData),
      ]);

      // Mostra sucesso
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Todas as bases carregadas do CSV com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Mostra erro
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao carregar bases: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Carrega clientes do CSV
  Future<void> _loadClientesFromCsv(AppDataNotifier appData) async {
    final clientesCsv = await CsvService.carregarClientesDoCsv();
    if (clientesCsv.isNotEmpty) {
      await appData.database.apagarTodosClientes();
      await appData.database.batch((batch) {
        batch.insertAll(appData.database.clientes, clientesCsv);
      });
      
      // Atualiza timestamp
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastClientSync', now.millisecondsSinceEpoch);
    }
  }

  // Carrega produtos do CSV
  Future<void> _loadProdutosFromCsv(AppDataNotifier appData) async {
    final produtosCsv = await CsvService.carregarProdutosDoCsv();
    if (produtosCsv.isNotEmpty) {
      await appData.database.apagarTodosProdutos();
      await appData.database.batch((batch) {
        batch.insertAll(appData.database.produtos, produtosCsv);
      });
      
      // Atualiza timestamp
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastProductSync', now.millisecondsSinceEpoch);
    }
  }

  // Carrega endereços do CSV
  Future<void> _loadEnderecosFromCsv(AppDataNotifier appData) async {
    final enderecosCsv = await CsvService.carregarEnderecosDoCsv();
    if (enderecosCsv.isNotEmpty) {
      await appData.database.apagarTodosEnderecos();
      await appData.database.batch((batch) {
        batch.insertAll(appData.database.enderecosAlternativos, enderecosCsv);
      });
      
      // Atualiza timestamp
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastEnderecoSync', now.millisecondsSinceEpoch);
    }
  }
}
