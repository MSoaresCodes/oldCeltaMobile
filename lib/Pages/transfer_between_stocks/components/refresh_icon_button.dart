import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';

class RefreshIconButton extends StatelessWidget {
  final GlobalKey<FormState> keyJustifications;
  final GlobalKey<FormState> keyOriginStockType;
  final GlobalKey<FormState> keyDestinyStockType;

  const RefreshIconButton({
    super.key,
    required this.keyJustifications,
    required this.keyOriginStockType,
    required this.keyDestinyStockType,
  });

  @override
  Widget build(BuildContext context) {
    final transferBetweenStocksProvider =
        Provider.of<TransferBetweenStocksProvider>(context);

    return IconButton(
      icon: Icon(
        Icons.refresh,
        size: 30,
        color:
            transferBetweenStocksProvider.isLoadingTypeStockAndJustifications ||
                    transferBetweenStocksProvider.isLoadingAdjustStock ||
                    transferBetweenStocksProvider.isLoadingProducts
                ? Colors.grey
                : Theme.of(context).colorScheme.primary,
      ),
      tooltip: "Consultar justificativas e estoques",
      onPressed:
          transferBetweenStocksProvider.isLoadingTypeStockAndJustifications ||
                  transferBetweenStocksProvider.isLoadingAdjustStock ||
                  transferBetweenStocksProvider.isLoadingProducts
              ? null
              : () async {
                  await transferBetweenStocksProvider
                      .getStockTypeAndJustifications(context);

                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (keyJustifications.currentState != null &&
                        keyOriginStockType.currentState != null &&
                        keyDestinyStockType.currentState != null) {
                      keyJustifications.currentState!.reset();
                      keyOriginStockType.currentState!.reset();
                      keyDestinyStockType.currentState!.reset();
                    }
                  });
                },
    );
  }
}
