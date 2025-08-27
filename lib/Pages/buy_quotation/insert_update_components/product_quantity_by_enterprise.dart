import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';

class ProductQuantityByEnterprise extends StatelessWidget {
  final BuyQuotationProductsModel product;
  final int productIndex;

  const ProductQuantityByEnterprise({
    required this.product,
    required this.productIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BuyQuotationProvider buyQuotationProvider = Provider.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: product.ProductEnterprises?.length,
      itemBuilder: (context, enterpriseIndex) {
        int indexOfEnterprise = buyQuotationProvider.allEnterprises.indexWhere(
            (e) =>
                e.Code ==
                product.ProductEnterprises![enterpriseIndex].EnterpriseCode);

        if (indexOfEnterprise == -1) {
          return const SizedBox();
        }

        final enterprise =
            buyQuotationProvider.allEnterprises[indexOfEnterprise];

        if (!enterprise.isSelected) {
          return const SizedBox();
        }

        final productQuantity = buyQuotationProvider
            .productsWithNewValues[productIndex].ProductEnterprises!
            .where((e) => e.EnterpriseCode == enterprise.Code)
            .first
            .Quantity;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                enterprise.Name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              productQuantity.toString().toBrazilianNumber(),
            ),
          ],
        );
      },
    );
  }
}
