import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../Models/models.dart';
import '../../components/components.dart';
import '../../providers/providers.dart';
import 'transfer_between_stocks.dart';

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
  int pageIndex = 0;

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
    final enterprise =
        ModalRoute.of(context)!.settings.arguments as EnterpriseModel;

    final pages = [
      TransferBetweenStocksProductsPage(
        enterprise: enterprise,
        isHeaderExpanded: _isHeaderExpanded,
        consultProductController: _consultProductController,
        consultedProductController: _consultedProductController,
        scrollController: _scrollController,
      ),
      const Center(child: Text("Lote")),
    ];

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
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: kIsWeb ? false : true,
            appBar: AppBar(
              title: const FittedBox(
                child: Text(
                  'TRANSFERÊNCIA ENTRE ESTOQUES',
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: pageIndex,
              onTap: (index) {
                setState(() {
                  pageIndex = index;
                });
              },
              selectedIconTheme: const IconThemeData(size: 35),
              items: [
                const BottomNavigationBarItem(
                  label: 'Produtos',
                  icon: Icon(Icons.list),
                ),
                BottomNavigationBarItem(
                  label: 'Lote',
                  icon: Stack(
                    children: [
                      const Icon(Icons.shopping_cart_rounded),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          minRadius: pageIndex == 1 ? 8 : 6,
                          maxRadius: pageIndex == 1 ? 8 : 6,
                          child: const FittedBox(
                            child: Text(
                              "99", //TODO fix this
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: pages[pageIndex],
          ),
          loadingWidget(transferBetweenStocksProvider.isLoadingAdjustStock ||
              transferBetweenStocksProvider.isLoadingProducts ||
              transferBetweenStocksProvider
                  .isLoadingTypeStockAndJustifications),
        ],
      ),
    );
  }
}
