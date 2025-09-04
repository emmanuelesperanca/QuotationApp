import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  // URLs
  static const String _postOrderUrl = 'https://prod-50.westeurope.logic.azure.com:443/workflows/e273fbdc9d274955b78906f65fabc86a/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=57sZ3srSrWagjZjlRv33ptPHxmiLQFlGv-4Mo8DnHIo';
  static const String _getStatusUrl = 'https://prod-241.westeurope.logic.azure.com:443/workflows/fdde305be31447cd9fefcde5d10c4370/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=qZORIZG7DhtnnxBdwkb3VusxXbW_jg6hBTC0Fbx6pOM';
  static const String _getBaseDataUrl = 'https://default1900aa23cb5a4a458ad0968d229e95.5f.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/0350ab1197f944228fbd1f92bc14fb37/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=GWf97mW7xduKqEC4owLSI93T48B8ye6K-YO34sS66R0';
  static const String _analyticsUrl = 'https://default1900aa23cb5a4a458ad0968d229e95.5f.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/3ebbaa398f4c41288bfa2918425e4fa9/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=WzfQSg_I566NsagX8hgM7VdfFFUs4zPmpGJhMnjaZJM';
  
  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String?> getDeviceUUID() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('deviceUUID');
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString('deviceUUID', uuid);
    }
    return uuid;
  }

  // Envia um pedido para a API principal
  static Future<bool> enviarPedido(Map<String, dynamic> pedidoData) async {
    try {
      final response = await http.post(
        Uri.parse(_postOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pedidoData),
      ).timeout(const Duration(seconds: 30));
      return (response.statusCode == 200 || response.statusCode == 202);
    } catch (e) {
      debugPrint('Erro de conexão ao enviar pedido: $e');
      return false;
    }
  }

  // Obtém o status de um pedido
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

  // Obtém dados da base (clientes, produtos, etc.) com paginação
  static Future<List<dynamic>?> getBaseData(String dataType, int skip) async {
    try {
      final response = await http.post(
        Uri.parse(_getBaseDataUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'app_pedido_id': dataType, 'skip': skip}),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody is List ? responseBody : null;
      } else {
        debugPrint('Falha ao buscar dados para $dataType. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Erro de conexão ao buscar dados para $dataType: $e');
      return null;
    }
  }

  // Envia dados de análise para a API de telemetria
  static Future<void> enviarDadosAnalise(Map<String, dynamic> analyticsData) async {
    try {
      final response = await http.post(
        Uri.parse(_analyticsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(analyticsData),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 202) {
        debugPrint('Dados de análise enviados com sucesso.');
      } else {
        debugPrint('Falha ao enviar dados de análise. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao enviar dados de análise: $e');
    }
  }
}

