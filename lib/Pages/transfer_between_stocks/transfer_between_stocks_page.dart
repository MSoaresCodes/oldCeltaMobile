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
  late PageController _pageController;
  final _scrollController = ScrollController();
  final _searchFocusNode = FocusNode();
  int pageIndex = 0;
  bool _isHeaderExpanded = true;
  double _scrollAnchor = 0.0;
  ScrollDirection _lastScrollDirection = ScrollDirection.idle;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await Provider.of<TransferBetweenStocksProvider>(context, listen: false)
            .restoreProductsLots();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final currentDirection = _scrollController.position.userScrollDirection;

    // If the scroll direction changes, we set a new anchor point.
    // This is the "start interaction position" you wanted.
    if (currentDirection != _lastScrollDirection) {
      _scrollAnchor = currentOffset;
    }

    // Logic to HIDE the header (when scrolling DOWN)
    if (currentDirection == ScrollDirection.reverse && _isHeaderExpanded) {
      // Hide only if we've scrolled down > 30px from our anchor.
      if ((currentOffset - _scrollAnchor).abs() > 100) {
        if (mounted) {
          setState(() => _isHeaderExpanded = false);
          _searchFocusNode.unfocus();
        }
      }
    }
    // Logic to SHOW the header (when scrolling UP)
    else if (currentDirection == ScrollDirection.forward &&
        !_isHeaderExpanded) {
      // Show if we've scrolled up > 100px from our anchor, OR are near the top.
      if ((_scrollAnchor - currentOffset).abs() > 100 || currentOffset <= 100) {
        if (mounted) {
          setState(() => _isHeaderExpanded = true);
        }
      }
    }

    // Update the last known direction for the next scroll event.
    if (mounted) {
      _lastScrollDirection = currentDirection;
    }
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    TransferBetweenStocksProvider transferBetweenStocksProvider =
        Provider.of(context);
    final enterprise =
        ModalRoute.of(context)!.settings.arguments as EnterpriseModel;

    return PopScope(
      canPop: !transferBetweenStocksProvider.isLoadingAdjustStock &&
          !transferBetweenStocksProvider.isLoadingProducts &&
          !transferBetweenStocksProvider.isLoadingTypeStockAndJustifications,
      onPopInvokedWithResult: (value, __) {
        if (value == true) {
          transferBetweenStocksProvider.clearAllData();
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
            body: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: <Widget>[
                TransferBetweenStocksProductsPage(
                  enterprise: enterprise,
                  searchFocusNode: _searchFocusNode,
                  isHeaderExpanded: _isHeaderExpanded,
                  scrollController: _scrollController,
                  expandHeader: () {
                    setState(() {
                      _isHeaderExpanded = true;
                    });
                  },
                ),
                const TransferBetweenStocksLotsPage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: pageIndex,
              onTap: _onItemTapped,
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
                          child: FittedBox(
                            child: Text(
                              transferBetweenStocksProvider.productsLots
                                  .where((e) =>
                                      e.enterpriseCode == enterprise.Code)
                                  .length
                                  .toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
