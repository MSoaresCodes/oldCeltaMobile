import 'package:flutter/material.dart';

class DefaultDropDown<T> extends StatefulWidget {
  final GlobalKey<FormState> dropDownFormKey;
  final String? selectedValue;
  final void Function(String?)? changeSelectedValue;
  final String? Function(String?)? validator;
  final String hintText;
  final List<DropdownMenuItem<T>>? items;

  const DefaultDropDown({
    super.key,
    required this.dropDownFormKey,
    required this.selectedValue,
    required this.changeSelectedValue,
    required this.validator,
    required this.hintText,
    required this.items,
  });

  @override
  State<DefaultDropDown> createState() => _DefaultDropDownState();
}

class _DefaultDropDownState extends State<DefaultDropDown> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintStyle = TextStyle(
      color: widget.selectedValue == null
          ? theme.colorScheme.primary
          : Colors.black,
    );
    final errorStyle = TextStyle(
      color: theme.colorScheme.error,
    );

    return Container(
      height: 45,
      child: FormField(
        validator: widget.validator,
        builder: (field) {
          return SizedBox.expand(
            child: DropdownButton<dynamic>(
              padding: const EdgeInsets.only(top: 10),
              isDense: true,
              disabledHint:
                  Center(child: Text(widget.selectedValue ?? widget.hintText)),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: Container(
                child: Center(
                  child: FittedBox(
                    child: Text(
                      field.errorText ??
                          widget.selectedValue ??
                          widget.hintText,
                      style: field.hasError ? errorStyle : hintStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              onChanged: widget.changeSelectedValue == null
                  ? null
                  : (value) {
                      widget.dropDownFormKey.currentState?.reset();
                      if (widget.changeSelectedValue != null) {
                        widget.changeSelectedValue!(value);
                      }
                      field.validate();
                      field.didChange(value);
                    },
              items: widget.items,
            ),
          );
        },
      ),
    );
  }
}
