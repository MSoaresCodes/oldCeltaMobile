import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api.dart';
import '../../components/components.dart';
import '../../Models/models.dart';
import '../../providers/providers.dart';
import 'components/components.dart';
import 'sale_request.dart';

class SaleRequestPage extends StatefulWidget {
  const SaleRequestPage({Key? key}) : super(key: key);

  @override
  State<SaleRequestPage> createState() => _SaleRequestPageState();
}

class _SaleRequestPageState extends State<SaleRequestPage> {
  int _selectedIndex = 0;
  final observationsController = TextEditingController();
  final instructionsController = TextEditingController();
  final ipController = TextEditingController();
  final ipFocusNode = FocusNode();

  static const List appBarTitles = [
    "Inserir produtos",
    "cliente",
    "carrinho",
  ];

  void _onItemTapped({
    required int index,
    required SaleRequestProvider saleRequestProvider,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (saleRequestProvider.isLoadingSaveSaleRequest ||
        saleRequestProvider.isLoadingProcessCart) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  dispose() {
    super.dispose();
    observationsController.dispose();
    instructionsController.dispose();
    ipController.dispose();
    ipFocusNode.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        EnterpriseProvider enterpriseProvider =
            Provider.of(context, listen: false);
        SaleRequestProvider saleRequestProvider =
            Provider.of(context, listen: false);
        ipController.text = await PrefsInstance.getString(
          PrefsKeys.ipPrintSaleRequest,
        );
        await cleanSaleRequestBecauseVersionIncompatible();
        await saleRequestProvider.verifyUserCanChangePrices(enterpriseProvider);
        setState(() {});
      }
    });
  }

  Future<void> cleanSaleRequestBecauseVersionIncompatible() async {
    //usado somente a partir da versão 2.5.7 porque mudou a forma como grava os produtos

    bool isClean =
        await PrefsInstance.getBool(prefsKeys: PrefsKeys.cleanSaleRequest);

    if (!isClean) {
      await PrefsInstance.removeKey(PrefsKeys.cart);
      await PrefsInstance.setBool(
          prefsKeys: PrefsKeys.cleanSaleRequest, value: true);
    }
    await restoreSaleRequest();
  }

  Future<void> restoreSaleRequest() async {
    SaleRequestProvider saleRequestProvider = Provider.of(
      context,
      listen: false,
    );

    ConfigurationsProvider configurationsProvider = Provider.of(
      context,
      listen: false,
    );

    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final EnterpriseModel enterprise = arguments["enterprise"];

    await saleRequestProvider.restoreProducts(enterprise.Code.toString());
    await saleRequestProvider.restorecustomers(enterprise.Code.toString());
    await saleRequestProvider.restoreLastSavedSaleRequest();

    int customersCount =
        saleRequestProvider.customersCount(enterprise.Code.toString());
    if (customersCount == 0) {
      //logo que entra na tela de pedido de vendas, o app recupera os clientes
      //que foram pesquisados e marcados. Caso consulte os clientes, vai
      //apagar esses dados, por isso só pode pesquisar automaticamente quando
      //entrar na página de pedido de vendas se não houver clientes
      await saleRequestProvider.getCustomers(
        context: context,
        controllerText: "-1",
        enterpriseCode: enterprise.Code.toString(),
        searchOnlyDefaultCustomer: true,
        configurationsProvider: configurationsProvider,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SaleRequestProvider saleRequestProvider =
        Provider.of(context, listen: true);

    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final EnterpriseModel enterprise = arguments["enterprise"];

    int cartProductsCount =
        saleRequestProvider.cartProductsCount(enterprise.Code.toString());

    List<Widget> _pages = <Widget>[
      InsertProductsPage(
        enterprise: enterprise,
        requestTypeCode: arguments["SaleRequestTypeCode"],
      ),
      InsertCustomerPage(enterpriseCode: enterprise.Code),
      CartDetailsPage(
        enterpriseCode: enterprise.Code,
        requestTypeCode: arguments["SaleRequestTypeCode"],
        keyboardIsOpen: MediaQuery.of(context).viewInsets.bottom == 0,
        observationsController: observationsController,
        instructionsController: instructionsController,
        ipFocusNode: ipFocusNode,
        ipController: ipController,
      ),
    ];
    return Stack(
      children: [
        PopScope(
          onPopInvokedWithResult: (value, __) {
            saleRequestProvider.clearProducts();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: kIsWeb ? false : true,
            appBar: AppBar(
              title: FittedBox(
                child: Text(
                  appBarTitles[_selectedIndex],
                ),
              ),
              actions: [
                if (_selectedIndex == _pages.length - 1)
                  const ClearAllDataButton(),
                if (_selectedIndex < (_pages.length - 1))
                  CartBadge(changeSelectedIndex: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  }),
              ],
            ),
            body: Center(
              child: _pages.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: PersonalizedBottomNavigationBar(
              selectedIndex: _selectedIndex,
              cartProductsCount: cartProductsCount,
              onItemTapped: (index) {
                _onItemTapped(
                  index: index,
                  saleRequestProvider: saleRequestProvider,
                );
              },
            ),
          ),
        ),
        loadingWidget(saleRequestProvider.isLoadingProcessCart),
        loadingWidget(saleRequestProvider.isLoadingSaveSaleRequest),
        loadingWidget(saleRequestProvider.isLoadingCustomer),
        loadingWidget(saleRequestProvider.isLoadingProducts),
        loadingWidget(saleRequestProvider.isPrinting),
      ],
    );
  }
}
