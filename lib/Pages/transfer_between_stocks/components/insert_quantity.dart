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
    required bool isPendingAdjust,
  }) async {
    if (!_isValid()) {
      return;
    }

    ShowAlertDialog.show(
      context: context,
      title: "${isPendingAdjust ? "Solicitar" : "Confirmar"} a transferência?",
      function: () async {
        if (widget.consultedProductController.text.contains("\,")) {
          widget.consultedProductController.text = widget
              .consultedProductController.text
              .replaceAll(RegExp(r'\,'), '.');
        }

        await transferBetweenStocksProvider.confirmAdjustStock(
          context: context,
          indexOfProduct: widget.index,
          consultedProductControllerText:
              widget.consultedProductController.text,
          enterpriseCode: widget.internalEnterpriseCode,
          quantity: widget.consultedProductController.text.toDouble(),
          isPendingAdjust: isPendingAdjust,
        );

        if (transferBetweenStocksProvider.errorMessageAdjustStock == "") {
          widget.consultedProductController.clear();
        }

        if (configurationsProvider.autoScan?.value == true &&
            transferBetweenStocksProvider.errorMessageAdjustStock == "") {
          await widget.getProductsWithCamera();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);
    ConfigurationsProvider configurationsProvider = Provider.of(context);
    EnterpriseProvider enterpriseProvider = Provider.of(context);

    return Form(
      key: widget.insertQuantityFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                flex: 10,
                child: TextFormField(
                  focusNode:
                      transferBetweenStocksProvider.consultedProductFocusNode,
                  controller: widget.consultedProductController,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  onFieldSubmitted: (_) async {
                    await _confirmAdjustStock(
                      transferBetweenStocksProvider:
                          transferBetweenStocksProvider,
                      configurationsProvider: configurationsProvider,
                      isPendingAdjust: false,
                    );
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
                          offset: widget.consultedProductController.text.length,
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
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 35),
                        maximumSize: const Size(double.infinity, 35),
                      ),
                      onPressed: () async {
                        await _confirmAdjustStock(
                          transferBetweenStocksProvider:
                              transferBetweenStocksProvider,
                          configurationsProvider: configurationsProvider,
                          isPendingAdjust: false,
                        );
                      },
                      child: const FittedBox(
                        child: Text("CONFIRMAR"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (enterpriseProvider.bsDate?.isAfter(DateTime(2025, 6, 23)) == true)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: () async {
                      await _confirmAdjustStock(
                        transferBetweenStocksProvider:
                            transferBetweenStocksProvider,
                        configurationsProvider: configurationsProvider,
                        isPendingAdjust: true,
                      );
                    },
                    child: const Text("Solicitar"),
                  ),
                ),
                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  message: "Será criada uma solicitação no CeltaBS",
                  child: Icon(
                    Icons.warning,
                    size: 15,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
