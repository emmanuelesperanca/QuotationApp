import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  // URLs dos Endpoints
  static const String _postOrderUrl = 'https://prod-50.westeurope.logic.azure.com:443/workflows/e273fbdc9d274955b78906f65fabc86a/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=57sZ3srSrWagjZjlRv33ptPHxmiLQFlGv-4Mo8DnHIo';
  static const String _getStatusUrl = 'https://prod-241.westeurope.logic.azure.com:443/workflows/fdde305be31447cd9fefcde5d10c4370/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=qZORIZG7DhtnnxBdwkb3VusxXbW_jg6hBTC0Fbx6pOM';
  static const String _getBaseDataUrl = 'https://default1900aa23cb5a4a458ad0968d229e95.5f.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/0350ab1197f944228fbd1f92bc14fb37/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=GWf97mW7xduKqEC4owLSI93T48B8ye6K-YO34sS66R0';
  static const String _postAnalyticsUrl = 'https://default1900aa23cb5a4a458ad0968d229e95.5f.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/3ebbaa398f4c41288bfa2918425e4fa9/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=WzfQSg_I566NsagX8hgM7VdfFFUs4zPmpGJhMnjaZJM';

  // --- MÉTODOS DE UTILIDADES ---

  static Future<String?> getDeviceUUID() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('deviceUUID');
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString('deviceUUID', uuid);
    }
    return uuid;
  }

  static Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  // --- MÉTODOS DE API ---

  static Future<bool> enviarPedido(Map<String, dynamic> pedidoData) async {
    try {
      final response = await http.post(
        Uri.parse(_postOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pedidoData),
      ).timeout(const Duration(seconds: 30));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Erro de conexão ao enviar pedido: $e');
      return false;
    }
  }

  static Future<void> enviarDadosAnalise(Map<String, dynamic> data) async {
    try {
      await http.post(
        Uri.parse(_postAnalyticsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 20));
    } catch (e) {
      debugPrint('Erro ao enviar dados de análise: $e');
    }
  }
  
  static Future<Map<String, String>?> getStatusPedido(String appPedidoId) async {
    try {
      final Uri uri = Uri.parse('$_getStatusUrl&app_pedido_id=$appPedidoId');
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          final pedidoInfo = responseData.first;
          return {
            'numeroPedidoSap': pedidoInfo['N_x00fa_merodoPedido']?.toString() ?? 'N/A',
            'status': pedidoInfo['StatusdoPedido']?.toString() ?? 'N/A',
            'obsCentral': pedidoInfo['Observa_x00e7__x00e3_oparaAssess']?.toString() ?? 'N/A',
          };
        }
      }
    } catch (e) {
      debugPrint('Erro de conexão ao obter status: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getBaseData(String tipoBase, {int skip = 0}) async {
    try {
      final response = await http.post(
        Uri.parse(_getBaseDataUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'app_pedido_id': tipoBase, 'skip': skip}),
      ).timeout(const Duration(seconds: 90));
      
      if (response.statusCode == 200) {
        // CORREÇÃO: Verifica se o corpo da resposta está vazio antes de tentar descodificar.
        if (response.body.isEmpty) {
          debugPrint('Corpo da resposta vazio para $tipoBase com skip: $skip. Fim da paginação assumido.');
          return []; // Retorna uma lista vazia, indicando o fim dos dados.
        }
        return jsonDecode(response.body) as List<dynamic>;
      } else {
         debugPrint('Falha ao buscar dados para $tipoBase. Status: ${response.statusCode}, Corpo: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Erro de conexão ao buscar dados para $tipoBase: $e');
      return null;
    }
  }
}

