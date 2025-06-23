import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';
import '../../../Models/products/products.dart';
import '../../../components/components.dart';
import 'components.dart';

class ProductsItems extends StatefulWidget {
  final int enterpriseCode;
  final TextEditingController consultedProductController;
  final GlobalKey<FormState> dropDownFormKey;
  final GlobalKey<FormState> insertQuantityFormKey;
  final Function getProductsWithCamera;
  const ProductsItems({
    required this.getProductsWithCamera,
    required this.enterpriseCode,
    required this.consultedProductController,
    required this.dropDownFormKey,
    required this.insertQuantityFormKey,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductsItems> createState() => _ProductsItemsState();
}

class _ProductsItemsState extends State<ProductsItems> {
  int _selectedIndex = -1;

  changeFocusToConsultedProductFocusNode({
    required TransferBetweenStocksProvider transferBetweenStocksProvider,
  }) {
    Future.delayed(const Duration(milliseconds: 300), () {
      //se não colocar em um future pra mudar o foco,
      //não funciona corretamente
      FocusScope.of(context).requestFocus(
        transferBetweenStocksProvider.consultedProductFocusNode,
      );
    });
  }

  selectIndexAndFocus({
    required TransferBetweenStocksProvider transferBetweenStocksProvider,
    required int index,
  }) {
    widget.consultedProductController.text = "";

    if (transferBetweenStocksProvider.productsCount == 1 ||
        transferBetweenStocksProvider.isLoadingProducts ||
        transferBetweenStocksProvider.isLoadingAdjustStock) {
      return;
    }

    if (kIsWeb) {
      if (_selectedIndex != index) {
        setState(() {
          _selectedIndex = index;
          changeFocusToConsultedProductFocusNode(
            transferBetweenStocksProvider: transferBetweenStocksProvider,
          );
        });
      } else {
        setState(() {
          _selectedIndex = -1;
        });
      }
      return;
    }

    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      if (transferBetweenStocksProvider.consultedProductFocusNode.hasFocus &&
          MediaQuery.of(context).viewInsets.bottom == 0) {
        FocusScope.of(context).unfocus();
        changeFocusToConsultedProductFocusNode(
          transferBetweenStocksProvider: transferBetweenStocksProvider,
        );
      }
      if (!transferBetweenStocksProvider.consultedProductFocusNode.hasFocus) {
        changeFocusToConsultedProductFocusNode(
          transferBetweenStocksProvider: transferBetweenStocksProvider,
        );
      }
      return;
    }

    if (_selectedIndex == index) {
      if (!transferBetweenStocksProvider.consultedProductFocusNode.hasFocus) {
        changeFocusToConsultedProductFocusNode(
          transferBetweenStocksProvider: transferBetweenStocksProvider,
        );
      } else {
        setState(() {
          _selectedIndex = -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);

    return Column(
      mainAxisAlignment: transferBetweenStocksProvider.productsCount > 1
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transferBetweenStocksProvider.productsCount,
          itemBuilder: (context, index) {
            if (transferBetweenStocksProvider.productsCount == 1) {
              _selectedIndex = index;
            }

            GetProductJsonModel product =
                transferBetweenStocksProvider.products[index];
            return GestureDetector(
              onTap: transferBetweenStocksProvider
                          .isLoadingTypeStockAndJustifications ||
                      transferBetweenStocksProvider.isLoadingAdjustStock
                  ? null
                  : () {
                      transferBetweenStocksProvider.updateBody(
                        product: product,
                      );

                      selectIndexAndFocus(
                        transferBetweenStocksProvider:
                            transferBetweenStocksProvider,
                        index: index,
                      );
                    },
              child: ProductItem(
                enterpriseCode: widget.enterpriseCode,
                product: product,
                showPrice: false,
                showWholeInformations: false,
                componentAfterProductInformations: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        _selectedIndex == index
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (transferBetweenStocksProvider.lastUpdatedQuantity !=
                            "" &&
                        transferBetweenStocksProvider
                                .indexOfLastProductChangedStockQuantity ==
                            index)
                      Text(
                        "Última quantidade: ${transferBetweenStocksProvider.lastUpdatedQuantity}",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'BebasNeue',
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1,
                          wordSpacing: 5,
                        ),
                      ),
                    if (_selectedIndex == index)
                      InsertQuantity(
                        consultedProductController:
                            widget.consultedProductController,
                        dropDownFormKey: widget.dropDownFormKey,
                        insertQuantityFormKey: widget.insertQuantityFormKey,
                        internalEnterpriseCode: widget.enterpriseCode,
                        index: index,
                        getProductsWithCamera: widget.getProductsWithCamera,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
