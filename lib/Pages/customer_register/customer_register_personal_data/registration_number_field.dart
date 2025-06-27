import 'package:flutter/material.dart';

import '../../../components/components.dart';

class RegistrationNumberField extends StatelessWidget {
  final FocusNode nameFocusNode;
  final FocusNode registrationNumberFocusNode;
  final void Function()? validateFormKey;
  final TextEditingController registrationNumberController;
  const RegistrationNumberField({
    required this.nameFocusNode,
    required this.registrationNumberFocusNode,
    required this.validateFormKey,
    required this.registrationNumberController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FormFieldWidget(
      enabled: true,
      focusNode: registrationNumberFocusNode,
      onFieldSubmitted: (String? value) {
        FocusScope.of(context).requestFocus(nameFocusNode);
      },
      suffixWidget: IconButton(
        onPressed: () {
          registrationNumberController.text = "";
          registrationNumberFocusNode.requestFocus();
        },
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
      ),
      labelText: "Inscrição estadual",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Digite a inscrição!";
        }
        return null;
      },
      textEditingController: registrationNumberController,
      limitOfCaracters: 50,
    );
  }
}
