import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../providers/providers.dart';

class CpfOrCnpjField extends StatelessWidget {
  final FocusNode cpfCnpjFocusNode;
  final FocusNode nameFocusNode;
  final void Function(String) changeCpfCnpj;
  final TextEditingController cpfCnpjController;
  const CpfOrCnpjField({
    required this.cpfCnpjFocusNode,
    required this.nameFocusNode,
    required this.changeCpfCnpj,
    required this.cpfCnpjController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    CustomerRegisterProvider customerRegisterProvider = Provider.of(context);
    return FormFieldWidget(
      autofocus: true,
      focusNode: cpfCnpjFocusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: true,
      onChanged: changeCpfCnpj,
      suffixWidget: IconButton(
        onPressed: () {
          cpfCnpjController.text = "";
          changeCpfCnpj("");
          customerRegisterProvider.clearCustomer();
          FocusScope.of(context).requestFocus(cpfCnpjFocusNode);
        },
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
      ),
      onFieldSubmitted: (String? value) {
        nameFocusNode.requestFocus();
      },
      labelText: "CPF/CNPJ",
      validator: FormFieldValidations.cpfOrCnpj,
      textEditingController: cpfCnpjController,
      limitOfCaracters: 14,
    );
  }
}
