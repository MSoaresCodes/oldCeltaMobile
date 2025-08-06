import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../Models/configurations/configurations.dart';
import '../../../Models/enterprise/enterprise.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';
import './components/components.dart';

class ReceiptConferencePage extends StatefulWidget {
  const ReceiptConferencePage({
    Key? key,
  }) : super(key: key);

  @override
  State<ReceiptConferencePage> createState() => _ReceiptConferencePageState();
}

class _ReceiptConferencePageState extends State<ReceiptConferencePage> {
  TextEditingController _consultProductController = TextEditingController();
  TextEditingController _consultedProductController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _consultProductController.dispose();
    _consultedProductController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ReceiptProvider receiptProvider = Provider.of(context);
    ConfigurationsProvider configurationsProvider = Provider.of(context);
    EnterpriseProvider enterpriseProvider = Provider.of(context);
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    int docCode = arguments["grDocCode"];
    final EnterpriseModel enterprise = arguments["enterprise"];

    return Stack(
      children: [
        PopScope(
          canPop: !receiptProvider.isLoadingUpdateQuantity &&
              !receiptProvider.isLoadingProducts,
          onPopInvokedWithResult: (value, __) {
            if (value == true) {
              receiptProvider.clearProducts();
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: FittedBox(
                child: Text(
                  '[${arguments["numeroProcRecebDoc"]}] ${arguments["emitterName"]}',
                  style: const TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SearchWidget(
                    configurations: [
                      ConfigurationType.autoScan,
                      ConfigurationType.legacyCode,
                      ConfigurationType.personalizedCode,
                    ],
                    searchFocusNode: receiptProvider.consultProductFocusNode,
                    onPressSearch: () async {
                      await receiptProvider.getProducts(
                        configurationsProvider: configurationsProvider,
                        docCode: docCode,
                        searchValue: _consultProductController.text,
                        context: context,
                        isSearchAllCountedProducts: false,
                        getWeighableProducts: false,
                        enterprise: enterprise,
                      );

                      if (receiptProvider.productsCount > 0) {
                        _consultProductController.clear();
                      }
                    },
                    searchProductController: _consultProductController,
                  ),
                  if (receiptProvider.errorMessageGetProducts != "" &&
                      receiptProvider.productsCount == 0)
                    Expanded(
                      child: Center(
                        child: ErrorMessage(
                          errorMessage: receiptProvider.errorMessageGetProducts,
                        ),
                      ),
                    ),
                  if (receiptProvider.errorMessageGetProducts == "")
                    Expanded(
                      child: ConferenceProductsItems(
                        getProductsWithCamera: () async {
                          FocusScope.of(context).unfocus();
                          _consultProductController.clear();

                          _consultProductController.text =
                              await ScanBarCode.scanBarcode(context);

                          if (_consultProductController.text != "") {
                            await receiptProvider.getProducts(
                              configurationsProvider: configurationsProvider,
                              docCode: docCode,
                              searchValue: _consultProductController.text,
                              context: context,
                              isSearchAllCountedProducts: false,
                              enterprise: enterprise,
                              getWeighableProducts: false,
                            );
                          }

                          if (receiptProvider.productsCount > 0) {
                            _consultProductController.clear();
                          }
                        },
                        docCode: docCode,
                        consultedProductController: _consultedProductController,
                        consultProductController: _consultProductController,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        if (enterpriseProvider.bsDate
                                ?.isAfter(DateTime(2025, 8, 1)) ==
                            true)
                          Expanded(
                            flex: 30,
                            child: WighableProductsButton(
                              docCode: docCode,
                              enterprise: enterprise,
                            ),
                          ),
                        Expanded(
                          flex: 30,
                          child: ConsultProductWithoutEanButton(
                            docCode: docCode,
                            enterprise: enterprise,
                          ),
                        ),
                        Expanded(
                          flex: 40,
                          child: ProductsWithoutCadasterButton(
                            docCode: docCode,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        loadingWidget(receiptProvider.isLoadingProducts),
        loadingWidget(receiptProvider.isLoadingUpdateQuantity),
      ],
    );
  }
}
