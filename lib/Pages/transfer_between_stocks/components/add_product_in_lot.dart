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
  final GlobalKey<FormState> dropDownFormKey;
  final GlobalKey<FormState> insertQuantityFormKey;
  final int internalEnterpriseCode;
  final Function getProductsWithCamera;
  final GetProductJsonModel product;
  final VoidCallback expandHeader;

  const AddProductInLot({
    required this.internalEnterpriseCode,
    required this.getProductsWithCamera,
    required this.dropDownFormKey,
    required this.insertQuantityFormKey,
    required this.quantityController,
    required this.product,
    required this.expandHeader,
    Key? key,
  }) : super(key: key);

  @override
  State<AddProductInLot> createState() => _AddProductInLotState();
}

class _AddProductInLotState extends State<AddProductInLot> {
  bool _isValid() {
    widget.dropDownFormKey.currentState!.validate();
    widget.insertQuantityFormKey.currentState!.validate();

    return widget.dropDownFormKey.currentState!.validate() &&
        widget.insertQuantityFormKey.currentState!.validate();
  }

  Future<void> _addProductInLot({
    required TransferBetweenStocksProvider transferBetweenStocksProvider,
    required ConfigurationsProvider
        configurationsProvider, //TODO must use the autoscan
  }) async {
    if (!_isValid()) {
      widget.expandHeader();
      return;
    }

    await transferBetweenStocksProvider.addProductInLot(
      //TODO add justification, stockOrigin and destinyStock
      TransferBetweenStockLotProductsModel(
        productPackingCode: widget.product.productPackingCode!,
        productCode: widget.product.productCode!,
        quantity: widget.quantityController.text.toDouble(),
      ),
    );

    widget.quantityController.clear();

    if (configurationsProvider.autoScan?.value == true) {
      await widget.getProductsWithCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);
    ConfigurationsProvider configurationsProvider = Provider.of(context);

    return Form(
      key: widget.insertQuantityFormKey,
      child: Row(
        children: [
          Expanded(
            flex: 10,
            child: TextFormField(
              focusNode:
                  transferBetweenStocksProvider.consultedProductFocusNode,
              controller: widget.quantityController,
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
              onFieldSubmitted: (_) async {
                await _addProductInLot(
                  transferBetweenStocksProvider: transferBetweenStocksProvider,
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
    );
  }
}
