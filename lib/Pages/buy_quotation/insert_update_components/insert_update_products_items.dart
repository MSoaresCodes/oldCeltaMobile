import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';
import '../buy_quotation.dart';

class InsertUpdateProductsItems extends StatefulWidget {
  final EnterpriseModel enterprise;
  final List<Map<int, TextEditingController>> controllers;
  final List<Map<int, FocusNode>> focusNodes;
  final int? selectedProductIndex;
  final void Function(int index) updateSelectedProductIndex;
  const InsertUpdateProductsItems({
    required this.enterprise,
    required this.controllers,
    required this.focusNodes,
    required this.selectedProductIndex,
    required this.updateSelectedProductIndex,
    super.key,
  });

  @override
  State<InsertUpdateProductsItems> createState() =>
      _InsertUpdateProductsItemsState();
}

class _InsertUpdateProductsItemsState extends State<InsertUpdateProductsItems> {
  final searchProductController = TextEditingController();
  final searchFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    searchProductController.dispose();
    searchFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BuyQuotationProvider buyQuotationProvider = Provider.of(context);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: buyQuotationProvider.productsWithNewValues.length,
        (context, index) {
          final product = buyQuotationProvider.productsWithNewValues[index];

          return InsertUpdateProductItem(
            productIndex: index,
            selectedProductIndex: widget.selectedProductIndex,
            updateSelectedIndex: buyQuotationProvider.allEnterprises
                    .where((e) => e.isSelected)
                    .isEmpty
                ? null
                : () {
                    widget.updateSelectedProductIndex(index);
                    widget.focusNodes[0].values.first.requestFocus();
                  },
            product: product,
            controllers: widget.controllers,
            focusNodes: widget.focusNodes,
          );
        },
      ),
    );
  }
}

void updateControllersQuantity({
  required int productIndex,
  required BuyQuotationProvider buyQuotationProvider,
  required List<Map<int, TextEditingController>> controllers,
}) {
  if (buyQuotationProvider
          .productsWithNewValues[productIndex].ProductEnterprises ==
      null) {
    return;
  }

  for (var x = 0; x < buyQuotationProvider.allEnterprises.length; x++) {
    //a quantidade de controllers é criado de acordo com a quantidade de empresas selecionadas
    final enterprise = buyQuotationProvider.allEnterprises[x];

    final productQuantity = buyQuotationProvider
        .productsWithNewValues[productIndex].ProductEnterprises!
        .where((e) => e.EnterpriseCode == enterprise.Code)
        .first
        .Quantity;

    if (productQuantity != null) {
      final index =
          controllers.indexWhere((e) => e.keys.first == enterprise.Code);

      if (index == -1) {
        continue;
      } else if (productQuantity == 0) {
        controllers[index].values.first.text = "";
      } else {
        controllers[index].values.first.text = productQuantity
            .toString()
            .toBrazilianNumber(3)
            .replaceAll(RegExp(r'\.'), '');
      }
    } else {
      controllers
          .where((e) => e.keys.first == enterprise.Code)
          .first
          .values
          .first
          .text = "";
    }
  }
}
