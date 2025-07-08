import 'package:flutter/material.dart';

class AddOrSubtractButton extends StatefulWidget {
  final Function function;
  final bool isSubtract;
  final GlobalKey<FormState> formKey;
  final bool isIndividual;
  final bool isLoading;
  final String subtractButtonText;
  final String addButtonText;

  const AddOrSubtractButton({
    required this.isLoading,
    required this.function,
    required this.isSubtract,
    required this.formKey,
    required this.isIndividual,
    required this.subtractButtonText,
    required this.addButtonText,
    Key? key,
  }) : super(key: key);

  @override
  State<AddOrSubtractButton> createState() => _AddOrSubtractButtonState();
}

class _AddOrSubtractButtonState extends State<AddOrSubtractButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 70),
        maximumSize: const Size(double.infinity, 70),
      ),
      onPressed: widget.isLoading
          ? null
          : () async {
              bool isValid = widget.formKey.currentState!.validate();

              if (!isValid) {
                return;
              }
              await widget.function();
            },
      child: widget.isLoading
          ? FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'CONFIRMANDO...',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    height: 40,
                    width: 40,
                    child: const CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : FittedBox(
              child: Text(
                widget.isSubtract
                    ? widget.subtractButtonText
                    : widget.addButtonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 40,
                ),
              ),
            ),
    );
  }
}
