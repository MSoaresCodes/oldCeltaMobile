import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';
import '../components.dart';

class CepField extends StatefulWidget {
  final TextEditingController zipController;
  final FocusNode cepFocusNode;
  final void Function()? getAdressByCep;
  const CepField({
    super.key,
    required this.zipController,
    required this.cepFocusNode,
    required this.getAdressByCep,
  });

  @override
  State<CepField> createState() => _CepFieldState();
}

class _CepFieldState extends State<CepField> {
  bool canSearch = false;
  void changeCanSearch() {
    if (widget.zipController.text.length == 8) {
      setState(() {
        canSearch = true;
      });
    } else {
      setState(() {
        canSearch = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomerRegisterProvider customerRegisterProvider = Provider.of(context);

    return FormFieldWidget(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: !customerRegisterProvider.isLoading,
      focusNode: widget.cepFocusNode,
      onChanged: (_) {
        changeCanSearch();
      },
      onFieldSubmitted: (_) async {
        if (canSearch) {
          widget.getAdressByCep!();
        } else {
          widget.cepFocusNode.requestFocus();
        }
      },
      labelText: "CEP",
      textEditingController: widget.zipController,
      limitOfCaracters: 8,
      validator: FormFieldValidations.cep,
      suffixWidget: TextButton(
        child: const Text("Pesquisar CEP"),
        onPressed: canSearch ? widget.getAdressByCep : null,
      ),
    );
  }
}
