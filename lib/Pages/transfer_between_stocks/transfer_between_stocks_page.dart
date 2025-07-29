import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../Models/models.dart';
import '../../components/components.dart';
import '../../providers/providers.dart';
import '../../utils/utils.dart';
import 'components/components.dart';

class TransferBetweenStockPage extends StatefulWidget {
  const TransferBetweenStockPage({super.key});

  @override
  State<TransferBetweenStockPage> createState() =>
      _TransferBetweenStockPageState();
}

class _TransferBetweenStockPageState extends State<TransferBetweenStockPage> {
  final _scrollController = ScrollController();
  final _consultProductController = TextEditingController();
  final _consultedProductController = TextEditingController();

  final _insertQuantityFormKey = GlobalKey<FormState>();
  final _dropDownFormKey = GlobalKey<FormState>();
  final _keyJustifications = GlobalKey<FormState>();
  final _keyOriginStockType = GlobalKey<FormState>();
  final _keyDestinyStockType = GlobalKey<FormState>();

  bool _isHeaderExpanded = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isHeaderExpanded) {
        setState(() {
          _isHeaderExpanded = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isHeaderExpanded) {
        setState(() {
          _isHeaderExpanded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context, listen: true);
    ConfigurationsProvider configurationsProvider =
        Provider.of(context, listen: true);
    final enterprise =
        ModalRoute.of(context)!.settings.arguments as EnterpriseModel;

    return PopScope(
      canPop: !transferBetweenStocksProvider.isLoadingAdjustStock &&
          !transferBetweenStocksProvider.isLoadingProducts &&
          !transferBetweenStocksProvider.isLoadingTypeStockAndJustifications,
      onPopInvokedWithResult: (value, __) {
        if (value == true) {
          transferBetweenStocksProvider
              .clearProductsJustificationsStockTypesAndJsonAdjustStock();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: kIsWeb ? false : true,
        appBar: AppBar(
          title: const FittedBox(
            child: Text(
              'TRANSFERÊNCIA ENTRE ESTOQUES',
            ),
          ),
        ),
        body: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isHeaderExpanded ? 240.0 : 0.0,
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
                          controllerText: _consultProductController.text,
                          context: context,
                          configurationsProvider: configurationsProvider,
                        );

                        if (transferBetweenStocksProvider.productsCount > 0) {
                          _consultProductController.clear();
                        }
                      },
                      searchProductController: _consultProductController,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: JustificationsAndStocksDropwdownWidget(
                            dropDownFormKey: _dropDownFormKey,
                            keyJustifications: _keyJustifications,
                            keyOriginStockType: _keyOriginStockType,
                            keyDestinyStockType: _keyDestinyStockType,
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
                  scrollController: _scrollController,
                  enterpriseCode: enterprise.Code,
                  consultedProductController: _consultedProductController,
                  dropDownFormKey: _dropDownFormKey,
                  insertQuantityFormKey: _insertQuantityFormKey,
                  getProductsWithCamera: () async {
                    FocusScope.of(context).unfocus();
                    _consultProductController.clear();

                    _consultProductController.text =
                        await ScanBarCode.scanBarcode(context);

                    if (_consultProductController.text == "") {
                      return;
                    }

                    await transferBetweenStocksProvider.getProducts(
                      enterprise: enterprise,
                      controllerText: _consultProductController.text,
                      context: context,
                      configurationsProvider: configurationsProvider,
                    );

                    if (transferBetweenStocksProvider.productsCount > 0) {
                      _consultProductController.clear();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
