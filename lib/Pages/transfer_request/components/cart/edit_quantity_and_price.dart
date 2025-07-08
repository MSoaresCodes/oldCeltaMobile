import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/components.dart';
import '../../../../Models/models.dart';
import '../../../../providers/providers.dart';
import '../../../../utils/utils.dart';

class EditQuantityAndPrice extends StatefulWidget {
  final TransferRequestModel selectedTransferRequestModel;
  final void Function() unselectIndex;
  final TransferRequestEnterpriseModel originEnterprise;
  final TransferRequestEnterpriseModel destinyEnterprise;
  final GetProductJsonModel product;
  const EditQuantityAndPrice({
    required this.selectedTransferRequestModel,
    required this.unselectIndex,
    required this.originEnterprise,
    required this.destinyEnterprise,
    required this.product,
    super.key,
  });

  @override
  State<EditQuantityAndPrice> createState() => _EditQuantityAndPriceState();
}

class _EditQuantityAndPriceState extends State<EditQuantityAndPrice> {
  final quantityFormKey = GlobalKey<FormState>();
  final priceFormKey = GlobalKey<FormState>();
  final quantityFocusNode = FocusNode();
  final quantityController = TextEditingController();
  final priceFocusNode = FocusNode();
  final priceController = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    quantityFocusNode.dispose();
    quantityController.dispose();
    priceFocusNode.dispose();
    priceController.dispose();
  }

  Future<void> updateInCart(
    TransferRequestProvider transferRequestProvider,
  ) async {
    if (isValid(transferRequestProvider) != true) {
      return;
    } else if (widget.selectedTransferRequestModel.AllowAlterCostOrSalePrice ==
            true &&
        quantityFocusNode.hasFocus) {
      priceFocusNode.requestFocus();
      return;
    }

    ShowAlertDialog.show(
        context: context,
        title: "Deseja realmente atualizar?",
        function: () async {
          await transferRequestProvider.insertUpdateProductInCart(
            product: widget.product,
            quantityController: quantityController,
            newPriceController: priceController,
            enterpriseOriginCode: widget.originEnterprise.Code.toString(),
            enterpriseDestinyCode: widget.destinyEnterprise.Code.toString(),
            requestTypeCode:
                widget.selectedTransferRequestModel.Code.toString(),
            isAdding: false,
          );

          widget.unselectIndex();
        });
  }

  bool? isValid(TransferRequestProvider transferRequestProvider) {
    if (transferRequestProvider.getNewPrice(
          newQuantity: quantityController.text.toDouble(),
          product: widget.product,
          selectedTransferRequestModel: widget.selectedTransferRequestModel,
          newPrice: priceController.text.toDouble(),
        ) <
        0.01) {
      return false;
    } else if (widget.selectedTransferRequestModel.AllowAlterCostOrSalePrice ==
        true) {
      return priceFormKey.currentState?.validate() == true &&
          quantityFormKey.currentState?.validate() == true;
    } else {
      return quantityFormKey.currentState?.validate() == true;
    }
  }

  @override
  Widget build(BuildContext context) {
    TransferRequestProvider transferRequestProvider = Provider.of(context);
    double newPrice = transferRequestProvider.getNewPrice(
      newQuantity: quantityController.text.toDouble(),
      product: widget.product,
      selectedTransferRequestModel: widget.selectedTransferRequestModel,
      newPrice: priceController.text.toDouble(),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                InsertQuantityTextFormField(
                  focusNode: quantityFocusNode,
                  newQuantityController: quantityController,
                  formKey: quantityFormKey,
                  onChanged: (_) {
                    setState(() {});
                  },
                  onFieldSubmitted: (_) async {
                    await updateInCart(transferRequestProvider);
                  },
                ),
                if (widget.selectedTransferRequestModel
                        .AllowAlterCostOrSalePrice ==
                    true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InsertQuantityTextFormField(
                      showPrefixIcon: false,
                      showSuffixIcon: false,
                      canReceiveEmptyValue: false,
                      focusNode: priceFocusNode,
                      newQuantityController: priceController,
                      formKey: priceFormKey,
                      hintText: "Preço R\$",
                      labelText: "Preço R\$",
                      maxDecimalHouses: 2,
                      onChanged: (_) {
                        setState(() {});
                      },
                      onFieldSubmitted: (_) async {
                        await updateInCart(transferRequestProvider);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Novo preço \n ${(newPrice < 0.01 ? 0 : newPrice).toString().toBrazilianNumber().addBrazilianCoin()}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isValid(transferRequestProvider) != true
                      ? null
                      : () async {
                          await updateInCart(transferRequestProvider);
                        },
                  child: const FittedBox(child: Text("Alterar")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
