import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // URL para ENVIAR um novo pedido
  static const String _postOrderUrl = 'https://prod-50.westeurope.logic.azure.com:443/workflows/e273fbdc9d274955b78906f65fabc86a/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=57sZ3srSrWagjZjlRv33ptPHxmiLQFlGv-4Mo8DnHIo';

  // URL para OBTER o status de um pedido
  static const String _getStatusUrl = 'https://prod-241.westeurope.logic.azure.com:443/workflows/fdde305be31447cd9fefcde5d10c4370/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=qZORIZG7DhtnnxBdwkb3VusxXbW_jg6hBTC0Fbx6pOM';

  // Envia um pedido para a API do Power Automate
  static Future<bool> enviarPedido(Map<String, dynamic> pedidoData) async {
    try {
      // Cria uma cópia profunda do mapa para evitar modificar o original
      final Map<String, dynamic> pedidoFormatado = jsonDecode(jsonEncode(pedidoData));

      // Extrai a lista de itens
      final List<dynamic> itens = pedidoFormatado['itens'];

      // Formata a string de itens conforme o requisito
      final StringBuffer itensBuffer = StringBuffer();
      final StringBuffer descontosBuffer = StringBuffer();

      for (var item in itens) {
        itensBuffer.writeln('${item['cod']}\t${item['qtd']}');
        descontosBuffer.writeln('${item['cod']} = ${item['desconto']}%');
      }

      final String itensFormatados = '${itensBuffer.toString().trim()}\n\nDesconto aplicado\n${descontosBuffer.toString().trim()}';
      
      // Substitui a lista de itens pela string formatada
      pedidoFormatado['itens'] = itensFormatados;

      final response = await http.post(
        Uri.parse(_postOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pedidoFormatado),
      );

      // O Power Automate geralmente retorna 202 (Accepted) para fluxos iniciados com sucesso
      if (response.statusCode == 200 || response.statusCode == 202) {
        debugPrint('Pedido enviado com sucesso para a API.');
        return true;
      } else {
        debugPrint('Falha ao enviar pedido. Status: ${response.statusCode}, Corpo: ${response.body}');
        return false;
      }
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
}

