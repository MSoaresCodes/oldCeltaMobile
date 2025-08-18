import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';
import 'products.dart';

class ProductsItems extends StatefulWidget {
  final bool showOnlyCartProducts;
  const ProductsItems({
    this.showOnlyCartProducts = false,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductsItems> createState() => _ProductsItemsState();
}

class _ProductsItemsState extends State<ProductsItems> {
  void _updateCostControllerText(BuyRequestProvider buyRequestProvider) {
    GetProductJsonModel product;
    if (widget.showOnlyCartProducts) {
      product = buyRequestProvider
          .productsInCart[buyRequestProvider.indexOfSelectedProduct];
    } else {
      product = buyRequestProvider
          .products[buyRequestProvider.indexOfSelectedProduct];
    }
    setState(() {
      buyRequestProvider.priceController.text =
          ConvertString.convertToBrazilianNumber(
        getPracticedValue(product),
        decimalHouses: 4,
      );

      buyRequestProvider.priceController.text = buyRequestProvider
          .priceController.text
          .replaceAll(RegExp(r'\.'), ',');

      int pointQuantity =
          ",".allMatches(buyRequestProvider.priceController.text).length;

      for (var x = 1; x < pointQuantity; x++) {
        if (x < pointQuantity && pointQuantity > 1) {
          buyRequestProvider.priceController.text = buyRequestProvider
              .priceController.text
              .toString()
              .replaceFirst(RegExp(r'\,'), '');
        }
      }
    });
  }

  void _changeFocusToSelectedProduct(BuyRequestProvider buyRequestProvider) {
    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(
        buyRequestProvider.quantityFocusNode,
      );
    });
  }

  void changeFocusAndUpdatePriceControllerText(
    BuyRequestProvider buyRequestProvider,
  ) {
    _updateCostControllerText(buyRequestProvider);
    _changeFocusToSelectedProduct(buyRequestProvider);
  }

  void selectIndexAndFocus({
    required BuyRequestProvider buyRequestProvider,
    required int index,
  }) {
    buyRequestProvider.quantityController.text = "";
    buyRequestProvider.priceController.text = "";

    if (buyRequestProvider.isLoadingProducts ||
        buyRequestProvider.isLoadingInsertBuyRequest) {
      return;
    }

    if (kIsWeb) {
      if (buyRequestProvider.indexOfSelectedProduct != index) {
        buyRequestProvider.indexOfSelectedProduct = index;
        changeFocusAndUpdatePriceControllerText(buyRequestProvider);
      } else {
        buyRequestProvider.indexOfSelectedProduct = -1;
      }
      return;
    }

    if (buyRequestProvider.indexOfSelectedProduct != index) {
      buyRequestProvider.indexOfSelectedProduct = index;

      if ((buyRequestProvider.quantityFocusNode.hasFocus ||
              buyRequestProvider.priceFocusNode.hasFocus) &&
          MediaQuery.of(context).viewInsets.bottom == 0) {
        FocusScope.of(context).unfocus();
        changeFocusAndUpdatePriceControllerText(buyRequestProvider);
      }
      if (!buyRequestProvider.quantityFocusNode.hasFocus &&
          !buyRequestProvider.priceFocusNode.hasFocus) {
        changeFocusAndUpdatePriceControllerText(buyRequestProvider);
      }
      return;
    }

    if (buyRequestProvider.indexOfSelectedProduct == index) {
      if (!buyRequestProvider.quantityFocusNode.hasFocus &&
          !buyRequestProvider.priceFocusNode.hasFocus) {
        changeFocusAndUpdatePriceControllerText(buyRequestProvider);
      } else {
        buyRequestProvider.indexOfSelectedProduct = -1;
      }
    }
  }

  String getPracticedValue(GetProductJsonModel product) {
    if (product.valueTyped != 0) {
      return product.valueTyped!.toStringAsFixed(4);
    } else if (product.value == 0.0) {
      return product.realCost!.toStringAsFixed(4);
    } else {
      return product.value!.toStringAsFixed(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    BuyRequestProvider buyRequestProvider = Provider.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.showOnlyCartProducts
              ? buyRequestProvider.productsInCartCount
              : buyRequestProvider.productsCount,
          itemBuilder: (context, index) {
            if (buyRequestProvider.productsCount == 1 &&
                !widget.showOnlyCartProducts) {
              buyRequestProvider.indexOfSelectedProduct = index;
              buyRequestProvider.priceController.text =
                  getPracticedValue(buyRequestProvider.products[index]);
            } else if (buyRequestProvider.productsCount == 0 &&
                !widget.showOnlyCartProducts) {
              buyRequestProvider.indexOfSelectedProduct = -1;
            }

            final product = widget.showOnlyCartProducts
                ? buyRequestProvider.productsInCart[index]
                : buyRequestProvider.products[index];

            return GestureDetector(
              onTap: buyRequestProvider.isLoadingProducts ||
                      buyRequestProvider.isLoadingInsertBuyRequest
                  ? null
                  : () {
                      setState(() {
                        selectIndexAndFocus(
                          buyRequestProvider: buyRequestProvider,
                          index: index,
                        );
                      });
                    },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductItem(
                    enterpriseCode: product.enterpriseCode,
                    product: product,
                    showMargins: true,
                    showStocks: true,
                    showAddress: true,
                    showCosts: true,
                    showLastBuyEntrance: true,
                    showWholeInformations: false,
                    showPrice: false,
                    componentBeforeProductInformations:
                        TitleAndSubtitle.titleAndSubtitle(
                      fontSize: 20,
                      subtitleColor: Colors.yellow[900],
                      subtitle: _enterprisePersonalizedCodeAndName(
                        buyRequestProvider: buyRequestProvider,
                        product: product,
                      ),
                    ),
                    componentAfterProductInformations: Column(
                      children: [
                        CostsQuantityAndTotal(
                          practicedValue: getPracticedValue(product),
                          product: product,
                          index: index,
                        ),
                        if (buyRequestProvider.indexOfSelectedProduct == index)
                          InsertProductQuantity(
                            product: product,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

String _enterprisePersonalizedCodeAndName({
  required BuyRequestProvider buyRequestProvider,
  required GetProductJsonModel product,
}) {
  var enterprise = buyRequestProvider.enterprises.firstWhere(
    (element) => product.enterpriseCode == element.Code,
  );

  return "(${enterprise.PersonalizedCode}) - " + enterprise.Name;
}
