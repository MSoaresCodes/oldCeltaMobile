import 'package:celta_inventario/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';
import '../../../components/components.dart';
import 'components.dart';

class ProductsItems extends StatefulWidget {
  final int enterpriseCode;
  final TextEditingController quantityController;
  final GlobalKey<FormState> insertQuantityFormKey;
  final Function getProductsWithCamera;
  final ScrollController scrollController;
  final VoidCallback expandHeader;
  final FocusNode searchFocusNode;
  const ProductsItems({
    required this.getProductsWithCamera,
    required this.enterpriseCode,
    required this.quantityController,
    required this.insertQuantityFormKey,
    required this.scrollController,
    required this.expandHeader,
    required this.searchFocusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductsItems> createState() => _ProductsItemsState();
}

class _ProductsItemsState extends State<ProductsItems> {
  int _selectedIndex = -1;

  void changeFocusToConsultedProductFocusNode({
    required TransferBetweenStocksProvider transferBetweenStocksProvider,
  }) {
    Future.delayed(const Duration(milliseconds: 300), () {
      //se não colocar em um future pra mudar o foco,
      //não funciona corretamente
      FocusScope.of(context).requestFocus(widget.searchFocusNode);
    });
  }

  void selectIndexAndFocus({
    required TransferBetweenStocksProvider transferBetweenStocksProvider,
    required int index,
  }) {
    widget.quantityController.text = "";

    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      if (widget.searchFocusNode.hasFocus &&
          MediaQuery.of(context).viewInsets.bottom == 0) {
        FocusScope.of(context).unfocus();
        changeFocusToConsultedProductFocusNode(
          transferBetweenStocksProvider: transferBetweenStocksProvider,
        );
      }
      if (!widget.searchFocusNode.hasFocus) {
        changeFocusToConsultedProductFocusNode(
          transferBetweenStocksProvider: transferBetweenStocksProvider,
        );
      }
      return;
    }

    if (_selectedIndex == index) {
      if (!widget.searchFocusNode.hasFocus) {
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
    final transferBetweenStocksProvider =
        Provider.of<TransferBetweenStocksProvider>(context);

    return ListView.builder(
      // shrinkWrap: true,
      controller: widget.scrollController,
      itemCount: transferBetweenStocksProvider.products.length,
      itemBuilder: (context, index) {
        final product = transferBetweenStocksProvider.products[index];

        if (transferBetweenStocksProvider.products.length == 1) {
          _selectedIndex = index;
        }

        double quantityInLot = transferBetweenStocksProvider.productsLots
            .where((e) =>
                e.product.productPackingCode == product.productPackingCode &&
                e.product.productCode == product.productCode &&
                e.enterpriseCode == widget.enterpriseCode)
            .fold(
              0.0,
              (previousValue, element) => previousValue + element.quantity,
            );

        return GestureDetector(
          onTap: transferBetweenStocksProvider
                      .isLoadingTypeStockAndJustifications ||
                  transferBetweenStocksProvider.isLoadingAdjustStock
              ? null
              : () {
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: quantityInLot > 0 ? 8 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (quantityInLot > 0)
                        Expanded(
                          flex: 9,
                          child: Text(
                            "${quantityInLot.toString().toBrazilianNumber(2)} qtd(s) no lote",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            _selectedIndex == index
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedIndex == index)
                  AddProductInLot(
                    searchFocusNode: widget.searchFocusNode,
                    quantityController: widget.quantityController,
                    insertQuantityFormKey: widget.insertQuantityFormKey,
                    internalEnterpriseCode: widget.enterpriseCode,
                    product: product,
                    getProductsWithCamera: widget.getProductsWithCamera,
                    expandHeader: widget.expandHeader,
                    onSuccess: () {
                      setState(() {
                        _selectedIndex = -1;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
