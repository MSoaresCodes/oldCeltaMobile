import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';
import 'cart_details.dart';

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
    final pdfViewerProvider = Provider.of<PdfViewerProvider>(context);

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
                  if (kDebugMode &&
                      saleRequestProvider.lastSaleRequestSaved !=
                          null) //TODO remove when is implemented
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final pdf = await SaleRequestPdfGenerator.generate(
                              saleRequestProvider.lastSaleRequestSaved!,
                            );

                            pdfViewerProvider.openPdfViewerPage(
                                pdf,
                                saleRequestProvider.lastSaleRequestSaved!
                                    .lastSaleRequestSaved!);
                          },
                          icon: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ReceiptPdfGenerator.printReceiptDirectly(
                              saleRequestProvider.lastSaleRequestSaved!,
                              saleRequestProvider,
                            );
                          }, //TODO implement
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
