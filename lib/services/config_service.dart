import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modelo para representar os dados da tabela de configuração
class RemoteConfig {
  final String minAllowedVersion;
  final List<String> blockedVersions;
  final String? notificationTitle;
  final String? notificationMessage;
  final String? forceUpdateMessage;

  RemoteConfig({
    required this.minAllowedVersion,
    this.blockedVersions = const [],
    this.notificationTitle,
    this.notificationMessage,
    this.forceUpdateMessage,
  });

  factory RemoteConfig.fromJson(Map<String, dynamic> json) {
    return RemoteConfig(
      minAllowedVersion: json['min_allowed_version'] ?? '0.0.0',
      blockedVersions: (json['blocked_versions'] as String?)?.split(',') ?? [],
      notificationTitle: json['notification_title'],
      notificationMessage: json['notification_message'],
      forceUpdateMessage: json['force_update_message'],
    );
  }
}

class ConfigService {
  static const String _configUrl = 'https://default1900aa23cb5a4a458ad0968d229e95.5f.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/695fc5ae53844e5d88894c5ace45b9e2/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ismWhvgPgIWB13wDUhIYekdrHL_8qIsXrnrNXzXFe1Y';
  static const String _lastCheckKey = 'last_config_check_timestamp';
  static const int _checkIntervalSeconds = 1800; // 30 minutos

  // Método principal para ser chamado pela UI
  static Future<void> checkRemoteConfig(BuildContext context) async {
    final service = ConfigService._();
    
    print('ConfigService: Iniciando verificação de configuração remota...');
    
    if (await service._shouldCheck()) {
      try {
        print('ConfigService: Intervalo de verificação atingido, fazendo requisição à API...');
        final config = await service._fetchConfig();
        
        if (config != null && context.mounted) {
          print('ConfigService: Configuração recebida, processando...');
          await service._processConfig(context, config);
        } else {
          print('ConfigService: Nenhuma configuração ativa encontrada na resposta da API.');
        }
        
        await service._updateLastCheckTime();
      } catch (e) {
        // Ignora erros silenciosamente para não atrapalhar o usuário
        print('ConfigService: Erro ao buscar configuração remota: $e');
        await service._updateLastCheckTime(); // Atualiza mesmo com erro para evitar spam
      }
    } else {
      print('ConfigService: Verificação não necessária ainda (${_checkIntervalSeconds}s não passaram).');
    }
  }

  // Construtor privado para singleton
  ConfigService._();

  // Busca a configuração da API
  Future<RemoteConfig?> _fetchConfig() async {
    try {
      // JSON Schema para a API de configuração
      final requestBody = {
        "action": "get_active_config",
        "app_name": "Order Simulator",
        "timestamp": DateTime.now().toIso8601String()
      };

      print('ConfigService: Enviando requisição para API...');
      print('ConfigService: URL: $_configUrl');
      print('ConfigService: Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(_configUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 20));

      print('ConfigService: Response Status: ${response.statusCode}');
      print('ConfigService: Response Headers: ${response.headers}');
      print('ConfigService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('ConfigService: Dados decodificados: $data');
        
        // Estrutura do Power Automate: {ResultSets: {Table1: [dados]}}
        if (data is Map<String, dynamic>) {
          // Verifica se tem a estrutura ResultSets.Table1
          if (data.containsKey('ResultSets') && 
              data['ResultSets'] is Map<String, dynamic> &&
              data['ResultSets']['Table1'] is List &&
              (data['ResultSets']['Table1'] as List).isNotEmpty) {
            
            final configData = data['ResultSets']['Table1'][0];
            print('ConfigService: Extraindo dados de ResultSets.Table1: $configData');
            return RemoteConfig.fromJson(configData);
          }
          // Se a resposta for um objeto direto (formato antigo)
          else {
            print('ConfigService: Resposta é um objeto direto');
            return RemoteConfig.fromJson(data);
          }
        }
        // Se a resposta for uma lista simples (formato antigo)
        else if (data is List && data.isNotEmpty) {
          print('ConfigService: Resposta é uma lista com ${data.length} itens');
          return RemoteConfig.fromJson(data.first);
        } else {
          print('ConfigService: Formato de resposta não reconhecido: ${data.runtimeType}');
        }
      } else {
        print('ConfigService: Erro HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('ConfigService: Erro ao buscar configuração remota: $e');
      print('ConfigService: StackTrace: $stackTrace');
    }
    return null;
  }

  // Processa a configuração, comparando com a versão do app
  Future<void> _processConfig(BuildContext context, RemoteConfig config) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    
    print('ConfigService: Versão atual do app: $currentVersion');
    print('ConfigService: Versão mínima permitida: ${config.minAllowedVersion}');
    print('ConfigService: Versões bloqueadas: ${config.blockedVersions}');

    // Lógica de bloqueio
    final isBlocked = _isVersionBlocked(currentVersion, config.minAllowedVersion, config.blockedVersions);

    if (isBlocked) {
      print('ConfigService: Versão bloqueada! Mostrando diálogo de atualização forçada.');
      _showBlockDialog(context, config.forceUpdateMessage ?? 'Esta versão do aplicativo não é mais suportada. Entre em contato com o suporte para atualizar.');
      return; // Se está bloqueado, não mostra outra notificação
    }

    // Lógica de notificação
    if (config.notificationTitle != null && 
        config.notificationMessage != null && 
        config.notificationTitle!.isNotEmpty && 
        config.notificationMessage!.isNotEmpty) {
      print('ConfigService: Mostrando notificação: ${config.notificationTitle}');
      _showNotificationDialog(context, config.notificationTitle!, config.notificationMessage!);
    } else {
      print('ConfigService: Nenhuma notificação para mostrar.');
    }
  }

  // Verifica se a versão atual deve ser bloqueada
  bool _isVersionBlocked(String current, String min, List<String> blocked) {
    // Verifica se está na lista de versões especificamente bloqueadas
    if (blocked.contains(current)) {
      print('ConfigService: Versão $current está na lista de bloqueios específicos.');
      return true;
    }
    
    // Compara versões (ex: '1.0.10' vs '1.0.9')
    try {
      final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final minParts = min.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      
      // Garante que ambas as listas tenham o mesmo tamanho
      while (currentParts.length < minParts.length) currentParts.add(0);
      while (minParts.length < currentParts.length) minParts.add(0);
      
      for (int i = 0; i < minParts.length; i++) {
        if (currentParts[i] < minParts[i]) {
          print('ConfigService: Versão $current é menor que a mínima permitida $min.');
          return true;
        }
        if (currentParts[i] > minParts[i]) {
          print('ConfigService: Versão $current é maior que a mínima permitida $min.');
          return false;
        }
      }
      
      print('ConfigService: Versão $current é igual à mínima permitida $min.');
      return false;
    } catch (e) {
      print('ConfigService: Erro ao comparar versões: $e');
      return false; // Em caso de erro, não bloqueia
    }
  }

  // Verifica se já passaram os segundos definidos desde a última checagem
  Future<bool> _shouldCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffSeconds = (now - lastCheck) ~/ 1000;
    
    print('ConfigService: Última verificação: ${DateTime.fromMillisecondsSinceEpoch(lastCheck)}');
    print('ConfigService: Agora: ${DateTime.fromMillisecondsSinceEpoch(now)}');
    print('ConfigService: Diferença: ${diffSeconds}s (necessário: ${_checkIntervalSeconds}s)');
    
    final shouldCheck = diffSeconds >= _checkIntervalSeconds;
    print('ConfigService: Deve verificar? $shouldCheck');
    
    return shouldCheck;
  }

  // Atualiza o timestamp da última verificação
  Future<void> _updateLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_lastCheckKey, now);
    print('ConfigService: Timestamp de última verificação atualizado para: ${DateTime.fromMillisecondsSinceEpoch(now)}');
  }

  // Método para forçar uma nova verificação (remove o timestamp)
  static Future<void> forceNextCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastCheckKey);
    print('ConfigService: Timestamp resetado - próxima verificação será forçada');
  }

  // Mostra pop-up de bloqueio (não pode ser fechado)
  void _showBlockDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false, // Impede o usuário de fechar com o botão voltar
        child: AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 8),
              Text('Atualização Necessária'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              const Text(
                'O aplicativo será encerrado. Entre em contato com o suporte para obter a versão atualizada.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Fechar App', style: TextStyle(color: Colors.white)),
              onPressed: () {
                // Força o fechamento do app
                SystemNavigator.pop(); // Fecha o app completamente
              },
            ),
          ],
        ),
      ),
    );
  }

  // Mostra pop-up de notificação (pode ser fechado)
  void _showNotificationDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
