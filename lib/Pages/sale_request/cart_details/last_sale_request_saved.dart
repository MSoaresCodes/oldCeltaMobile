import 'package:flutter/material.dart';

import '../../../providers/providers.dart';

class LastSaleRequestSaved extends StatelessWidget {
  final SaleRequestProvider saleRequestProvider;
  const LastSaleRequestSaved({
    required this.saleRequestProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final lastSaleRequestSaved =
        saleRequestProvider.lastSaleRequestSaved?.lastSaleRequestSaved;
    return Container(
      width: double.infinity,
      child: lastSaleRequestSaved == null || lastSaleRequestSaved == ""
          ? null
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Último pedido: " + lastSaleRequestSaved,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic,
                  fontFamily: "OpenSans",
                ),
              ),
            ),
    );
  }
}
