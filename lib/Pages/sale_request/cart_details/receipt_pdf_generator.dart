import 'dart:convert';

import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

// Assuming your data models are available here
import '../../../Models/models.dart';
import '../../../providers/providers.dart';

class ReceiptPdfGenerator {
  ReceiptPdfGenerator._();

  static Future<void> printReceiptDirectly(
    SaleRequestCartModel saleRequest,
    SaleRequestProvider saleRequestProvider,
  ) async {
    // ⬇️ HERE is where you put the printer's IP address and port.
    final printer = PrinterNetworkManager('192.168.100.70', port: 9100);

    // Connect to the printer. The `timeout` is in milliseconds.
    final PosPrintResult res =
        await printer.connect(timeout: const Duration(seconds: 5));

    if (res != PosPrintResult.success) {
      print('Error connecting to printer: $res');
      // Handle connection error (e.g., show a message to the user)
      return;
    }

    // --- Start Building Your Receipt Commands ---
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text('PEDIDO DE VENDA',
        styles: const PosStyles(
            align: PosAlign.center, bold: true, height: PosTextSize.size2));
    bytes += generator.text(
        'Pedido: ${saleRequest.lastSaleRequestSaved ?? "N/A"}',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(
        "Impresso em " + DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // Products section
    if (saleRequest.cartProducts != null) {
      for (final product in saleRequest.cartProducts!) {
        final productSubtotal = (product.quantity) * (product.value ?? 0);
        final discount = saleRequestProvider.getProductDiscount(product);

        // Product Name and Total
        bytes += generator.row([
          PosColumn(
            textEncoded: latin1.encode(product.name ?? 'N/A'),
            width: 8,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            textEncoded: latin1.encode(_formatCurrency(productSubtotal)),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);

        // Quantity and Price details
        bytes += generator.row([
          PosColumn(
            textEncoded: latin1.encode(
                '  ${product.quantity.toStringAsFixed(0)} un x ${_formatCurrency(product.value)}'),
            width: 12,
          ),
        ]);

        // Discount if it exists
        if ((discount ?? 0) > 0) {
          bytes += generator.row([
            PosColumn(
              textEncoded: latin1.encode('  Desconto'),
              width: 6,
            ),
            PosColumn(
                textEncoded: latin1.encode('- ${_formatCurrency(discount)}'),
                width: 6,
                styles: const PosStyles(align: PosAlign.right)),
          ]);
        }
      }
    }

    bytes += generator.hr();

    // Totals Section
    final double totalBruto = saleRequest.cartProducts
            ?.map((p) => (p.quantity) * (p.value ?? 0))
            .fold(0, (prev, curr) => prev ?? 0 + curr) ??
        0;
    final double totalDiscount = saleRequest.cartProducts
            ?.map((p) => saleRequestProvider.getProductDiscount(p))
            .fold(0, (prev, curr) => prev ?? 0 + (curr ?? 0)) ??
        0;
    final double totalLiquid = totalBruto - totalDiscount;

    bytes += generator.row([
      PosColumn(
        textEncoded: latin1.encode('Subtotal'),
        width: 6,
      ),
      PosColumn(
          textEncoded: latin1.encode(_formatCurrency(totalBruto)),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
        textEncoded: latin1.encode('Descontos'),
        width: 6,
      ),
      PosColumn(
          textEncoded: latin1.encode(_formatCurrency(totalDiscount)),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          textEncoded: latin1.encode('TOTAL'),
          width: 6,
          styles: const PosStyles(bold: true, height: PosTextSize.size2)),
      PosColumn(
        textEncoded: latin1.encode(_formatCurrency(totalLiquid)),
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
    ]);

    // Feed paper, cut, and disconnect
    bytes += generator.feed(2);
    bytes += generator.cut();

    // Send the commands to the printer
    printer.printTicket(bytes);
    printer.disconnect();
  }

// You still need your _formatCurrency helper function
  static String _formatCurrency(double? value) {
    if (value == null) return 'R\$ 0,00';
    final format =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
    return format.format(value);
  }
}
