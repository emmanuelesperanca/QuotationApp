import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database.dart';
import 'providers/theme_notifier.dart';
import 'providers/app_data_notifier.dart';
import 'providers/auth_notifier.dart';
import 'providers/pedido_provider.dart'; // Importado
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


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AppDataNotifier(database)),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()), // Adicionado
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
    // Define um TextTheme base com tamanhos maiores
    const TextTheme baseTextTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 102.0),
      displayMedium: TextStyle(fontSize: 64.0),
      displaySmall: TextStyle(fontSize: 51.0),
      headlineMedium: TextStyle(fontSize: 36.0),
      headlineSmall: TextStyle(fontSize: 25.0),
      titleLarge: TextStyle(fontSize: 21.0),
      titleMedium: TextStyle(fontSize: 17.0),
      titleSmall: TextStyle(fontSize: 15.0),
      bodyLarge: TextStyle(fontSize: 17.0),
      bodyMedium: TextStyle(fontSize: 15.0),
      labelLarge: TextStyle(fontSize: 15.0),
    );

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Order to Smile',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            // Aplica a fonte do Google ao TextTheme base com tamanhos maiores
            textTheme: GoogleFonts.leagueSpartanTextTheme(baseTextTheme),
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeNotifier.currentTheme.primaryColor,
              brightness: Brightness.dark,
            ),
          ),
          home: TelaLogin(database: database),
          routes: {
            '/home':(context) => MainLayout(database: database),
            '/pedido': (context) => const TelaDePedido(),
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
          },
        );
      },
    );
  }
}

