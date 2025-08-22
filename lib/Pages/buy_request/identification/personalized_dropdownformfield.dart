import 'package:flutter/material.dart';

class PersonalizedDropdownFormfield extends StatefulWidget {
  final GlobalKey<FormFieldState> dropdownKey;
  final bool isLoading;
  final String isLoadingMessage;
  final String disabledHintText;
  final String? Function(dynamic)? validator;
  final List<DropdownMenuItem<dynamic>>? items;
  final void Function(dynamic)? onChanged;
  final dynamic value;

  const PersonalizedDropdownFormfield({
    required this.value,
    required this.dropdownKey,
    required this.isLoading,
    required this.disabledHintText,
    required this.items,
    required this.isLoadingMessage,
    required this.onChanged,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  State<PersonalizedDropdownFormfield> createState() =>
      _PersonalizedDropdownFormfieldState();
}

class _PersonalizedDropdownFormfieldState
    extends State<PersonalizedDropdownFormfield> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<dynamic>(
      // isDense: false,
      key: widget.dropdownKey,
      initialValue: widget.value,
      disabledHint: widget.isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  child: Text(
                    widget.isLoadingMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 60,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  height: 15,
                  width: 15,
                  child: const CircularProgressIndicator(),
                ),
              ],
            )
          : Center(child: Text(widget.disabledHintText)),
      isExpanded: true,
      hint: Center(
        child: Text(
          widget.disabledHintText,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
      items: widget.items,
    );
  }
}
