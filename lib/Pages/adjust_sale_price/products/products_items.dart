import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../components/components.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';

class ProductsItems extends StatefulWidget {
  const ProductsItems({super.key});

  @override
  State<ProductsItems> createState() => _ProductsItemsState();
}

class _ProductsItemsState extends State<ProductsItems> {
  void onTapProduct(
    BuildContext context,
    EnterpriseModel enterprise,
    GetProductJsonModel product,
  ) {
    Navigator.of(context).pushNamed(
      APPROUTES.ADJUST_SALE_PRICE,
      arguments: {
        "enterprise": enterprise,
        "product": product,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AdjustSalePriceProvider adjustSalePriceProvider = Provider.of(context);
    final EnterpriseModel enterprise =
        ModalRoute.of(context)!.settings.arguments! as EnterpriseModel;

    return Expanded(
      child: ListView.builder(
        itemCount: adjustSalePriceProvider.products.length,
        itemBuilder: (context, index) {
          final product = adjustSalePriceProvider.products[index];

          return ProductItem(
            product: product,
            componentAfterProductInformations: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    onTapProduct(context, enterprise, product);
                  },
                  child: const Text("Alterar preços"),
                ),
              ],
            ),
            enterpriseCode: enterprise.Code,
            showCosts: true,
            showMargins: true,
            showPrice: true,
            showLastBuyEntrance: false,
            showWholeInformations: false,
            showAddress: false,
            showStocks: false,
          );
        },
      ),
    );
  }
}
