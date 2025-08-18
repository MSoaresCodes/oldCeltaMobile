import 'package:flutter/foundation.dart';
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
              child: Column(
                children: [
                  Text(
                    "Último pedido: " + lastSaleRequestSaved,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontStyle: FontStyle.italic,
                      fontFamily: "OpenSans",
                    ),
                  ),
                  if (kDebugMode) //TODO remove when is implemented
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {}, //TODO implement
                          icon: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {}, //TODO implement
                          icon: Icon(
                            Icons.print,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
