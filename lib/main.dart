import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
import 'providers/theme_notifier.dart';
import 'providers/app_data_notifier.dart';
import 'providers/auth_notifier.dart';
import 'providers/pedido_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/login/tela_login.dart';
import 'screens/home/main_layout.dart';
import 'screens/pedido/tela_de_pedido.dart';
import 'screens/pre_cadastro/tela_pre_cadastro_cliente.dart';
import 'screens/visualizacoes/tela_visualizacoes.dart';
import 'screens/ajuda/tela_ajuda.dart';
import 'screens/visualizacoes/tela_pedidos_pendentes.dart';
import 'screens/visualizacoes/tela_base_clientes.dart';
import 'screens/visualizacoes/tela_base_produtos.dart';
import 'screens/visualizacoes/tela_historico.dart';
import 'screens/pedido/tela_lista_produtos.dart';
import 'screens/visualizacoes/tela_base_pre_cadastro.dart';
import 'screens/visualizacoes/tela_base_enderecos_alternativos.dart';
import 'screens/visualizacoes/tela_dashboard.dart';
import 'screens/visualizacoes/tela_base_categorias.dart'; 


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AppDataNotifier(database)),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => PedidoProvider(database)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MyApp(database: database),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AppDatabase database;
  const MyApp({super.key, required this.database});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Map<String, WidgetBuilder> _routes;

  @override
  void initState() {
    super.initState();
    // Cria as rotas apenas uma vez para evitar recriações
    _routes = {
      '/home': (context) => MainLayout(database: widget.database),
      '/pedido': (context) => TelaDePedido(database: widget.database),
      '/pre_cadastro_cliente': (context) => TelaPreCadastroCliente(database: widget.database),
      '/visualizacoes': (context) => TelaVisualizacoes(database: widget.database),
      '/ajuda': (context) => const TelaAjuda(),
      '/pedidos_pendentes': (context) => TelaPedidosPendentes(database: widget.database),
      '/base_clientes': (context) => TelaBaseClientes(database: widget.database),
      '/base_produtos': (context) => TelaBaseProdutos(database: widget.database),
      '/historico': (context) => TelaHistorico(database: widget.database),
      '/lista_produtos': (context) => TelaListaProdutos(database: widget.database),
      '/base_pre_cadastro': (context) => TelaBasePreCadastro(database: widget.database),
      '/base_enderecos_alternativos': (context) => TelaBaseEnderecosAlternativos(database: widget.database),
      '/dashboard': (context) => TelaDashboard(database: widget.database),
      '/base_categorias': (context) => TelaBaseCategorias(database: widget.database),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        // Aguarda a inicialização do tema
        if (!themeNotifier.isInitialized) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }

        final baseTheme = themeNotifier.currentTheme.brightness == Brightness.dark 
          ? ThemeData.dark()
          : ThemeData.light();

        return MaterialApp(
          title: 'Order to Smile',
          debugShowCheckedModeBanner: false,
          theme: baseTheme.copyWith(
            textTheme: _buildSafeTextTheme(baseTheme),
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeNotifier.currentTheme.primaryColor,
              brightness: themeNotifier.currentTheme.brightness,
            ),
          ),
          home: TelaLogin(database: widget.database),
          routes: _routes, // Usa as rotas pré-criadas
        );
      },
    );
  }

  TextTheme _buildSafeTextTheme(ThemeData baseTheme) {
    // Cria um TextTheme base com tamanhos fixos e seguros
    final baseTextTheme = GoogleFonts.leagueSpartanTextTheme(baseTheme.textTheme)
        .apply(
          bodyColor: baseTheme.colorScheme.onSurface,
          displayColor: baseTheme.colorScheme.onSurface,
        );
    
    // Retorna com tamanhos fixos para evitar problemas de null
    return baseTextTheme.copyWith(
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 15.0),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14.0),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontSize: 17.0),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: 23.0),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontSize: 25.0),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontSize: 29.0),
    );
  }
}

