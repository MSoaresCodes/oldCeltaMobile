import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/providers.dart';

class JustificationsDropdown extends StatefulWidget {
  final GlobalKey<FormState> dropDownFormKey;
  final TextStyle errorStyle;
  final TextStyle hintStyle;

  const JustificationsDropdown({
    super.key,
    required this.dropDownFormKey,
    required this.errorStyle,
    required this.hintStyle,
  });

  @override
  State<JustificationsDropdown> createState() => _JustificationsDropdownState();
}

class _JustificationsDropdownState extends State<JustificationsDropdown> {
  String? _selectedJustifications;

  @override
  Widget build(BuildContext context) {
    final transferBetweenStocksProvider =
        Provider.of<TransferBetweenStocksProvider>(context);

    return Container(
      height: 45,
      child: FormField(
        validator: (_) {
          if (_selectedJustifications == null) {
            return 'Selecione uma justificativa!';
          }
          return null;
        },
        builder: (field) {
          return SizedBox.expand(
            child: DropdownButton<dynamic>(
              padding: const EdgeInsets.only(top: 10),
              isDense: true,
              disabledHint: const Center(child: Text("Justificativas")),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              hint: Container(
                child: Center(
                  child: FittedBox(
                    child: Text(
                      field.errorText ??
                          _selectedJustifications ??
                          'Justificativas',
                      style: field.hasError
                          ? widget.errorStyle
                          : (_selectedJustifications == null
                              ? widget.hintStyle
                              : const TextStyle(color: Colors.black)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              onChanged: transferBetweenStocksProvider.products.isEmpty
                  ? null
                  : (value) {
                      widget.dropDownFormKey.currentState?.reset();
                      _selectedJustifications = value;
                      field.validate();
                      field.didChange(value);
                    },
              items: transferBetweenStocksProvider.justifications
                  .map(
                    (value) => DropdownMenuItem(
                      alignment: Alignment.center,
                      value: value.Descricao_JustMov,
                      child: FittedBox(
                        child: Center(child: Text(value.Descricao_JustMov)),
                      ),
                      onTap: () {
                        transferBetweenStocksProvider.updateBody(
                          justification: value,
                        );

                        if (value.CodigoInterno_TipoEstoque
                                .CodigoInterno_TipoEstoque !=
                            -1) {
                          transferBetweenStocksProvider
                              .justificationHasStockType = true;

                          setState(() {
                            transferBetweenStocksProvider
                                .updateJustificationStockTypeName(
                              value.CodigoInterno_TipoEstoque.Nome_TipoEstoque,
                            );
                          });
                        } else {
                          transferBetweenStocksProvider
                              .justificationHasStockType = false;
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
