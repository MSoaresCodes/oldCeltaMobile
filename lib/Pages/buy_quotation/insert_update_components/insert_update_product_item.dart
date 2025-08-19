import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import '../buy_quotation.dart';

class InsertUpdateProductItem extends StatelessWidget {
  final int productIndex;
  final int? selectedProductIndex;
  final void Function()? updateSelectedIndex;
  final BuyQuotationProductsModel product;
  final List<Map<int, TextEditingController>> controllers;
  final List<Map<int, FocusNode>> focusNodes;
  const InsertUpdateProductItem({
    required this.productIndex,
    required this.selectedProductIndex,
    required this.updateSelectedIndex,
    required this.product,
    required this.controllers,
    required this.focusNodes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BuyQuotationProvider buyQuotationProvider = Provider.of(context);

    return InkWell(
      onTap: updateSelectedIndex,
      child: Column(
        children: [
          ProductItem(
            product: product.Product!,
            showAddress: true,
            showPrice: false,
            showWholeInformations: false,
            enterpriseCode: null,
            componentBeforeProductInformations: ProductQuantityByEnterprise(
              product: product,
              productIndex: productIndex,
            ),
            componentAfterProductInformations: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        ShowAlertDialog.show(
                          context: context,
                          title: "Remover produto?",
                          function: () async {
                            buyQuotationProvider
                                .removeProductWithNewValue(productIndex);
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                    Icon(
                      selectedProductIndex == productIndex
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  ],
                ),
                if (selectedProductIndex == productIndex)
                  UpdateQuantity(
                    controllers: controllers,
                    focusNodes: focusNodes,
                    updateSelectedIndex: updateSelectedIndex,
                    productIndex: productIndex,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
