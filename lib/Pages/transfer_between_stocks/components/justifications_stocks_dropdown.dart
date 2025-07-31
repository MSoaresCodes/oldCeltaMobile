import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import 'default_drop_down.dart';

class JustificationsAndStocksDropwdownWidget extends StatefulWidget {
  const JustificationsAndStocksDropwdownWidget({
    super.key,
  });

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
      child: Column(
        children: [
          DefaultDropDown<GetJustificationsModel?>(
            hintText: "Justificativas",
            selectedValue: transferBetweenStocksProvider
                .selectedJustification?.Descricao_JustMov,
            errorText: transferBetweenStocksProvider.errorSelectedJustification,
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
            selectedValue:
                transferBetweenStocksProvider.selectedOrigin?.Nome_TipoEstoque,
            hintText: "Estoque de origem",
            changeSelectedValue:
                transferBetweenStocksProvider.getFixedOrigin() != null
                    ? null
                    : (value) {
                        transferBetweenStocksProvider
                            .changeSelectedOrigin(value);
                      },
            errorText: transferBetweenStocksProvider.errorSelectedOrigin,
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
            selectedValue:
                transferBetweenStocksProvider.selectedDestiny?.Nome_TipoEstoque,
            hintText: "Estoque de destino",
            changeSelectedValue: (value) {
              transferBetweenStocksProvider.changeSelectedDestiny(value);
            },
            errorText: transferBetweenStocksProvider.errorSelectedDestiny,
            items: transferBetweenStocksProvider.destinyStockTypes
                .map(
                  (value) => DropdownMenuItem(
                    alignment: Alignment.center,
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
    );
  }
}
