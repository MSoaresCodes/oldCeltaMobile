import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Models/models.dart';
import '../../../../providers/providers.dart';

class SaleTypeRadios extends StatefulWidget {
  final EnterpriseModel enterpriseModel;
  const SaleTypeRadios({
    required this.enterpriseModel,
    super.key,
  });

  @override
  State<SaleTypeRadios> createState() => _SaleTypeRadiosState();
}

class _SaleTypeRadiosState extends State<SaleTypeRadios> {
  int? groupValue;

  @override
  void initState() {
    super.initState();

    AdjustSalePriceProvider adjustSalePriceProvider =
        Provider.of(context, listen: false);

    adjustSalePriceProvider.addUsedSaleTypes(widget.enterpriseModel);

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    AdjustSalePriceProvider adjustSalePriceProvider = Provider.of(context);

    return Column(
      children: [
        const Divider(),
        const Text(
          "Tipo de venda",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: generateRadios(adjustSalePriceProvider),
        )
      ],
    );
  }

  List<Widget> generateRadios(AdjustSalePriceProvider adjustSalePriceProvider) {
    List<Widget> radios = [];

    for (var i = 0; i < adjustSalePriceProvider.saleTypes.length; i++) {
      if (adjustSalePriceProvider.saleTypes.length == 1) {
        groupValue = i;
        adjustSalePriceProvider.updateSelectedSaleType(i);
      }
      radios.add(
        Expanded(
          child: InkWell(
            onTap: () {
              adjustSalePriceProvider.updateSelectedSaleType(i);
              setState(() {
                groupValue = i;
              });
            },
            child: RadioGroup(
              groupValue: groupValue,
              onChanged: (value) {
                adjustSalePriceProvider.updateSelectedSaleType(i);
                setState(() {
                  groupValue = value;
                });
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      adjustSalePriceProvider.saleTypes[i].saleTypeName.name,
                      style: const TextStyle(fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Radio(value: i),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return radios;
  }
}
