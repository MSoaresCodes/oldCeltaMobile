import 'package:flutter/material.dart';

import '../../../Models/firebase/firebase.dart';

class MonthDetails extends StatelessWidget {
  final SoapActionsModel? monthData;
  final String month;
  final bool showUsersAndDatesInformations;
  const MonthDetails({
    required this.monthData,
    required this.month,
    this.showUsersAndDatesInformations = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return monthData == null
        ? const SizedBox()
        : Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        month,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      if (monthData?.adjustStockConfirmQuantity != null)
                        Text(
                            "Ajuste de estoque: ${monthData?.adjustStockConfirmQuantity}"),
                      if (monthData?.priceConferenceGetProductOrSendToPrint !=
                          null)
                        Text(
                            "Consulta de preços: ${monthData?.priceConferenceGetProductOrSendToPrint}"),
                      if (monthData?.inventoryEntryQuantity != null)
                        Text(
                            "Inventário: ${monthData?.inventoryEntryQuantity}"),
                      if (monthData?.receiptEntryQuantity != null)
                        Text(
                            "Confirmação quantidade recebimento: ${monthData?.receiptEntryQuantity}"),
                      if (monthData?.receiptLiberate != null)
                        Text(
                            "Liberação do documento no recebimento: ${monthData?.receiptLiberate}"),
                      if (monthData?.saleRequestSave != null)
                        Text(
                            "Pedidos de venda salvos: ${monthData?.saleRequestSave}"),
                      if (monthData?.transferBetweenStocksConfirmAdjust != null)
                        Text(
                            "Transferência entre estoques: ${monthData?.transferBetweenStocksConfirmAdjust}"),
                      if (monthData?.transferBetweenPackageConfirmAdjust !=
                          null)
                        Text(
                            "Transferência entre embalagens: ${monthData?.transferBetweenPackageConfirmAdjust}"),
                      if (monthData?.transferRequestSave != null)
                        Text(
                            "Pedidos de transferência salvos: ${monthData?.transferRequestSave}"),
                      if (monthData?.customerRegister != null)
                        Text(
                            "Cadastro de clientes: ${monthData?.customerRegister}"),
                      if (monthData?.buyRequestSave != null)
                        Text("Pedido de compras: ${monthData?.buyRequestSave}"),
                      if (monthData?.researchPricesInsertPrice != null)
                        Text(
                            "Pesquisa de preços concorrentes: ${monthData?.researchPricesInsertPrice}"),
                      if (monthData?.productsConference != null)
                        Text(
                            "Conferência de produtos: ${monthData?.productsConference}"),
                      if (monthData?.adjustSalePrice != null)
                        Text("Ajuste de preços: ${monthData?.adjustSalePrice}"),
                      if (monthData?.reports != null)
                        Text("Relatórios: ${monthData?.reports}"),
                      if (monthData != null &&
                          monthData?.users != null &&
                          showUsersAndDatesInformations)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "${monthData!.users!.length} usuários utilizaram o APP",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (monthData != null &&
                          monthData?.users != null &&
                          showUsersAndDatesInformations)
                        Wrap(
                          children: [
                            for (var i = 0; i < monthData!.users!.length; i++)
                              Text(monthData!.users![i].toString() + "; "),
                          ],
                        ),
                      if (monthData != null &&
                          monthData!.datesUsed != null &&
                          showUsersAndDatesInformations)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "Utilizaram o APP em ${monthData!.datesUsed!.length} datas diferentes",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // if (monthData != null && monthData!.datesUsed != null)
                      //   for (var i = 0;
                      //       i < monthData!.datesUsed!.length;
                      //       i++)
                      //     Text(monthData!.datesUsed![i].toString()),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
