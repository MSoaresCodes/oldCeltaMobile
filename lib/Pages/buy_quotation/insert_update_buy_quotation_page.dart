import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../Models/models.dart';
import '../../providers/providers.dart';
import 'buy_quotation.dart';

class InsertUpdateBuyQuotationPage extends StatefulWidget {
  const InsertUpdateBuyQuotationPage({super.key});

  @override
  State<InsertUpdateBuyQuotationPage> createState() =>
      _InsertUpdateBuyQuotationPageState();
}

class _InsertUpdateBuyQuotationPageState
    extends State<InsertUpdateBuyQuotationPage> {
  final observationsController = TextEditingController();
  final searchProductController = TextEditingController();
  final observationsFocusNode = FocusNode();
  final searchFocusNode = FocusNode();
  List<Map<int, TextEditingController>> controllers = [];
  List<Map<int, FocusNode>> focusNodes = [];
  int? selectedProductIndex;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        // {
        //     "enterprise": enterprise,
        //     "incompleteQuotation": incompleteQuotation,
        //   }
        EnterpriseProvider enterpriseProvider =
            Provider.of(context, listen: false);
        BuyQuotationProvider buyQuotationProvider =
            Provider.of(context, listen: false);

        await loadCompleteBuyQuotation();

        Map? arguments = ModalRoute.of(context)?.settings.arguments as Map?;
        bool isInserting = arguments?["isInserting"];

        buyQuotationProvider.updateSelectedsValues(
          enterpriseProvider: enterpriseProvider,
          isInserting: isInserting,
        );

        observationsController.text =
            buyQuotationProvider.selectedBuyQuotation?.Observations ?? "";

        createControllersAndFocusNode(buyQuotationProvider);
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    observationsController.dispose();
    searchProductController.dispose();
    observationsFocusNode.dispose();
    searchFocusNode.dispose();
    disposeControllersAndFocusNodes();
  }

  void updateSelectedProductIndex({
    required int index,
    required BuyQuotationProvider buyQuotationProvider,
  }) {
    if (selectedProductIndex == index) {
      setState(() {
        selectedProductIndex = null;
      });
    } else {
      setState(() {
        selectedProductIndex = index;
        updateControllersQuantity(
          productIndex: index,
          buyQuotationProvider: buyQuotationProvider,
          controllers: controllers,
        );
      });
    }
  }

  void createControllersAndFocusNode(
      BuyQuotationProvider buyQuotationProvider) {
    if (buyQuotationProvider.allEnterprises.isEmpty == true) {
      return;
    } else {
      controllers = buyQuotationProvider.allEnterprises
          .map((e) => {e.Code: TextEditingController()})
          .toList();
      focusNodes = buyQuotationProvider.allEnterprises
          .map((e) => {e.Code: FocusNode()})
          .toList();
    }
  }

  void disposeControllersAndFocusNodes() {
    for (var controller in controllers) {
      controller.values.first.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.values.first.dispose();
    }
  }

  Future<void> loadCompleteBuyQuotation() async {
    Map? arguments = ModalRoute.of(context)?.settings.arguments as Map?;

    EnterpriseModel? enterprise = arguments?["enterprise"];
    bool isInserting = arguments?["isInserting"];

    BuyQuotationProvider buyQuotationProvider =
        Provider.of(context, listen: false);

    await buyQuotationProvider.getBuyers(context: context);

    if (enterprise == null) {
      return;
    }

    if (!isInserting) {
      await buyQuotationProvider.getBuyQuotation(
        context: context,
        valueToSearch:
            buyQuotationProvider.selectedBuyQuotation?.Code.toString() ?? "",
        searchByPersonalizedCode: false,
        enterpriseCode: enterprise.Code,
        complete: isInserting ? false : true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    BuyQuotationProvider buyQuotationProvider = Provider.of(context);
    Map? arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    EnterpriseModel? enterprise = arguments?["enterprise"];
    bool isInserting = arguments?["isInserting"];

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            //TODO use sliverappbar to be better see the top
            leading: IconButton(
              onPressed: () {
                ShowAlertDialog.show(
                    context: context,
                    title: "Deseja realmente sair?",
                    content: const Text(
                      "Se alguma alteração não foi salva, ela será perdida se você sair da tela",
                    ),
                    function: () {
                      Navigator.of(context).pop();
                    });
              },
              icon: const Icon(
                Icons.arrow_back,
              ),
            ),
            title: Text(isInserting ? "Inserindo" : "Alterando"),
            actions: [
              SaveButton(
                isInserting: isInserting,
                observationsController: observationsController,
                enterpriseModel: enterprise,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomScrollView(
              slivers: [
                if (buyQuotationProvider.errorMessage != "")
                  SliverToBoxAdapter(
                    child: TextButton(
                      onPressed: () async {
                        await loadCompleteBuyQuotation();
                      },
                      child: const Text("Pesquisar novamente"),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SimpleInformations(
                    isInserting: isInserting,
                    observationsController: observationsController,
                    observationsFocusNode: observationsFocusNode,
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                const SliverToBoxAdapter(child: Enterprises()),
                const SliverToBoxAdapter(child: Divider()),
                if (enterprise != null) ...[
                  SliverToBoxAdapter(
                    child: Text("Produtos" +
                        " (${buyQuotationProvider.productsWithNewValues.length})"),
                  ),
                  SliverToBoxAdapter(
                    child: SearchProducts(
                      searchProductController: searchProductController,
                      enterprise: enterprise,
                      searchFocusNode: searchFocusNode,
                      cleanSelectedIndex: () {
                        setState(() {
                          selectedProductIndex = null;
                        });
                      },
                    ),
                  ),
                  if (buyQuotationProvider.productsWithNewValues.length == 0)
                    const SliverToBoxAdapter(
                        child: Text("Não há produtos na cotação")),
                  //TODO add option to filter already added products when has more than 10 products
                  InsertUpdateProductsItems(
                    enterprise: enterprise,
                    controllers: controllers,
                    focusNodes: focusNodes,
                    selectedProductIndex: selectedProductIndex,
                    updateSelectedProductIndex: (index) {
                      updateSelectedProductIndex(
                        index: index,
                        buyQuotationProvider: buyQuotationProvider,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        loadingWidget(buyQuotationProvider.isLoading),
      ],
    );
  }
}
