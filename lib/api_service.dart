import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // --- URLs ---
  static const String _postOrderUrl = 'https://prod-50.westeurope.logic.azure.com:443/workflows/e273fbdc9d274955b78906f65fabc86a/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=57sZ3srSrWagjZjlRv33ptPHxmiLQFlGv-4Mo8DnHIo';
  static const String _getStatusUrl = 'https://prod-241.westeurope.logic.azure.com:443/workflows/fdde305be31447cd9fefcde5d10c4370/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=qZORIZG7DhtnnxBdwkb3VusxXbW_jg6hBTC0Fbx6pOM';
  static const String _getBaseDataUrl = 'https://default1900aa23cb5a4a458ad0968d229e95.5f.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/0350ab1197f944228fbd1f92bc14fb37/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=GWf97mW7xduKqEC4owLSI93T48B8ye6K-YO34sS66R0';
  static const String _postAnalyticsUrl = 'https://default1900aa23cb5a4a458ad0968d229e95.5f.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/3ebbaa398f4c41288bfa2918425e4fa9/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=WzfQSg_I566NsagX8hgM7VdfFFUs4zPmpGJhMnjaZJM';


  // Envia um pedido para a API do Power Automate
  static Future<bool> enviarPedido(Map<String, dynamic> pedidoData) async {
    try {
      final Map<String, dynamic> pedidoFormatado = jsonDecode(jsonEncode(pedidoData));

      dynamic itens = pedidoFormatado['itens'];
      if (itens is String) {
        itens = jsonDecode(itens);
      }

      final StringBuffer itensBuffer = StringBuffer();
      final StringBuffer descontosBuffer = StringBuffer();

      for (var item in itens) {
        itensBuffer.writeln('${item['cod']}\t${item['qtd']}');
        descontosBuffer.writeln('${item['cod']} = ${item['desconto']}%');
      }

      final String itensFormatados = '${itensBuffer.toString().trim()}\n\nDesconto aplicado\n${descontosBuffer.toString().trim()}';
      
      pedidoFormatado['itens'] = itensFormatados;

      final response = await http.post(
        Uri.parse(_postOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pedidoFormatado),
      );

      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      debugPrint('Erro de conexão ao enviar pedido: $e');
      return false;
    }
  }

  // Obtém o status de um pedido a partir da API do SharePoint
  static Future<Map<String, String>?> getStatusPedido(String appPedidoId) async {
    try {
      final Uri uri = Uri.parse('$_getStatusUrl&app_pedido_id=$appPedidoId');
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

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
      } else {
        debugPrint('Falha ao obter status. Código: ${response.statusCode}, Corpo: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao obter status: $e');
    }
    return null;
  }

  // Busca os dados de uma base (clientes, produtos ou endereços) com paginação
  static Future<List<dynamic>?> getBaseData(String baseType, {int skip = 0}) async {
    try {
      final response = await http.post(
        Uri.parse(_getBaseDataUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'app_pedido_id': baseType, 'skip': skip}),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        if (decodedBody is List) {
          return decodedBody;
        } else if (decodedBody is Map && decodedBody.containsKey('value')) {
          return decodedBody['value'];
        }
      } else {
        debugPrint('Falha ao obter base $baseType. Status: ${response.statusCode}, Corpo: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao obter base $baseType: $e');
    }
    return null;
  }

  // Envia dados de análise para o endpoint de telemetria
  static Future<void> enviarDadosAnaliticos(Map<String, dynamic> analyticsData) async {
    try {
      final response = await http.post(
        Uri.parse(_postAnalyticsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(analyticsData),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        debugPrint('Dados de análise enviados com sucesso.');
      } else {
        debugPrint('Falha ao enviar dados de análise. Status: ${response.statusCode}, Corpo: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao enviar dados de análise: $e');
    }
  }
}

