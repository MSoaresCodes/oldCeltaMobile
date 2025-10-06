import 'dart:convert';

import 'package:celta_inventario/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

import '../../../Models/models.dart';
import '../../../components/components.dart';
import '../sale_request_provider.dart';

abstract class ReceiptPdfGenerator {
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
    BuildContext context,
  ) async {
    try {
      final printer = PrinterNetworkManager(ip, port: 9100);

      final PosPrintResult res =
          await printer.connect(timeout: const Duration(seconds: 5));

      if (res != PosPrintResult.success) {
        throw Exception('Ocorreu um erro para conectar com a impressora: $res');
      }

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      final lastFourNumbers = saleRequest.lastSaleRequestSaved?.substring(8);

      bytes += generator.text('PEDIDO DE VENDA $lastFourNumbers',
          styles: const PosStyles(
              align: PosAlign.center, bold: true, height: PosTextSize.size2));
      bytes += generator.text(
          "Impresso em " +
              DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text(
          'Pedido: ${saleRequest.lastSaleRequestSaved ?? "N/A"}',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(
          'Cliente: ${saleRequest.selectedCustomer?.Name ?? "N/A"}',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Usuario: ${UserData.userName}',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.hr();

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
          final eans = product.EANs ?? [];
          final eanOrPlu = eans.isNotEmpty ? eans.first : product.plu;

          totalDiscount += productDiscount;
          totalLiquid += itemLiquidValue;
          totalGross += itemGrossValue;

          bytes += generator.row([
            PosColumn(
              textEncoded: latin1.encode("(${eanOrPlu}) ${product.name}"),
              width: 12,
              styles: const PosStyles(bold: true),
            ),
          ]);

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

      bytes += generator.feed(2);
      bytes += generator.cut();

      await printer.printTicket(bytes);
      await printer.disconnect();
    } catch (e) {
      ShowSnackbarMessage.show(message: e.toString(), context: context);
    }
  }
}
