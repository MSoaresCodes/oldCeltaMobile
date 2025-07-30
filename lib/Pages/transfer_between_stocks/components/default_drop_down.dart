import 'package:flutter/material.dart';

class DefaultDropDown<T> extends StatefulWidget {
  final GlobalKey<FormState> dropDownFormKey;
  final String? selectedValue;
  final void Function(T?)? changeSelectedValue;
  final String? Function(T?)? validator;
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
  State<DefaultDropDown<T>> createState() => _DefaultDropDownState<T>();
}

class _DefaultDropDownState<T> extends State<DefaultDropDown<T>> {
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
      child: FormField<T>(
        validator: widget.validator,
        builder: (field) {
          return SizedBox.expand(
            child: DropdownButton<T>(
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
                  : (T? value) {
                      widget.dropDownFormKey.currentState?.reset();
                      if (widget.changeSelectedValue != null) {
                        widget.changeSelectedValue!(value);
                      }
                      field.validate();
                      field.didChange(value);
                    },
              items: widget.items?.map<DropdownMenuItem<T>>((dynamic item) {
                return item as DropdownMenuItem<T>;
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
