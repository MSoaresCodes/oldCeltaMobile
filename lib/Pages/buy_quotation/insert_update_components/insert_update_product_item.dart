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

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: productIndex % 2 == 0
            ? Theme.of(context).primaryColor.withAlpha(30)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 0.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: updateSelectedIndex,
              child: Column(
                children: [
                  ProductQuantityByEnterprise(
                    product: product,
                    productIndex: productIndex,
                  ),
                  TitleAndSubtitle.titleAndSubtitle(
                    subtitle:
                        "${product.Product!.name} - (${product.Product?.packingQuantity})",
                    otherWidget: IconButton(
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
                  ),
                  TitleAndSubtitle.titleAndSubtitle(
                    title: "PLU",
                    subtitle: product.Product!.plu,
                    otherWidget: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton.icon(
                        onPressed: updateSelectedIndex,
                        label: const Text("Qtd"),
                        iconAlignment: IconAlignment.end,
                        icon: Icon(
                          selectedProductIndex == productIndex
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (selectedProductIndex == productIndex)
              UpdateQuantity(
                controllers: controllers,
                focusNodes: focusNodes,
                updateSelectedIndex: updateSelectedIndex,
                productIndex: productIndex,
              )
          ],
        ),
      ),
    );
  }
}
