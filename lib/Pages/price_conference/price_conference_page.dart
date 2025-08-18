import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './components/components.dart';
import '../../components/components.dart';
import '../../Models/models.dart';
import '../../providers/providers.dart';

class PriceConferencePage extends StatefulWidget {
  const PriceConferencePage({Key? key}) : super(key: key);

  @override
  State<PriceConferencePage> createState() => _PriceConferencePageState();
}

class _PriceConferencePageState extends State<PriceConferencePage> {
  final TextEditingController _consultProductController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _consultProductController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PriceConferenceProvider priceConferenceProvider =
        Provider.of(context, listen: true);
    ConfigurationsProvider configurationsProvider =
        Provider.of(context, listen: true);
    EnterpriseModel enterprise =
        ModalRoute.of(context)!.settings.arguments as EnterpriseModel;

    return PopScope(
      canPop: !priceConferenceProvider.isLoading &&
          !priceConferenceProvider.isSendingToPrint,
      onPopInvokedWithResult: (value, __) async {
        if (value == true) {
          priceConferenceProvider.clearProducts();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text(
                'CONSULTA DE PREÇOS',
              ),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SearchWidget(
                  configurations: [
                    ConfigurationType.legacyCode,
                    ConfigurationType.personalizedCode,
                  ],
                  searchFocusNode:
                      priceConferenceProvider.consultProductFocusNode,
                  onPressSearch: () async {
                    await priceConferenceProvider.getProduct(
                      configurationsProvider: configurationsProvider,
                      enterprise: enterprise,
                      controllerText: _consultProductController.text,
                      context: context,
                    );

                    //não estava funcionando passar o productsCount como parâmetro
                    //para o "SearchProductWithEanPluOrNameWidget" para apagar o
                    //textEditingController após a consulta dos produtos se encontrar
                    //algum produto
                    if (priceConferenceProvider.productsCount > 0) {
                      //se for maior que 0 significa que deu certo a consulta e
                      //por isso pode apagar o que foi escrito no campo de
                      //consulta
                      _consultProductController.clear();
                    }
                  },
                  searchProductController: _consultProductController,
                ),
                if (priceConferenceProvider.errorMessage != "" &&
                    priceConferenceProvider.productsCount == 0)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ErrorMessage(
                          errorMessage: priceConferenceProvider.errorMessage),
                    ),
                  ),
                if (!priceConferenceProvider.isLoading &&
                    priceConferenceProvider.products.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: priceConferenceProvider.products.length,
                      itemBuilder: (context, index) {
                        final product = priceConferenceProvider.products[index];

                        return ProductItem(
                          enterpriseCode: enterprise.Code,
                          product: priceConferenceProvider.products[index],
                          showCosts: true,
                          showLastBuyEntrance: true,
                          componentAfterProductInformations: SendToPrintButton(
                            internalEnterpriseCode: enterprise.Code,
                            index: index,
                            productPackingCode: product.productPackingCode!,
                            etiquetaPendente: product.pendantPrintLabel == true,
                          ),
                        );
                      },
                    ),
                  ),
                if (MediaQuery.of(context).viewInsets.bottom == 0 &&
                    priceConferenceProvider.productsCount > 1)
                  //só mostra a opção de organizar se houver mais de um produto e se o teclado estiver fechado
                  PriceConferenceOrderProductsButtons(
                      priceConferenceProvider: priceConferenceProvider)
              ],
            ),
          ),
          loadingWidget(priceConferenceProvider.isLoading),
          loadingWidget(priceConferenceProvider.isSendingToPrint),
        ],
      ),
    );
  }
}
