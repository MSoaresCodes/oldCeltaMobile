import 'dart:convert';

import 'package:celta_inventario/utils/utils.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

// Assuming your data models are available here
import '../../../Models/models.dart';
import '../../../providers/providers.dart';

class ReceiptPdfGenerator {
  ReceiptPdfGenerator._();

  static double _getItemLiquidValue(
    GetProductJsonModel product,
    SaleRequestProvider saleRequestProvider,
  ) {
    return (product.value! * product.quantity) -
        (saleRequestProvider.getProductDiscount(product) ?? 0);
  }

  static double _getItemGrossValue(GetProductJsonModel product) {
    return (product.value! * product.quantity);
  }

  static Future<void> printReceiptDirectly(
    SaleRequestCartModel saleRequest,
    SaleRequestProvider saleRequestProvider,
    String ip,
  ) async {
    // ⬇️ HERE is where you put the printer's IP address and port.
    final printer = PrinterNetworkManager(ip, port: 9100);

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
    bytes += generator.text(
        'Cliente: ${saleRequest.selectedCustomer?.Name ?? "N/A"}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Usuario: ${UserData.userName}',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.hr();

    // Products section
    double totalDiscount = 0;
    double totalLiquid = 0;
    double totalGross = 0;

    if (saleRequest.cartProducts != null) {
      for (final product in saleRequest.cartProducts!) {
        final productDiscount =
            saleRequestProvider.getProductDiscount(product) ?? 0;
        final itemLiquidValue =
            _getItemLiquidValue(product, saleRequestProvider);
        final itemGrossValue = _getItemGrossValue(product);

        totalDiscount += productDiscount;
        totalLiquid += itemLiquidValue;
        totalGross += itemGrossValue;

        // Product Name and Total
        bytes += generator.row([
          PosColumn(
            textEncoded: latin1.encode("(${product.plu}) ${product.name}"),
            width: 12,
            styles: const PosStyles(bold: true),
          ),
        ]);

        // Quantity and Price details

        bytes += generator.row([
          PosColumn(
            text: "",
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: product.quantity.toString().toBrazilianNumber(),
            width: 3,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: "x",
            width: 1,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: product.value.toString().toBrazilianNumber(),
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: "=",
            width: 1,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: itemGrossValue.toString().toBrazilianNumber(),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    }

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
        textEncoded: latin1.encode('Subtotal R\$'),
        width: 6,
      ),
      PosColumn(
          text: totalGross.toStringAsFixed(2),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
        textEncoded: latin1.encode('Total descontos R\$'),
        width: 6,
      ),
      PosColumn(
          text: totalDiscount.toStringAsFixed(2),
          width: 6,
          styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.row([
      PosColumn(
          textEncoded: latin1.encode('TOTAL R\$ '),
          width: 6,
          styles: const PosStyles(bold: true, height: PosTextSize.size2)),
      PosColumn(
        text: totalLiquid.toStringAsFixed(2),
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
    await printer.printTicket(bytes);
    await printer.disconnect();
    //TODO put inside a try catch and show success or error message
  }
}
