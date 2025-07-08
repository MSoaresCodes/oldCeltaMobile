import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/components.dart';
import '../../../../Models/models.dart';
import '../../../../providers/providers.dart';

class ProductInformationAndRemoveIcon extends StatelessWidget {
  final GetProductJsonModel product;
  final TransferRequestEnterpriseModel originEnterprise;
  final TransferRequestEnterpriseModel destinyEnterprise;
  final TransferRequestModel selectedTransferRequestModel;
  final int index;
  const ProductInformationAndRemoveIcon({
    required this.product,
    required this.index,
    required this.originEnterprise,
    required this.destinyEnterprise,
    required this.selectedTransferRequestModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TransferRequestProvider transferRequestProvider =
        Provider.of(context, listen: false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            minRadius: 10,
            maxRadius: 10,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  (index + 1).toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleAndSubtitle.titleAndSubtitle(
                subtitle: "${product.name} (${product.packingQuantity})",
              ),
              TitleAndSubtitle.titleAndSubtitle(
                subtitle: "PLU: " + product.plu.toString(),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            ShowAlertDialog.show(
                context: context,
                title: "Remover produto?",
                function: () async {
                  await transferRequestProvider.removeProductFromCart(
                    enterpriseOriginCode: originEnterprise.Code.toString(),
                    enterpriseDestinyCode: destinyEnterprise.Code.toString(),
                    requestTypeCode:
                        selectedTransferRequestModel.Code.toString(),
                    ProductPackingCode: product.productPackingCode,
                  );
                });
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
