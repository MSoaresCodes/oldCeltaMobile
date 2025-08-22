import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';

class StateDropDown extends StatelessWidget {
  final FocusNode stateFocusNode;
  final ValueNotifier<String?> selectedState;
  final TextEditingController areaCodeController;
  const StateDropDown({
    super.key,
    required this.stateFocusNode,
    required this.selectedState,
    required this.areaCodeController,
  });

  @override
  Widget build(BuildContext context) {
    AddressProvider addressProvider = Provider.of(context);

    return DropdownButtonFormField<dynamic>(
      focusNode: stateFocusNode,
      initialValue: selectedState.value,
      isExpanded: true,
      hint: Center(
        child: Text(
          'Estado',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      validator: (value) {
        if (value == null && areaCodeController.text.length == 8) {
          return 'Selecione um estado!';
        }
        return null;
      },
      onChanged: addressProvider.isLoading
          ? null
          : (value) {
              selectedState.value = value;
            },
      items: addressProvider.states
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
    );
  }
}
