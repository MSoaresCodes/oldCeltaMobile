import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';

class RefreshIconButton extends StatelessWidget {
  const RefreshIconButton({super.key});

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
                },
    );
  }
}
