import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../components/components.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';

class AddProductInLot extends StatefulWidget {
  final TextEditingController quantityController;
  final GlobalKey<FormState> insertQuantityFormKey;
  final int internalEnterpriseCode;
  final Function getProductsWithCamera;
  final GetProductJsonModel product;
  final VoidCallback expandHeader;
  final FocusNode searchFocusNode;
  final VoidCallback onSuccess;

  const AddProductInLot({
    required this.internalEnterpriseCode,
    required this.getProductsWithCamera,
    required this.insertQuantityFormKey,
    required this.quantityController,
    required this.product,
    required this.expandHeader,
    required this.searchFocusNode,
    required this.onSuccess,
    Key? key,
  }) : super(key: key);

  @override
  State<AddProductInLot> createState() => _AddProductInLotState();
}

class _AddProductInLotState extends State<AddProductInLot> {
  Future<void> _addProductInLot({
    required TransferBetweenStocksProvider transferBetweenStocksProvider,
    required ConfigurationsProvider configurationsProvider,
  }) async {
    transferBetweenStocksProvider.validateDropdowns();
    if (transferBetweenStocksProvider.errorSelectedJustification != null ||
        transferBetweenStocksProvider.errorSelectedOrigin != null ||
        transferBetweenStocksProvider.errorSelectedDestiny != null) {
      widget.expandHeader();
      return;
    }

    final added = await transferBetweenStocksProvider.addProductInLot(
      product: widget.product,
      quantity: widget.quantityController.text.toDouble(),
      enterpriseCode: widget.internalEnterpriseCode,
    );

    if (!added) return;

    widget.quantityController.clear();
    widget.onSuccess();

    if (configurationsProvider.autoScan?.value == true) {
      await widget.getProductsWithCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);
    ConfigurationsProvider configurationsProvider = Provider.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Form(
        key: widget.insertQuantityFormKey,
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: TextFormField(
                focusNode: widget.searchFocusNode,
                controller: widget.quantityController,
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                onFieldSubmitted: (_) async {
                  await _addProductInLot(
                    transferBetweenStocksProvider:
                        transferBetweenStocksProvider,
                    configurationsProvider: configurationsProvider,
                  );
                },
                onChanged: (value) {
                  if (value.isEmpty || value == '-') {
                    value = '0';
                  }
                  if (value.startsWith(",") || value.startsWith(".")) {
                    widget.quantityController.text =
                        "0" + widget.quantityController.text;
                    widget.quantityController.selection =
                        TextSelection.fromPosition(
                      TextPosition(
                        offset: widget.quantityController.text.length,
                      ),
                    );
                  }
                },
                validator: FormFieldValidations.number,
                decoration: FormFieldDecoration.decoration(
                  context: context,
                  labelText: "Quantidade",
                ),
                style: FormFieldStyle.style(),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: () async {
                await _addProductInLot(
                  transferBetweenStocksProvider: transferBetweenStocksProvider,
                  configurationsProvider: configurationsProvider,
                );
              },
              child: Row(
                children: [
                  const Text("Lote"),
                  Icon(Platform.isIOS ? Icons.add : Icons.add)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
