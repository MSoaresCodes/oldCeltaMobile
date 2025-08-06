import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/components.dart';
import '../../../../Models/models.dart';
import '../../../../providers/providers.dart';
import '../../../../utils/utils.dart';

class CnpjAndSurnameInput extends StatelessWidget {
  final TextEditingController cnpjController;
  final FocusNode cnpjFocusNode;
  final TextEditingController surnameController;
  final FocusNode surnameFocusNode;
  final SubEnterpriseModel? selectedSubEnterprise;

  const CnpjAndSurnameInput({
    required this.cnpjController,
    required this.cnpjFocusNode,
    required this.surnameController,
    required this.surnameFocusNode,
    required this.selectedSubEnterprise,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    WebProvider webProvider = Provider.of(context);
    Map? arguments = ModalRoute.of(context)!.settings.arguments as Map?;
    SubEnterpriseModel? selectedSubEnterprise =
        arguments?["selectedSubEnterprise"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: cnpjController,
            focusNode: cnpjFocusNode,
            enabled: selectedSubEnterprise == null,
            validator: (value) {
              if (value != null &&
                  webProvider.indexOfSelectedEnterprise != -1 &&
                  webProvider.enterprises[webProvider.indexOfSelectedEnterprise]
                          .subEnterprises!
                          .indexWhere((e) => e.cnpj == value.toInt()) !=
                      -1) {
                return "CNPJ já adicionado";
              } else if (selectedSubEnterprise != null) {
                return null;
              }
              return FormFieldValidations.cpfOrCnpj(value);
            },
            onFieldSubmitted: (value) async {
              if (value.isEmpty) {
                Future.delayed(Duration.zero, () {
                  cnpjFocusNode.requestFocus();
                });
              } else {
                surnameFocusNode.requestFocus();
              }
            },
            decoration: FormFieldDecoration.decoration(
              context: context,
              hintText: "Somente números",
              labelText: "CNPJ",
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: surnameController,
            focusNode: surnameFocusNode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Campo obrigatório";
              }
              return null;
            },
            onFieldSubmitted: (value) {},
            decoration: FormFieldDecoration.decoration(
              context: context,
              hintText: "Apelido",
              labelText: "Apelido",
            ),
          )
        ],
      ),
    );
  }
}
