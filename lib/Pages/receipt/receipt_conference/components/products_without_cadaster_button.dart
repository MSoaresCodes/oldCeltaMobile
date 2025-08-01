import 'package:flutter/material.dart';

import '../../../../utils/utils.dart';

class ProductsWithoutCadasterButton extends StatelessWidget {
  final int docCode;
  const ProductsWithoutCadasterButton({
    required this.docCode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).pushNamed(
          APPROUTES.RECEIPT_PRODUCTS_WITHOUT_CADASTER,
          arguments: docCode,
        );
      },
      icon: const Icon(Icons.add),
      label: const FittedBox(child: Text("Não encontrados")),
    );
  }
}
