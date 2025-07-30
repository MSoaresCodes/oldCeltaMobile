import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import 'default_drop_down.dart';

class JustificationsAndStocksDropwdownWidget extends StatefulWidget {
  final GlobalKey<FormState> dropDownFormKey;

  const JustificationsAndStocksDropwdownWidget({
    required this.dropDownFormKey,
    Key? key,
  }) : super(key: key);

  @override
  State<JustificationsAndStocksDropwdownWidget> createState() =>
      _JustificationsAndStocksDropwdownWidgetState();
}

class _JustificationsAndStocksDropwdownWidgetState
    extends State<JustificationsAndStocksDropwdownWidget> {
  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Form(
        key: widget.dropDownFormKey,
        child: Column(
          children: [
            DefaultDropDown<GetJustificationsModel?>(
              dropDownFormKey: widget.dropDownFormKey,
              hintText: "Justificativas",
              selectedValue: transferBetweenStocksProvider
                  .selectedJustification?.Descricao_JustMov,
              validator: (_) {
                if (transferBetweenStocksProvider.selectedJustification ==
                    null) {
                  return 'Selecione uma justificativa!';
                }
                return null;
              },
              changeSelectedValue: (GetJustificationsModel? value) {
                setState(() {
                  transferBetweenStocksProvider
                      .changeSelectedJustification(value);
                });
              },
              items: transferBetweenStocksProvider.justifications
                  .map(
                    (GetJustificationsModel value) => DropdownMenuItem(
                      alignment: Alignment.center,
                      value: value,
                      child: FittedBox(
                        child: Center(child: Text(value.Descricao_JustMov)),
                      ),
                    ),
                  )
                  .toList(),
            ),
            DefaultDropDown<GetStockTypesModel?>(
              dropDownFormKey: widget.dropDownFormKey,
              selectedValue: transferBetweenStocksProvider
                  .selectedOrigin?.Nome_TipoEstoque,
              hintText: "Estoque de origem",
              changeSelectedValue:
                  transferBetweenStocksProvider.getFixedOrigin() != null
                      ? null
                      : (value) {
                          transferBetweenStocksProvider
                              .changeSelectedOrigin(value);
                        },
              validator: (_) {
                if (transferBetweenStocksProvider.selectedOrigin != null) {
                  return null;
                } else if (transferBetweenStocksProvider.selectedOrigin ==
                    null) {
                  return 'Selecione um tipo de estoque!';
                }
                return null;
              },
              items: transferBetweenStocksProvider.originStockTypes
                  .map(
                    (value) => DropdownMenuItem(
                      alignment: Alignment.center,
                      value: value,
                      child: FittedBox(
                        child: Text(
                          value.Nome_TipoEstoque,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            DefaultDropDown<GetStockTypesModel?>(
              dropDownFormKey: widget.dropDownFormKey,
              selectedValue: transferBetweenStocksProvider
                  .selectedDestiny?.Nome_TipoEstoque,
              hintText: "Estoque de destino",
              changeSelectedValue: (value) {
                transferBetweenStocksProvider.changeSelectedDestiny(value);
              },
              validator: (value) {
                if (transferBetweenStocksProvider.selectedDestiny == null) {
                  return 'Selecione um tipo de estoque!';
                } else if (transferBetweenStocksProvider
                        .selectedOrigin?.CodigoInterno_TipoEstoque ==
                    value?.CodigoInterno_TipoEstoque) {
                  return "Estoque igual ao de origem";
                } else if (transferBetweenStocksProvider
                        .selectedOrigin?.CodigoInterno_TipoEstoque ==
                    transferBetweenStocksProvider
                        .selectedDestiny?.CodigoInterno_TipoEstoque) {
                  return "Os estoques devem ser diferentes!";
                }
                return null;
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
                      value: value,
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
