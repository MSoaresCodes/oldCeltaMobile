import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';
import 'default_drop_down.dart';

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
  String? selectedJustification; //TODO move to provider
  String? selectedOriginStock; //TODO move to provider
  String? selectedDestinyStock; //TODO move to provider

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);

    int indexSelectedJustification = transferBetweenStocksProvider
        .justifications
        .indexWhere((e) => e.Descricao_JustMov == selectedJustification);

    String fixedOrigin = indexSelectedJustification == -1
        ? ""
        : transferBetweenStocksProvider
            .justifications[indexSelectedJustification].Nome_TipoEstoque;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Form(
        key: widget.dropDownFormKey,
        child: Column(
          children: [
            DefaultDropDown(
              dropDownFormKey: widget.dropDownFormKey,
              hintText: "Justificativas",
              selectedValue: selectedJustification,
              validator: (_) {
                if (selectedJustification == null) {
                  return 'Selecione uma justificativa!';
                }
                return null;
              },
              changeSelectedValue: (value) {
                setState(() {
                  selectedJustification = value;
                  indexSelectedJustification =
                      transferBetweenStocksProvider.justifications.indexWhere(
                          (e) => e.Descricao_JustMov == selectedJustification);

                  fixedOrigin = indexSelectedJustification == -1
                      ? ""
                      : transferBetweenStocksProvider
                          .justifications[indexSelectedJustification]
                          .Nome_TipoEstoque;

                  if (fixedOrigin.isNotEmpty) {
                    selectedOriginStock = fixedOrigin;
                  } else {
                    selectedOriginStock = null;
                  }
                });
                debugPrint("selectedOriginStock $selectedOriginStock");
              },
              items: transferBetweenStocksProvider.justifications
                  .map(
                    (value) => DropdownMenuItem(
                      alignment: Alignment.center,
                      value: value.Descricao_JustMov,
                      child: FittedBox(
                        child: Center(child: Text(value.Descricao_JustMov)),
                      ),
                    ),
                  )
                  .toList(),
            ),
            DefaultDropDown(
              dropDownFormKey: widget.dropDownFormKey,
              selectedValue: selectedOriginStock,
              hintText: selectedOriginStock ?? "Estoque de origem",
              changeSelectedValue: fixedOrigin.isNotEmpty == true
                  ? null
                  : (value) {
                      setState(() {
                        selectedOriginStock = value;
                      });
                    },
              validator: (_) {
                if (selectedOriginStock?.isNotEmpty == true) {
                  return null;
                } else if (selectedOriginStock == null) {
                  return 'Selecione um tipo de estoque!';
                }
                return null;
              },
              items: transferBetweenStocksProvider.originStockTypes
                  .map(
                    (value) => DropdownMenuItem(
                      alignment: Alignment.center,
                      value: value.Nome_TipoEstoque,
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
            //TODO BELOW, man kkkkk
            DefaultDropDown(
              dropDownFormKey: widget.dropDownFormKey,
              selectedValue: selectedDestinyStock,
              hintText: selectedDestinyStock ?? "Estoque de destino",
              changeSelectedValue: (value) {
                setState(() {
                  selectedDestinyStock = value;
                });
              },
              validator: (_) {
                if (selectedDestinyStock == null) {
                  return 'Selecione um tipo de estoque!';
                } else if (transferBetweenStocksProvider
                        .transferBodyModel?.StockTypeCode ==
                    transferBetweenStocksProvider
                        .transferBodyModel?.StockTypeRecipientCode) {
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
