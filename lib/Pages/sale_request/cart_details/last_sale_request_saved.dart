import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../providers/providers.dart';
import 'cart_details.dart';

class LastSaleRequestSaved extends StatefulWidget {
  final SaleRequestProvider saleRequestProvider;
  const LastSaleRequestSaved({
    required this.saleRequestProvider,
    super.key,
  });

  @override
  State<LastSaleRequestSaved> createState() => _LastSaleRequestSavedState();
}

class _LastSaleRequestSavedState extends State<LastSaleRequestSaved> {
  final ipController = TextEditingController();
  final ipFocusNode = FocusNode();
  final ipFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    ipController.dispose();
    ipFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastSaleRequestSaved =
        widget.saleRequestProvider.lastSaleRequestSaved?.lastSaleRequestSaved;
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
                      widget.saleRequestProvider.lastSaleRequestSaved !=
                          null) //TODO remove when is implemented
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () async {
                            final pdf = await SaleRequestPdfGenerator.generate(
                              widget.saleRequestProvider.lastSaleRequestSaved!,
                            );

                            pdfViewerProvider.openPdfViewerPage(
                                pdf,
                                widget.saleRequestProvider.lastSaleRequestSaved!
                                    .lastSaleRequestSaved!);
                          },
                          icon: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              ipFocusNode.requestFocus();
                            });

                            ShowAlertDialog.show(
                              context: context,
                              title: "Impressão do pedido",
                              cancelMessage: "Cancelar",
                              confirmMessage: "Imprimir",
                              closeAutomaticallyOnConfirm: true,
                              canCloseClickingOut: false,
                              content: Column(
                                children: [
                                  const Text(
                                      "Para imprimir o pedido, precisa haver uma impressora compartilhada na mesma rede que o celular está conectado e você deve informar o IP da impressora no campo abaixo"),
                                  const SizedBox(height: 16),
                                  Form(
                                    key: ipFormKey,
                                    child: TextFormField(
                                      focusNode: ipFocusNode,
                                      controller: ipController,
                                      decoration:
                                          FormFieldDecoration.decoration(
                                        context: context,
                                        labelText: "IP",
                                        hintText: "IP",
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              signed: true),
                                      validator: (value) {
                                        //TODO save this IP locally when succeeds
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Por favor, escreva o IP';
                                        }

                                        final parts = value.split('.');

                                        if (parts.length != 4) {
                                          return 'O IP não está válido';
                                        }

                                        for (final part in parts) {
                                          final number = int.tryParse(part);

                                          if (number == null) {
                                            return 'O IP não está válido';
                                          } else if (number < 0 ||
                                              number > 255) {
                                            return 'O IP não está válido';
                                          }
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              function: () async {
                                if (ipFormKey.currentState?.validate() !=
                                    true) {
                                  return;
                                }
                                bool updated = await ReceiptPdfGenerator
                                    .printReceiptDirectly(
                                  widget.saleRequestProvider
                                      .lastSaleRequestSaved!,
                                  widget.saleRequestProvider,
                                  ipController.text,
                                  context,
                                );

                                if (updated) {
                                  Navigator.of(context).pop();
                                }
                              },
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
