import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/models.dart';
import '../../components/components.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import 'transfer_between_stocks.dart';

class TransferBetweenStocksProductsPage extends StatefulWidget {
  final bool isHeaderExpanded;
  final EnterpriseModel enterprise;
  final TextEditingController consultProductController;
  final TextEditingController quantityController;
  final ScrollController scrollController;
  final VoidCallback expandHeader;
  const TransferBetweenStocksProductsPage({
    super.key,
    required this.isHeaderExpanded,
    required this.enterprise,
    required this.consultProductController,
    required this.quantityController,
    required this.scrollController,
    required this.expandHeader,
  });

  @override
  State<TransferBetweenStocksProductsPage> createState() =>
      _TransferBetweenStocksProductsPageState();
}

class _TransferBetweenStocksProductsPageState
    extends State<TransferBetweenStocksProductsPage> {
  final insertQuantityFormKey = GlobalKey<FormState>();
  final quantityFocusNode = FocusNode();
  final searchFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    quantityFocusNode.dispose();
    searchFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transferBetweenStocksProvider =
        Provider.of<TransferBetweenStocksProvider>(context);
    final configurationsProvider = Provider.of<ConfigurationsProvider>(context);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: widget.isHeaderExpanded ? 200.0 : 0.0,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SearchWidget(
                  configurations: [
                    ConfigurationType.autoScan,
                    ConfigurationType.legacyCode,
                    ConfigurationType.personalizedCode,
                  ],
                  searchFocusNode: searchFocusNode,
                  onPressSearch: () async {
                    await transferBetweenStocksProvider.getProducts(
                      enterprise: widget.enterprise,
                      controllerText: widget.consultProductController.text,
                      context: context,
                      configurationsProvider: configurationsProvider,
                      searchFocusNode: quantityFocusNode,
                    );

                    if (transferBetweenStocksProvider.products.length > 0) {
                      widget.consultProductController.clear();
                    }
                  },
                  searchProductController: widget.consultProductController,
                ),
                const Row(
                  children: [
                    Expanded(child: JustificationsAndStocksDropwdownWidget()),
                    RefreshIconButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!transferBetweenStocksProvider.isLoadingProducts)
          Expanded(
            child: ProductsItems(
              scrollController: widget.scrollController,
              enterpriseCode: widget.enterprise.Code,
              searchFocusNode: quantityFocusNode,
              quantityController: widget.quantityController,
              insertQuantityFormKey: insertQuantityFormKey,
              expandHeader: widget.expandHeader,
              getProductsWithCamera: () async {
                FocusScope.of(context).unfocus();
                widget.consultProductController.clear();

                widget.consultProductController.text =
                    await ScanBarCode.scanBarcode(context);

                if (widget.consultProductController.text == "") {
                  return;
                }

                await transferBetweenStocksProvider.getProducts(
                  enterprise: widget.enterprise,
                  controllerText: widget.consultProductController.text,
                  context: context,
                  configurationsProvider: configurationsProvider,
                  searchFocusNode: quantityFocusNode,
                );

                if (transferBetweenStocksProvider.products.length > 0) {
                  widget.consultProductController.clear();
                }
              },
            ),
          ),
      ],
    );
  }
}
