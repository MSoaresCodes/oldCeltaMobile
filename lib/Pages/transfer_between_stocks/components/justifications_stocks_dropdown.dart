import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';

class JustificationsAndStocksDropwdownWidget extends StatefulWidget {
  final GlobalKey<FormState> keyJustifications;
  final GlobalKey<FormState> keyOriginStockType;
  final GlobalKey<FormState> keyDestinyStockType;
  final GlobalKey<FormState> dropDownFormKey;

  const JustificationsAndStocksDropwdownWidget({
    required this.dropDownFormKey,
    required this.keyJustifications,
    required this.keyOriginStockType,
    required this.keyDestinyStockType,
    Key? key,
  }) : super(key: key);

  @override
  State<JustificationsAndStocksDropwdownWidget> createState() =>
      _JustificationsAndStocksDropwdownWidgetState();
}

class _JustificationsAndStocksDropwdownWidgetState
    extends State<JustificationsAndStocksDropwdownWidget> {
  final _keyJustifications = GlobalKey<FormState>();
  final _keyOriginStockType = GlobalKey<FormState>();
  final _keyDestinyStockType = GlobalKey<FormState>();

  //se a justificativa possuir um código de estoque atrelado, significa que
  //somente esse estoque pode ser alterado quando selecionar essa justificativa.
  //Por isso, quando selecionar a justificativa, está validando se ela possui um
  //estoque atrelado e caso tenha, desativa o dropdown de tipo de estoque,
  //altera o nome do dropdown do tipo de estoque e atualiza o código do estoque
  //que precisa ser enviado na requisição do json

  bool _changedJustifications = false;
  String? _selectedJustifications;
  bool _changedOriginStockType = false;
  bool _changedDestinyStockType = false;

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);
    final theme = Theme.of(context);
    final hintStyle = TextStyle(
      color: theme.colorScheme.primary,
    );
    final errorStyle = TextStyle(
      color: theme.colorScheme.error,
    );

    if (transferBetweenStocksProvider.isLoadingTypeStockAndJustifications) {
      if (_changedJustifications) {
        _keyJustifications.currentState?.reset();
        _changedJustifications = false;
      }
      if (_changedOriginStockType) {
        _keyOriginStockType.currentState?.reset();
        _changedOriginStockType = false;
      }
      if (_changedDestinyStockType) {
        _keyDestinyStockType.currentState?.reset();
        _changedDestinyStockType = false;
      }
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: widget.dropDownFormKey,
        child: Column(
          children: [
            FormField(
              validator: (value) {
                if (value == null) {
                  return 'Selecione uma justificativa!';
                }
                return null;
              },
              builder: (field) {
                return DropdownButton<dynamic>(
                  isDense: true,
                  key: _keyJustifications,
                  disabledHint: const Center(child: Text("Justificativas")),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: Center(
                    child: FittedBox(
                      child: Text(
                        field.errorText ??
                            _selectedJustifications ??
                            'Justificativas',
                        style: field.hasError
                            ? errorStyle
                            : (_selectedJustifications == null
                                ? hintStyle
                                : const TextStyle(color: Colors.black)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  onChanged: transferBetweenStocksProvider.products.isEmpty
                      ? null
                      : (value) {
                          _changedJustifications = true;
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
                                  value.CodigoInterno_TipoEstoque
                                      .Nome_TipoEstoque,
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
                );
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<dynamic>(
              // isDense: false,
              key: _keyOriginStockType,
              disabledHint: Center(
                child: Text(
                  transferBetweenStocksProvider.justificationHasStockType
                      ? transferBetweenStocksProvider
                          .fixedJustificationStockName
                      : "Estoque de origem",
                ),
              ),
              isExpanded: true,
              hint: Center(
                child: Text(
                  'Estoque de origem',
                  style: hintStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              validator: (value) {
                if (transferBetweenStocksProvider.justificationHasStockType) {
                  return null;
                } else if (value == null) {
                  return 'Selecione um tipo de estoque!';
                }
                return null;
              },
              onChanged:
                  transferBetweenStocksProvider.justificationHasStockType ||
                          transferBetweenStocksProvider.products.isEmpty
                      ? null
                      : (value) {
                          _changedOriginStockType = true;
                        },
              items: transferBetweenStocksProvider.originStockTypes
                  .map(
                    (value) => DropdownMenuItem(
                      alignment: Alignment.center,
                      onTap: () {
                        transferBetweenStocksProvider.updateBody(
                          originStock: value,
                        );
                      },
                      value: value.Nome_TipoEstoque,
                      child: FittedBox(
                        child: Text(
                          transferBetweenStocksProvider
                                  .justificationHasStockType
                              ? transferBetweenStocksProvider
                                  .fixedJustificationStockName
                              : value.Nome_TipoEstoque,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            DropdownButtonFormField<dynamic>(
              // isDense: false,
              key: _keyDestinyStockType,
              disabledHint: const Center(child: Text("Estoque de destino")),
              isExpanded: true,
              hint: Center(
                child: Text(
                  'Estoque de destino',
                  style: hintStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              validator: (value) {
                if (value == null) {
                  return 'Selecione um tipo de estoque!';
                } else if (transferBetweenStocksProvider
                        .transferBodyModel?.StockTypeCode ==
                    transferBetweenStocksProvider
                        .transferBodyModel?.StockTypeRecipientCode) {
                  return "Os estoques devem ser diferentes!";
                }
                return null;
              },
              onChanged: transferBetweenStocksProvider.products.isEmpty
                  ? null
                  : (value) {
                      _changedDestinyStockType = true;
                    },
              items: transferBetweenStocksProvider.destinyStockTypes
                  .map(
                    (value) => DropdownMenuItem(
                      alignment: Alignment.center,
                      onTap: () {
                        transferBetweenStocksProvider.updateBody(
                          destinyStock: value,
                        );
                      },
                      value: value.Nome_TipoEstoque,
                      child: FittedBox(
                        child: Text(
                          value.Nome_TipoEstoque,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
