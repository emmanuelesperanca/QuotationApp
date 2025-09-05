import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
import 'providers/theme_notifier.dart';
import 'providers/app_data_notifier.dart';
import 'providers/auth_notifier.dart';
import 'providers/pedido_provider.dart';
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
      ],
      child: MyApp(database: database),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        final baseTheme = themeNotifier.currentTheme.brightness == Brightness.dark 
          ? ThemeData.dark()
          : ThemeData.light();

        final customTextTheme = GoogleFonts.leagueSpartanTextTheme(baseTheme.textTheme)
            .apply(
              bodyColor: baseTheme.colorScheme.onSurface,
              displayColor: baseTheme.colorScheme.onSurface
            )
            .copyWith(
              bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 15),
              bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(fontSize: 14),
              titleMedium: baseTheme.textTheme.titleMedium?.copyWith(fontSize: 17),
              titleLarge: baseTheme.textTheme.titleLarge?.copyWith(fontSize: 23),
              headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(fontSize: 25),
              headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(fontSize: 29),
            );

        return MaterialApp(
          title: 'Order to Smile',
          debugShowCheckedModeBanner: false,
          theme: baseTheme.copyWith(
            textTheme: customTextTheme,
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeNotifier.currentTheme.primaryColor,
              brightness: themeNotifier.currentTheme.brightness,
            ),
          ),
          home: TelaLogin(database: database),
          routes: {
            '/home':(context) => MainLayout(database: database),
            '/pedido': (context) => TelaDePedido(database: database),
            '/pre_cadastro_cliente': (context) => TelaPreCadastroCliente(database: database),
            '/visualizacoes': (context) => TelaVisualizacoes(database: database),
            '/ajuda': (context) => const TelaAjuda(),
            '/pedidos_pendentes': (context) => TelaPedidosPendentes(database: database),
            '/base_clientes': (context) => TelaBaseClientes(database: database),
            '/base_produtos': (context) => TelaBaseProdutos(database: database),
            '/historico': (context) => TelaHistorico(database: database),
            '/lista_produtos': (context) => TelaListaProdutos(database: database),
            '/base_pre_cadastro': (context) => TelaBasePreCadastro(database: database),
            '/base_enderecos_alternativos': (context) => TelaBaseEnderecosAlternativos(database: database),
            '/dashboard': (context) => TelaDashboard(database: database),
            '/base_categorias': (context) => TelaBaseCategorias(database: database),
          },
        );
      },
    );
  }
}

