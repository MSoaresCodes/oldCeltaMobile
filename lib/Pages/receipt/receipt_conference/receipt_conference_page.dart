import 'package:flutter/foundation.dart';
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
    ReceiptProvider receiptProvider = Provider.of(context, listen: true);
    ConfigurationsProvider configurationsProvider =
        Provider.of(context, listen: true);
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
            resizeToAvoidBottomInset: kIsWeb ? false : true,
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
            body: Column(
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
                      controllerText: _consultProductController.text,
                      context: context,
                      isSearchAllCountedProducts: false,
                      enterprise: enterprise,
                    );
    
                    //não estava funcionando passar o productsCount como parâmetro
                    //para o "SearchProductWithEanPluOrNameWidget" para apagar o
                    //textEditingController após a consulta dos produtos se encontrar
                    //algum produto
                    if (receiptProvider.productsCount > 0) {
                      //se for maior que 0 significa que deu certo a consulta e
                      //por isso pode apagar o que foi escrito no campo de
                      //consulta
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
                            controllerText: _consultProductController.text,
                            context: context,
                            isSearchAllCountedProducts: false,
                            enterprise: enterprise,
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
                if (MediaQuery.of(context).viewInsets.bottom == 0)
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: ConsultProductWithoutEanButton(
                            docCode: docCode,
                            enterprise: enterprise,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          flex: 4,
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
        loadingWidget(receiptProvider.isLoadingProducts),
        loadingWidget(receiptProvider.isLoadingUpdateQuantity),
      ],
    );
  }
}
