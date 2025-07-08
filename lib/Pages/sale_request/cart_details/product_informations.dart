import 'package:celta_inventario/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../Models/models.dart';
import '../../../providers/providers.dart';

class ProductInformations extends StatelessWidget {
  final int index;
  final GetProductJsonModel product;
  final int enterpriseCode;
  final int selectedIndex;

  const ProductInformations({
    required this.index,
    required this.product,
    required this.enterpriseCode,
    required this.selectedIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    SaleRequestProvider saleRequestProvider = Provider.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
                child: FittedBox(
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name! +
                          " (${product.packingQuantity?.formatPackingQuantity()})" +
                          '\nplu: ${product.plu}',
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      IconButton(
                        onPressed: saleRequestProvider
                                    .isLoadingSaveSaleRequest ||
                                saleRequestProvider.isLoadingProcessCart
                            ? null
                            : () {
                                ShowAlertDialog.show(
                                  context: context,
                                  title: "Remover item",
                                  content: const SingleChildScrollView(
                                    child: Text(
                                      "Deseja realmente remover o item do carrinho?",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  function: () {
                                    saleRequestProvider.removeProductFromCart(
                                      ProductPackingCode:
                                          product.productPackingCode!,
                                      enterpriseCode: enterpriseCode.toString(),
                                    );

                                    ShowSnackbarMessage.show(
                                      message: "Produto removido",
                                      context: context,
                                      functionSnackBarAction: () {
                                        saleRequestProvider
                                            .restoreProductRemoved(
                                                enterpriseCode.toString());
                                      },
                                      labelSnackBarAction: "Restaurar produto",
                                    );
                                  },
                                );
                              },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
