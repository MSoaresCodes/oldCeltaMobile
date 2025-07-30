import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/models.dart';
import '../../components/components.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import 'transfer_between_stocks.dart';

class TransferBetweenStocksProductsPage extends StatelessWidget {
  final bool isHeaderExpanded;
  final EnterpriseModel enterprise;
  final TextEditingController consultProductController;
  final TextEditingController consultedProductController;
  final ScrollController scrollController;
  final VoidCallback expandHeader;
  const TransferBetweenStocksProductsPage({
    super.key,
    required this.isHeaderExpanded,
    required this.enterprise,
    required this.consultProductController,
    required this.consultedProductController,
    required this.scrollController,
    required this.expandHeader,
  });

  static final _insertQuantityFormKey = GlobalKey<FormState>();
  static final _dropDownFormKey = GlobalKey<FormState>();
  static final _keyJustifications = GlobalKey<FormState>();
  static final _keyOriginStockType = GlobalKey<FormState>();
  static final _keyDestinyStockType = GlobalKey<FormState>();

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
          height: isHeaderExpanded ? 240.0 : 0.0,
          // color: Colors.lightBlue[100],
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
                  searchFocusNode:
                      transferBetweenStocksProvider.consultProductFocusNode,
                  onPressSearch: () async {
                    await transferBetweenStocksProvider.getProducts(
                      enterprise: enterprise,
                      controllerText: consultProductController.text,
                      context: context,
                      configurationsProvider: configurationsProvider,
                    );

                    if (transferBetweenStocksProvider.products.length > 0) {
                      consultProductController.clear();
                    }
                  },
                  searchProductController: consultProductController,
                ),
                Row(
                  children: [
                    Expanded(
                      child: JustificationsAndStocksDropwdownWidget(
                        dropDownFormKey: _dropDownFormKey,
                      ),
                    ),
                    RefreshIconButton(
                      keyJustifications: _keyJustifications,
                      keyOriginStockType: _keyOriginStockType,
                      keyDestinyStockType: _keyDestinyStockType,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!transferBetweenStocksProvider.isLoadingProducts)
          Expanded(
            child: ProductsItems(
              scrollController: scrollController,
              enterpriseCode: enterprise.Code,
              consultedProductController: consultedProductController,
              dropDownFormKey: _dropDownFormKey,
              insertQuantityFormKey: _insertQuantityFormKey,
              expandHeader: expandHeader,
              getProductsWithCamera: () async {
                FocusScope.of(context).unfocus();
                consultProductController.clear();

                consultProductController.text =
                    await ScanBarCode.scanBarcode(context);

                if (consultProductController.text == "") {
                  return;
                }

                await transferBetweenStocksProvider.getProducts(
                  enterprise: enterprise,
                  controllerText: consultProductController.text,
                  context: context,
                  configurationsProvider: configurationsProvider,
                );

                if (transferBetweenStocksProvider.products.length > 0) {
                  consultProductController.clear();
                }
              },
            ),
          ),
      ],
    );
  }
}
