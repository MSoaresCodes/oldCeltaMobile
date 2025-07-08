import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';
import '../../../utils/utils.dart';
import '../../../components/components.dart';
import './components.dart';

class ProductsItems extends StatefulWidget {
  final int inventoryCountingCode;
  final int productPackingCode;
  final bool isIndividual;
  final TextEditingController consultedProductController;
  final Function getProducts;
  const ProductsItems({
    Key? key,
    required this.inventoryCountingCode,
    required this.getProducts,
    required this.consultedProductController,
    required this.productPackingCode,
    required this.isIndividual,
  }) : super(key: key);

  @override
  State<ProductsItems> createState() => ProductsItemsState();
}

class ProductsItemsState extends State<ProductsItems> {
  addQuantity({
    bool? isSubtract = false,
    required InventoryProvider inventoryProvider,
    required ConfigurationsProvider configurationsProvider,
    required int indexOfProduct,
  }) async {
    double? quantity = double.tryParse(
        widget.consultedProductController.text.replaceAll(RegExp(r','), '.'));

    if (quantity != null && quantity >= 10000) {
      //se a quantidade digitada for maior que 10.000, vai abrir um alertDialog pra confirmar a quantidade
      ShowAlertDialog.show(
          context: context,
          title: 'Confirmar quantidade?',
          content: SingleChildScrollView(
            child: Text(
              isSubtract!
                  ? 'Quantidade digitada: -${ConvertString.convertToBrazilianNumber(quantity)}'
                  : 'Quantidade digitada: ${ConvertString.convertToBrazilianNumber(quantity)}',
              textAlign: TextAlign.center,
            ),
          ),
          function: () async {
            await inventoryProvider.addQuantity(
              indexOfProduct: indexOfProduct,
              consultedProductController: widget.consultedProductController,
              isIndividual: widget.isIndividual,
              context: context,
              countingCode: widget.inventoryCountingCode,
              isSubtract: isSubtract,
              configurationsProvider: configurationsProvider,
            );

            if (inventoryProvider.errorMessageQuantity == "" &&
                configurationsProvider.autoScan?.value == true) {
              await widget.getProducts();
            }
          });
    } else {
      //se a quantidade digitada for menor do que 10.000, vai adicionar direto a quantidade, sem o alertDialog pra confirmar
      await inventoryProvider.addQuantity(
        indexOfProduct: indexOfProduct,
        consultedProductController: widget.consultedProductController,
        isIndividual: widget.isIndividual,
        context: context,
        countingCode: widget.inventoryCountingCode,
        isSubtract: isSubtract!,
        configurationsProvider: configurationsProvider,
      );

      if (inventoryProvider.errorMessageQuantity == "" &&
          configurationsProvider.autoScan?.value == true) {
        await widget.getProducts();
      }
    }
  }

  anullQuantity({
    required InventoryProvider inventoryProvider,
    required ConfigurationsProvider configurationsProvider,
    required int index,
  }) async {
    FocusScope.of(context).unfocus();
    if (inventoryProvider.products[index].quantidadeInvContProEmb == -1) {
      ShowSnackbarMessage.show(
        message: "A quantidade já está nula!",
        context: context,
      );
      return;
    }

    ShowAlertDialog.show(
      confirmMessageSize: 300,
      cancelMessageSize: 300,
      context: context,
      title: "Deseja realmente anular a quantidade?",
      function: () async {
        await inventoryProvider.anullQuantity(
          indexOfProduct: index,
          inventoryProcessCode: widget.inventoryCountingCode,
          productPackingCode:
              inventoryProvider.products[index].codigoInternoProEmb,
          context: context,
        );

        if (inventoryProvider.errorMessageQuantity == "" &&
            configurationsProvider.autoScan?.value == true) {
          await widget.getProducts();
        }
      },
    );
  }

  selectIndexAndFocus({
    required InventoryProvider inventoryProvider,
    required int index,
  }) {
    widget.consultedProductController.text = "";

    if (inventoryProvider.productsCount == 1 ||
        inventoryProvider.isLoadingProducts ||
        inventoryProvider.isLoadingQuantity) {
      return;
    }

    if (kIsWeb) {
      if (_selectedIndex != index) {
        setState(() {
          _selectedIndex = index;
          inventoryProvider.alterFocusToConsultedProduct(context: context);
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

      if (inventoryProvider.consultedProductFocusNode.hasFocus &&
          MediaQuery.of(context).viewInsets.bottom == 0) {
        FocusScope.of(context).unfocus();
        inventoryProvider.alterFocusToConsultedProduct(context: context);
      }
      if (!inventoryProvider.consultedProductFocusNode.hasFocus) {
        inventoryProvider.alterFocusToConsultedProduct(context: context);
      }
      return;
    }

    if (_selectedIndex == index) {
      if (!inventoryProvider.consultedProductFocusNode.hasFocus) {
        inventoryProvider.alterFocusToConsultedProduct(context: context);
      } else {
        setState(() {
          _selectedIndex = -1;
        });
      }
    }
  }

  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    InventoryProvider inventoryProvider = Provider.of(context, listen: true);
    ConfigurationsProvider configurationsProvider =
        Provider.of(context, listen: true);

    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: inventoryProvider.productsCount,
        itemBuilder: (context, index) {
          if (inventoryProvider.productsCount == 1) {
            _selectedIndex = index;
          }

          return GestureDetector(
            onTap: () {
              selectIndexAndFocus(
                inventoryProvider: inventoryProvider,
                index: index,
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Produto",
                      subtitle: inventoryProvider.products[index].productName,
                      fontSize: 20,
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "PLU",
                      subtitle: inventoryProvider.products[index].plu,
                      fontSize: 20,
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Qtd contada",
                      subtitle: inventoryProvider
                                  .products[index].quantidadeInvContProEmb ==
                              -1
                          //quando o valor está nulo, eu coloco como "-1" pra tratar um bug
                          ? 'Sem contagem'
                          : ConvertString.convertToBrazilianNumber(
                              inventoryProvider
                                  .products[index].quantidadeInvContProEmb,
                            ),
                      subtitleColor: inventoryProvider
                                  .products[index].quantidadeInvContProEmb !=
                              -1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                      otherWidget: Icon(
                        _selectedIndex != index
                            ? Icons.arrow_drop_down_sharp
                            : Icons.arrow_drop_up_sharp,
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
                      fontSize: 20,
                    ),
                    if (inventoryProvider.lastQuantityAdded != 0 &&
                        _selectedIndex == index &&
                        inventoryProvider.indexOfLastAddedQuantity == index)
                      const SizedBox(height: 3),
                    if (inventoryProvider.lastQuantityAdded != 0 &&
                        _selectedIndex == index &&
                        inventoryProvider.indexOfLastAddedQuantity == index)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FittedBox(
                          child: Text(
                            'Última quantidade adicionada:  ${inventoryProvider.lastQuantityAdded.toStringAsFixed(3).replaceAll(RegExp(r'\.'), ',')}',
                            style: TextStyle(
                              fontSize: 100,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'BebasNeue',
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1,
                              wordSpacing: 4,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (!widget.isIndividual && _selectedIndex == index)
                      AddSubtractOrAnullWidget(
                        onFieldSubmitted: () async {
                          // await widget.getProducts();
                        },
                        addButtonText: "SOMAR",
                        subtractButtonText: "SUBTRAIR",
                        isUpdatingQuantity: inventoryProvider.isLoadingQuantity,
                        addQuantityFunction: () async {
                          await addQuantity(
                            indexOfProduct: index,
                            inventoryProvider: inventoryProvider,
                            configurationsProvider: configurationsProvider,
                          );
                        },
                        subtractQuantityFunction: () async {
                          await addQuantity(
                            indexOfProduct: index,
                            isSubtract: true,
                            inventoryProvider: inventoryProvider,
                            configurationsProvider: configurationsProvider,
                          );
                        },
                        anullFunction: () async {
                          await anullQuantity(
                            inventoryProvider: inventoryProvider,
                            configurationsProvider: configurationsProvider,
                            index: index,
                          );
                        },
                        consultedProductController:
                            widget.consultedProductController,
                        consultedProductFocusNode:
                            inventoryProvider.consultedProductFocusNode,
                      ),
                    if (widget.isIndividual && _selectedIndex == index)
                      InsertOneQuantity(
                        isIndividual: widget.isIndividual,
                        inventoryCountingCode: widget.inventoryCountingCode,
                        consultedProductController:
                            widget.consultedProductController,
                        indexOfProduct: index,
                        addQuantity: () async {
                          addQuantity(
                            inventoryProvider: inventoryProvider,
                            configurationsProvider: configurationsProvider,
                            indexOfProduct: index,
                          );
                        },
                        subtractQuantity: () async {
                          addQuantity(
                            isSubtract: true,
                            inventoryProvider: inventoryProvider,
                            configurationsProvider: configurationsProvider,
                            indexOfProduct: index,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
