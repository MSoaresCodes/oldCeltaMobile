import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';

class InsertQuantity extends StatefulWidget {
  final TextEditingController consultedProductController;
  final GlobalKey<FormState> dropDownFormKey;
  final GlobalKey<FormState> insertQuantityFormKey;
  final int internalEnterpriseCode;
  final int index;
  final Function getProductsWithCamera;

  const InsertQuantity({
    required this.internalEnterpriseCode,
    required this.getProductsWithCamera,
    required this.dropDownFormKey,
    required this.insertQuantityFormKey,
    required this.consultedProductController,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  State<InsertQuantity> createState() => _InsertQuantityState();
}

class _InsertQuantityState extends State<InsertQuantity> {
  bool _isValid() {
    widget.dropDownFormKey.currentState!.validate();
    widget.insertQuantityFormKey.currentState!.validate();

    return widget.dropDownFormKey.currentState!.validate() &&
        widget.insertQuantityFormKey.currentState!.validate();
  }

  Future<void> _confirmAdjustStock({
    required TransferBetweenStocksProvider transferBetweenStocksProvider,
    required ConfigurationsProvider configurationsProvider,
  }) async {
    if (widget.consultedProductController.text.contains("\,")) {
      widget.consultedProductController.text =
          widget.consultedProductController.text.replaceAll(RegExp(r'\,'), '.');
    }

    await transferBetweenStocksProvider.confirmAdjustStock(
      context: context,
      indexOfProduct: widget.index,
      consultedProductControllerText: widget.consultedProductController.text,
      enterpriseCode: widget.internalEnterpriseCode,
      quantity: widget.consultedProductController.text.toDouble(),
    );

    if (transferBetweenStocksProvider.errorMessageAdjustStock == "") {
      widget.consultedProductController.clear();
    }

    if (configurationsProvider.autoScan?.value == true &&
        transferBetweenStocksProvider.errorMessageAdjustStock == "") {
      await widget.getProductsWithCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);
    ConfigurationsProvider configurationsProvider = Provider.of(context);
    return Column(
      children: [
        Form(
          key: widget.insertQuantityFormKey,
          child: Row(
            children: [
              Flexible(
                flex: 10,
                child: TextFormField(
                  // autofocus: true,
                  focusNode:
                      transferBetweenStocksProvider.consultedProductFocusNode,
                  enabled: transferBetweenStocksProvider.isLoadingProducts ||
                          transferBetweenStocksProvider
                              .isLoadingTypeStockAndJustifications ||
                          transferBetweenStocksProvider.isLoadingAdjustStock
                      ? false
                      : true,
                  controller: widget.consultedProductController,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  onFieldSubmitted: (_) async {
                    if (_isValid()) {
                      ShowAlertDialog.show(
                        context: context,
                        title: "Confirmar transferência",
                        function: () async {
                          await _confirmAdjustStock(
                            transferBetweenStocksProvider:
                                transferBetweenStocksProvider,
                            configurationsProvider: configurationsProvider,
                          );
                        },
                      );
                    }
                  },
                  onChanged: (value) {
                    if (value.isEmpty || value == '-') {
                      value = '0';
                    }
                    if (value.startsWith(",") || value.startsWith(".")) {
                      widget.consultedProductController.text =
                          "0" + widget.consultedProductController.text;
                      widget.consultedProductController.selection =
                          TextSelection.fromPosition(
                        TextPosition(
                          offset:
                              widget.consultedProductController.text.length,
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
              Flexible(
                flex: 9,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 35),
                    maximumSize: const Size(double.infinity, 35),
                  ),
                  onPressed:
                      transferBetweenStocksProvider.isLoadingAdjustStock
                          ? null
                          : () async {
                              if (_isValid()) {
                                ShowAlertDialog.show(
                                  context: context,
                                  title: "Confirmar transferência",
                                  function: () async {
                                    await _confirmAdjustStock(
                                      transferBetweenStocksProvider:
                                          transferBetweenStocksProvider,
                                      configurationsProvider:
                                          configurationsProvider,
                                    );
                                  },
                                );
                              }
                            },
                  child: const FittedBox(
                    child: Text(
                      "CONFIRMAR",
                      style: const TextStyle(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
