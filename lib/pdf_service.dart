import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart'; // Import necessário para impressão
import '../models/item_pedido.dart';

class PdfService {
  // Novo método para gerar e imprimir o PDF diretamente
  static Future<void> generateAndPrintPdf(Map<String, dynamic> pedidoData) async {
    final bytes = await generateOrderPdfBytes(pedidoData);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  // Gera o PDF como bytes, para ser enviado para a API ou impresso
  static Future<Uint8List> generateOrderPdfBytes(Map<String, dynamic> pedidoData) async {
    final pdf = pw.Document();
    final logo = pw.MemoryImage((await rootBundle.load('assets/images/logo.png')).buffer.asUint8List());

    final List<dynamic> itensJson = (pedidoData['itens'] is String)
        ? jsonDecode(pedidoData['itens'])
        : pedidoData['itens'];

    final List<ItemPedido> itens = itensJson.map((item) => ItemPedido.fromJson(item)).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.SizedBox(height: 60, width: 180, child: pw.Image(logo)),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('CÓPIA DO PEDIDO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                      pw.Text('ID do App: ${pedidoData['app_pedido_id'] ?? 'N/A'}'),
                      pw.Text('Data: ${DateTime.now().toLocal().toString().substring(0, 16)}'),
                    ],
                  ),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 20),
                child: pw.Divider(thickness: 2),
              ),
              // Dados do Cliente e Pedido
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Cliente:', pedidoData['cliente'] ?? 'N/A'),
                        _buildDetailRow('Cód. Cliente:', pedidoData['cod_cliente'] ?? 'N/A'),
                        _buildDetailRow('Telefone:', pedidoData['telefone'] ?? 'N/A'),
                        _buildDetailRow('E-mail:', pedidoData['email'] ?? 'N/A'),
                        _buildDetailRow('Endereço de Entrega:', pedidoData['endereco_entrega'] ?? 'N/A'),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Assessor:', pedidoData['cod_assessor'] ?? 'N/A'),
                        _buildDetailRow('PromoCode:', pedidoData['promocode'] ?? 'N/A'),
                        _buildDetailRow('Pagamento:', '${pedidoData['condicao_pagamento'] ?? ''} (${pedidoData['parcelas'] ?? ''})'),
                        _buildDetailRow('Método de Entrega:', pedidoData['entrega'] ?? 'N/A'),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              // Tabela de Itens
              pw.Text('Itens do Pedido', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: 10),
              _buildItemsTable(itens),
              pw.Spacer(),
              // Totais (Observações Removidas)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Total: R\$ ${pedidoData['total']?.toStringAsFixed(2) ?? '0.00'}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 20),
                child: pw.Divider(),
              ),
              pw.Center(child: pw.Text('Order to Smile - Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}')),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  static pw.Widget _buildDetailRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static pw.Table _buildItemsTable(List<ItemPedido> itens) {
    final headers = ['Cód.', 'Descrição', 'Qtd', 'Desc. %', 'Total'];
    final data = itens.map((item) {
      return [
        item.cod,
        item.descricao,
        item.qtd.toString(),
        item.desconto.toStringAsFixed(2),
        'R\$ ${item.valorFinal.toStringAsFixed(2)}',
      ];
    }).toList();
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
       columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2),
      },
    );
  }
}

