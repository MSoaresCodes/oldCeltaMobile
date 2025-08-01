import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Models/models.dart';
import '../../../../providers/providers.dart';

class WighableProductsButton extends StatelessWidget {
  final int docCode;
  final EnterpriseModel enterprise;
  const WighableProductsButton({
    required this.docCode,
    required this.enterprise,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ReceiptProvider receiptProvider = Provider.of(context);
    ConfigurationsProvider configurationsProvider = Provider.of(context);
    return TextButton.icon(
      onPressed: () async {
        await receiptProvider.getProducts(
          docCode: docCode,
          context: context,
          searchValue: "",
          isSearchAllCountedProducts: true,
          configurationsProvider: configurationsProvider,
          enterprise: enterprise,
        );
      },
      icon: const Icon(Icons.search),
      label: const FittedBox(child: Text("Pesáveis")),
    );
  }
}
