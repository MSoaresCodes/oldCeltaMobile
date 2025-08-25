import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';

class SaleRequestPdfGenerator {
  SaleRequestPdfGenerator._();

  static Future<Uint8List> generate(SaleRequestCartModel saleRequest) async {
    final pdf = pw.Document();
    final saleRequestProvider = Provider.of<SaleRequestProvider>(
      NavigatorKey.key.currentState!.context,
      listen: false,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        header: (context) => _buildHeader(saleRequest),
        footer: (context) => _buildFooter(),
        build: (context) => [
          _buildCustomerInfo(saleRequest),
          pw.SizedBox(height: 10),
          if (saleRequest.cartProducts?.isNotEmpty ?? false)
            _buildProductTable(saleRequest.cartProducts!, saleRequestProvider),
          if (saleRequest.cartProducts?.isEmpty ?? true)
            pw.Center(
              child: pw.Text('Nenhum produto no carrinho.'),
            ),
        ],
      ),
    );

    return await pdf.save();
  }

  /// Builds the header widget that is repeated on each page.
  static pw.Widget _buildHeader(SaleRequestCartModel saleRequest) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          // pw.Text(
          //   'Código da Empresa: ${saleRequest.enterpriseCode}',
          //   style: pw.TextStyle(
          //     fontWeight: pw.FontWeight.bold,
          //   ),
          // ),
          pw.Text(
            'Pedido Nº: ${saleRequest.lastSaleRequestSaved ?? "N/A"}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the footer widget that is repeated on each page.
  static pw.Widget _buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20.0),
      child: pw.Text(
        'Desenvolvido por Celtaware',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
      ),
    );
  }

  /// Builds the customer and order details section.
  static pw.Widget _buildCustomerInfo(SaleRequestCartModel saleRequest) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Cliente: ${saleRequest.selectedCustomer?.Name ?? "Não informado"}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
        ),
        pw.SizedBox(height: 12),
        if (saleRequest.instructions?.isNotEmpty ?? false) ...[
          _buildInfoSection('Instruções:', saleRequest.instructions!),
          pw.SizedBox(height: 8),
        ],
        if (saleRequest.observations?.isNotEmpty ?? false)
          _buildInfoSection('Observações:', saleRequest.observations!),
      ],
    );
  }

  /// Helper to create a styled section for instructions or observations.
  static pw.Widget _buildInfoSection(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(content, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  static double _getTotalItem(
    GetProductJsonModel product,
    SaleRequestProvider saleRequestProvider,
  ) {
    return (product.value! * product.quantity) -
        (saleRequestProvider.getProductDiscount(product) ?? 0);
  }

  static pw.Widget _buildProductTable(
    List<GetProductJsonModel> products,
    SaleRequestProvider saleRequestProvider,
  ) {
    final headers = ['Produto', 'Qtd', 'Preço unit', 'Desconto', 'Total'];

    double totalDiscount = 0;
    double totalLiquid = 0;
    final data = products.map((product) {
      final productDiscount =
          saleRequestProvider.getProductDiscount(product) ?? 0;
      final productTotalLiquid = _getTotalItem(product, saleRequestProvider);
      totalDiscount += productDiscount;
      totalLiquid += productTotalLiquid;

      return [
        product.name ?? 'N/A',
        product.quantity.toStringAsFixed(product.quantity % 1 == 0 ? 0 : 2),
        _formatCurrency(product.value),
        _formatCurrency(saleRequestProvider.getProductDiscount(product) ?? 0),
        _formatCurrency(_getTotalItem(product, saleRequestProvider)),
      ];
    }).toList()
      ..add([
        "",
        "",
        "",
        _formatCurrency(totalDiscount),
        _formatCurrency(totalLiquid),
      ]);

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }

  /// Formats a nullable double value into a currency string.
  static String _formatCurrency(double? value) {
    if (value == null) return 'R\$ 0,00';
    final format =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    return format.format(value);
  }
}
