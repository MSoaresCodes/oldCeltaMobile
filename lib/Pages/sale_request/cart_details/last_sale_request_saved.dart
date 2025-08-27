import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';
import 'cart_details.dart';

class LastSaleRequestSaved extends StatefulWidget {
  final TextEditingController ipController;
  final FocusNode ipFocusNode;
  const LastSaleRequestSaved({
    required this.ipController,
    required this.ipFocusNode,
    super.key,
  });

  @override
  State<LastSaleRequestSaved> createState() => _LastSaleRequestSavedState();
}

class _LastSaleRequestSavedState extends State<LastSaleRequestSaved> {
  final ipFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final saleRequestProvider = Provider.of<SaleRequestProvider>(context);
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
                  if (saleRequestProvider.lastSaleRequestSaved != null)
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
                        PrintSaleRequestButton(
                          ipFocusNode: widget.ipFocusNode,
                          ipController: widget.ipController,
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
