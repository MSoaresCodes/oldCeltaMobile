import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../providers/providers.dart';

class PrintSaleRequestButton extends StatelessWidget {
  final FocusNode ipFocusNode;
  final TextEditingController ipController;

  const PrintSaleRequestButton({
    super.key,
    required this.ipFocusNode,
    required this.ipController,
  });

  static final ipFormKey = GlobalKey<FormState>();

  Future<void> onSubmit(
    SaleRequestProvider saleRequestProvider,
    BuildContext context,
  ) async {
    if (ipFormKey.currentState?.validate() != true) {
      return;
    }

    Navigator.of(context).pop();

    await saleRequestProvider.printPdf(
      context,
      ipController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final saleRequestProvider = Provider.of<SaleRequestProvider>(context);
    final theme = Theme.of(context);
    final isIOS = theme.platform == TargetPlatform.iOS;

    return IconButton(
      onPressed: () {
        Future.delayed(const Duration(milliseconds: 100), () {
          ipFocusNode.requestFocus();
        });

        ShowAlertDialog.show(
          context: context,
          title: "Impressão do pedido",
          cancelMessage: "Cancelar",
          confirmMessage: "Imprimir",
          closeAutomaticallyOnConfirm: false,
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
                  onFieldSubmitted: (_) async {
                    await onSubmit(saleRequestProvider, context);
                  },
                  decoration: FormFieldDecoration.decoration(
                    context: context,
                    labelText: "IP",
                    hintText: "IP",
                  ),
                  keyboardType: TextInputType.numberWithOptions(
                    signed: isIOS,
                    decimal: !isIOS,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
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
                      } else if (number < 0 || number > 255) {
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
            await onSubmit(saleRequestProvider, context);
          },
        );
      },
      icon: Icon(Icons.print, color: theme.colorScheme.primary),
    );
  }
}
