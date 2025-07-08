import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';

class LimitAndBindCovenantButton extends StatelessWidget {
  final TextEditingController limitController;
  final FocusNode limitFocusNode;
  const LimitAndBindCovenantButton({
    required this.limitController,
    required this.limitFocusNode,
    super.key,
  });

  static final formKey = GlobalKey<FormState>();

  void associateCovenant(
    CustomerRegisterProvider customerRegisterProvider,
    BuildContext context,
  ) {
    bool? isValid = formKey.currentState?.validate();
    final limit = limitController.text.toDouble();

    if (isValid == true) {
      customerRegisterProvider.bindCovenant(limit: limit);
    }

    limitFocusNode.unfocus();
    limitController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    CustomerRegisterProvider customerRegisterProvider = Provider.of(context);

    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.fromLTRB(3, 5, 3, 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withAlpha(50),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: limitFocusNode,
                enabled: customerRegisterProvider.selectedCovenant != null,
                autofocus: false,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: limitController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: (_) {
                  associateCovenant(customerRegisterProvider, context);
                },
                validator: (value) => FormFieldValidations.number(
                  value,
                  maxDecimalPlaces: 2,
                ),
                decoration: FormFieldDecoration.decoration(
                  context: context,
                  hintText: "Limite R\$",
                  labelText: "Limite R\$",
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Center(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: customerRegisterProvider.selectedCovenant == null
                      ? null
                      : () {
                          associateCovenant(customerRegisterProvider, context);
                        },
                  child: FittedBox(
                    child: Text(
                      customerRegisterProvider.selectedCovenant == null
                          ? "Selecione um convênio"
                          : "Vincular convênio",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
