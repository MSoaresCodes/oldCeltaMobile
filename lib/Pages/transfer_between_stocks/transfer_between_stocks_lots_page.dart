import 'package:celta_inventario/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../providers/providers.dart';

class TransferBetweenStocksLotsPage extends StatelessWidget {
  const TransferBetweenStocksLotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transferBetweenStocksProvider =
        Provider.of<TransferBetweenStocksProvider>(context);

    return ListView.builder(
      itemCount: transferBetweenStocksProvider.productsLots.length,
      itemBuilder: (context, index) {
        final lot = transferBetweenStocksProvider.productsLots[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TitleAndSubtitle.titleAndSubtitle(
                  title: "ProductCode",
                  subtitle: lot.product.productCode.toString(),
                ),
                TitleAndSubtitle.titleAndSubtitle(
                  title: "productPackingCode",
                  subtitle: lot.product.productPackingCode.toString(),
                ),
                TitleAndSubtitle.titleAndSubtitle(
                  title: "quantity",
                  subtitle: lot.quantity.toString().toBrazilianNumber(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
