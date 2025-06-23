import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';

class JustificationsAndStocksDropwdownWidget extends StatefulWidget {
  final GlobalKey<FormFieldState> keyJustifications;
  final GlobalKey<FormFieldState> keyOriginStockType;
  final GlobalKey<FormFieldState> keyDestinyStockType;
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
  final GlobalKey<FormFieldState> _keyJustifications = GlobalKey();
  final GlobalKey<FormFieldState> _keyOriginStockType = GlobalKey();
  final GlobalKey<FormFieldState> _keyDestinyStockType = GlobalKey();

  //se a justificativa possuir um código de estoque atrelado, significa que
  //somente esse estoque pode ser alterado quando selecionar essa justificativa.
  //Por isso, quando selecionar a justificativa, está validando se ela possui um
  //estoque atrelado e caso tenha, desativa o dropdown de tipo de estoque,
  //altera o nome do dropdown do tipo de estoque e atualiza o código do estoque
  //que precisa ser enviado na requisição do json

  bool _changedJustifications = false;
  bool _changedOriginStockType = false;
  bool _changedDestinyStockType = false;

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);

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
            DropdownButtonFormField<dynamic>(
              // isDense: false,
              key: _keyJustifications,
              disabledHint: transferBetweenStocksProvider
                      .isLoadingTypeStockAndJustifications
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FittedBox(
                          child: Text(
                            "Consultando",
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
                  : const Center(child: Text("Justificativas")),
              isExpanded: true,
              hint: Center(
                child: Text(
                  'Justificativas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              validator: (value) {
                if (value == null) {
                  return 'Selecione uma justificativa!';
                }
                return null;
              },
              onChanged: transferBetweenStocksProvider
                          .isLoadingTypeStockAndJustifications ||
                      transferBetweenStocksProvider.isLoadingAdjustStock ||
                      transferBetweenStocksProvider.isLoadingProducts ||
                      transferBetweenStocksProvider.products.isEmpty
                  ? null
                  : (value) {
                      _changedJustifications = true;
                    },
              items: transferBetweenStocksProvider.justifications
                  .map(
                    (value) => DropdownMenuItem(
                      alignment: Alignment.center,
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
                      value: value.Descricao_JustMov,
                      child: FittedBox(
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                value.Descricao_JustMov,
                              ),
                            ),
                            const Divider(
                              height: 4,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<dynamic>(
              // isDense: false,
              key: _keyOriginStockType,
              disabledHint: transferBetweenStocksProvider
                      .isLoadingTypeStockAndJustifications
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FittedBox(
                          child: Text(
                            "Consultando",
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
                  : Center(
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
              onChanged: transferBetweenStocksProvider
                          .isLoadingTypeStockAndJustifications ||
                      transferBetweenStocksProvider.isLoadingAdjustStock ||
                      transferBetweenStocksProvider.isLoadingProducts ||
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
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
                            const Divider(
                              height: 4,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            DropdownButtonFormField<dynamic>(
              // isDense: false,
              key: _keyDestinyStockType,
              disabledHint: transferBetweenStocksProvider
                      .isLoadingTypeStockAndJustifications
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const FittedBox(
                          child: Text(
                            "Consultando",
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
                  : const Center(
                      child: Text(
                        "Estoque de destino",
                      ),
                    ),
              isExpanded: true,
              hint: Center(
                child: Text(
                  'Estoque de destino',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
              onChanged: transferBetweenStocksProvider
                          .isLoadingTypeStockAndJustifications ||
                      transferBetweenStocksProvider.isLoadingAdjustStock ||
                      transferBetweenStocksProvider.isLoadingProducts ||
                      transferBetweenStocksProvider.products.isEmpty
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                value.Nome_TipoEstoque,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const Divider(
                              height: 4,
                              color: Colors.black,
                            ),
                          ],
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
