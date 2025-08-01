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
  final ScrollController scrollController;
  final VoidCallback expandHeader;
  final FocusNode searchFocusNode;
  const TransferBetweenStocksProductsPage({
    super.key,
    required this.isHeaderExpanded,
    required this.enterprise,
    required this.scrollController,
    required this.expandHeader,
    required this.searchFocusNode,
  });

  @override
  State<TransferBetweenStocksProductsPage> createState() =>
      _TransferBetweenStocksProductsPageState();
}

class _TransferBetweenStocksProductsPageState
    extends State<TransferBetweenStocksProductsPage> {
  final insertQuantityFormKey = GlobalKey<FormState>();
  final quantityFocusNode = FocusNode();
  final productController = TextEditingController();
  final quantityController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    quantityFocusNode.dispose();
    productController.dispose();
    quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transferBetweenStocksProvider =
        Provider.of<TransferBetweenStocksProvider>(context);
    final configurationsProvider = Provider.of<ConfigurationsProvider>(context);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: widget.isHeaderExpanded ? 200.0 : 0.0,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                SearchWidget(
                  autofocus: false,
                  configurations: [
                    ConfigurationType.autoScan,
                    ConfigurationType.legacyCode,
                    ConfigurationType.personalizedCode,
                  ],
                  searchFocusNode: widget.searchFocusNode,
                  onPressSearch: () async {
                    await transferBetweenStocksProvider.getProducts(
                      enterprise: widget.enterprise,
                      text: productController.text,
                      context: context,
                      configurationsProvider: configurationsProvider,
                      searchFocusNode: quantityFocusNode,
                    );

                    if (transferBetweenStocksProvider.products.length > 0) {
                      productController.clear();
                    }
                  },
                  searchProductController: productController,
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
        if (transferBetweenStocksProvider.errorMessageGetProducts != "" &&
            !transferBetweenStocksProvider.isLoadingProducts)
          Expanded(
            child: Center(
              child: ErrorMessage(
                  errorMessage:
                      transferBetweenStocksProvider.errorMessageGetProducts),
            ),
          ),
        if (!transferBetweenStocksProvider.isLoadingProducts)
          Expanded(
            child: ProductsItems(
              scrollController: widget.scrollController,
              enterpriseCode: widget.enterprise.Code,
              searchFocusNode: quantityFocusNode,
              quantityController: quantityController,
              insertQuantityFormKey: insertQuantityFormKey,
              expandHeader: widget.expandHeader,
              getProductsWithCamera: () async {
                FocusScope.of(context).unfocus();
                productController.clear();

                productController.text = await ScanBarCode.scanBarcode(context);

                if (productController.text == "") {
                  return;
                }

                await transferBetweenStocksProvider.getProducts(
                  enterprise: widget.enterprise,
                  text: productController.text,
                  context: context,
                  configurationsProvider: configurationsProvider,
                  searchFocusNode: quantityFocusNode,
                );

                if (transferBetweenStocksProvider.products.length > 0) {
                  productController.clear();
                }
              },
            ),
          ),
      ],
    );
  }
}
