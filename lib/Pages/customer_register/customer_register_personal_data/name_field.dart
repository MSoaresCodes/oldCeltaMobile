import 'package:flutter/material.dart';

import '../../../components/components.dart';

class NameField extends StatelessWidget {
  final FocusNode nameFocusNode;
  final FocusNode reducedNameFocusNode;
  final void Function()? validateFormKey;
  final TextEditingController nameController;
  const NameField({
    required this.nameFocusNode,
    required this.reducedNameFocusNode,
    required this.validateFormKey,
    required this.nameController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FormFieldWidget(
      enabled: true,
      focusNode: nameFocusNode,
      onFieldSubmitted: (String? value) {
        FocusScope.of(context).requestFocus(reducedNameFocusNode);
      },
      suffixWidget: IconButton(
        onPressed: () {
          nameController.text = "";
          nameFocusNode.requestFocus();
        },
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
      ),
      labelText: "Nome",
      validator: FormFieldValidations.nameAndLastName,
      textEditingController: nameController,
      limitOfCaracters: 50,
    );
  }
}
