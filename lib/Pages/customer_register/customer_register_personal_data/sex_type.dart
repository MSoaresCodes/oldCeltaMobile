import 'package:flutter/material.dart';

class SexType extends StatelessWidget {
  final ValueNotifier<String?>? selectedSexDropDown;
  final FocusNode sexTypeFocusNode;
  final void Function()? validateFormKey;
  final bool cpfCnpjIsValid;
  final void Function(String?) changeSexDropDown;
  const SexType({
    required this.selectedSexDropDown,
    required this.sexTypeFocusNode,
    required this.validateFormKey,
    required this.cpfCnpjIsValid,
    required this.changeSexDropDown,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: DropdownButtonFormField<dynamic>(
        initialValue: selectedSexDropDown?.value,
        focusNode: sexTypeFocusNode,
        disabledHint: const Center(child: Text("Sexo")),
        isExpanded: true,
        hint: Center(
          child: Text(
            'Sexo',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        validator: (value) {
          if (value == null) {
            return 'Selecione uma opção!';
          }
          return null;
        },
        onChanged: cpfCnpjIsValid == false
            ? null
            : (value) {
                changeSexDropDown(value);
                if (validateFormKey != null) {
                  validateFormKey!();
                }
              },
        decoration: const InputDecoration(
          labelText: '',
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
          ),
        ),
        items: ["Masculino", "Feminino"]
            .map(
              (value) => DropdownMenuItem(
                alignment: Alignment.center,
                onTap: () {},
                value: value,
                child: FittedBox(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          value,
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
