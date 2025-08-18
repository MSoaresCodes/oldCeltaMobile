import 'package:flutter/material.dart';

import '../../../components/components.dart';
import '../../Models/products/products.dart';
import '../../../utils/utils.dart';

class ProductItem extends StatelessWidget {
  final GetProductJsonModel product;
  final Widget? componentAfterProductInformations;
  final bool? showCosts;
  final bool? showLastBuyEntrance;
  final bool? showPrice;
  final bool? showWholeInformations;
  final bool? showMargins;
  final bool? showAddress;
  final bool? showStocks;
  final Widget? componentBeforeProductInformations;
  final int? enterpriseCode;
  const ProductItem({
    required this.product,
    required this.componentAfterProductInformations,
    required this.enterpriseCode,
    this.componentBeforeProductInformations,
    this.showPrice = true,
    this.showWholeInformations = true,
    this.showAddress = true,
    this.showStocks = true,
    this.showCosts,
    this.showLastBuyEntrance,
    this.showMargins,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final balanceStock = _balanceStock(product, enterpriseCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                if (componentBeforeProductInformations != null)
                  componentBeforeProductInformations!,
                TitleAndSubtitle.titleAndSubtitle(
                  title: "Produto",
                  subtitle: product.name.toString() +
                      " (${product.packingQuantity?.formatPackingQuantity()})",
                ),
                Row(
                  children: [
                    Expanded(
                      // flex: 6,
                      child: TitleAndSubtitle.titleAndSubtitle(
                        title: "PLU",
                        subtitle: product.plu,
                      ),
                    ),
                    Expanded(
                      // flex: 4,
                      child: OpenDialogProductInformations(
                        product: product,
                        pages: [
                          if (showPrice == true &&
                              ((product.wholePracticedPrice ?? 0) > 0 ||
                                  (product.retailPracticedPrice ?? 0) > 0 ||
                                  (product.eCommercePracticedPrice ?? 0) > 0))
                            Prices(product: product),
                          if (showStocks == true) Stocks(product: product),
                          if (showAddress == true)
                            StockAddress(product: product),
                          if (showLastBuyEntrance == true)
                            LastBuyEntrance(product: product),
                          if (showCosts == true) Costs(product: product),
                          if (showMargins == true) Margins(product: product),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showPrice == true)
                  getTitleAndSubtitle(
                    value: (product.value != null && product.value! > 0
                            ? product.value
                            : product.retailPracticedPrice)
                        .toString(),
                    isPrice: true,
                    successMessage: "Preço",
                    errorMessage: "Sem preço",
                    context: context,
                  ),
                TitleAndSubtitle.titleAndSubtitle(
                  title:
                      _getAtualStock(product, enterpriseCode)?.stockQuantity !=
                                  null &&
                              _getAtualStock(product, enterpriseCode)!
                                      .stockQuantity! >
                                  0
                          ? "Estoque atual"
                          : null,
                  subtitle: _getStockValueMessage(product, enterpriseCode),
                  subtitleColor:
                      _getStockSubtitleColor(context, product, enterpriseCode),
                ),
                if (balanceStock != null)
                  TitleAndSubtitle.titleAndSubtitle(
                    title: "Saldo",
                    subtitle: balanceStock.toString().toBrazilianNumber(3),
                    subtitleColor: Colors.green,
                  ),
                if (showWholeInformations == true)
                  Column(
                    children: [
                      getTitleAndSubtitle(
                        isPrice: true,
                        value: product.wholePracticedPrice.toString(),
                        successMessage: "Preço de atacado",
                        errorMessage: "Sem preço de atacado",
                        context: context,
                      ),
                      getTitleAndSubtitle(
                        isPrice: false,
                        value: product.minimumWholeQuantity.toString(),
                        successMessage: "Qtd mín atacado",
                        errorMessage: "Sem qtd mín p/ atacado",
                        context: context,
                      ),
                    ],
                  ),
                if (!product.liquidCost.toString().contains("-1") &&
                    showCosts == true)
                  //quando o usuário não possui permissão para consultar o estoque, a API retorna "-1.0"
                  getTitleAndSubtitle(
                    isPrice: true,
                    value: product.liquidCost.toString(),
                    successMessage: "Custo líquido",
                    errorMessage: "Sem custo líquido",
                    context: context,
                  ),
              ],
            ),
            if (componentAfterProductInformations != null)
              componentAfterProductInformations!,
          ],
        ),
      ),
    );
  }
}

StocksModel? _getAtualStock(GetProductJsonModel product, int? enterpriseCode) {
  final atualStock = product.stocks?.where((element) =>
      element.stockName == "Estoque Atual" &&
      element.enterpriseCode == enterpriseCode);
  if (atualStock?.isNotEmpty == true &&
      atualStock?.first.stockQuantity != null) {
    return atualStock!.first;
  }
  return null;
}

Widget getTitleAndSubtitle({
  required String value,
  required String successMessage,
  required String errorMessage,
  required bool isPrice,
  required BuildContext context,
}) {
  bool hasValue = double.tryParse(value) != null && double.tryParse(value)! > 0;

  return TitleAndSubtitle.titleAndSubtitle(
    title: hasValue ? successMessage : null,
    subtitle: hasValue
        ? (isPrice
            ? value.toBrazilianNumber().addBrazilianCoin()
            : value.toBrazilianNumber())
        : errorMessage,
    subtitleColor:
        hasValue ? Theme.of(context).colorScheme.primary : Colors.red,
  );
}

String _getStockValueMessage(GetProductJsonModel product, int? enterpriseCode) {
  final atualStock = _getAtualStock(product, enterpriseCode);

  if (atualStock == null || atualStock.stockQuantity == 0) {
    return "Sem estoque atual";
  } else if (atualStock.stockQuantity! >= 0) {
    return atualStock.stockQuantity!.toString().toBrazilianNumber();
  } else {
    return "Estoque negativo: " +
        atualStock.stockQuantity!.toString().toBrazilianNumber();
  }
}

Color _getStockSubtitleColor(
    BuildContext context, GetProductJsonModel product, int? enterpriseCode) {
  final atualStock = _getAtualStock(product, enterpriseCode);

  if (atualStock == null) {
    return Colors.black;
  } else if (atualStock.stockQuantity == 0) {
    return Colors.red;
  } else if (atualStock.stockQuantity! > 0) {
    return Theme.of(context).colorScheme.primary;
  } else {
    return Colors.red;
  }
}

double? _balanceStock(GetProductJsonModel product, int? enterpriseCode) {
  final balanceStock = product.stocks?.where((element) =>
      element.stockName?.toLowerCase().contains("saldo") == true &&
      element.enterpriseCode == enterpriseCode);

  if (balanceStock?.isNotEmpty == true &&
      balanceStock?.first.stockQuantity != null &&
      (balanceStock?.first.stockQuantity ?? 0) > 0) {
    return balanceStock!.first.stockQuantity;
  }
  return null;
}
