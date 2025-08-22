import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/providers.dart';

class PriceTypeRadios extends StatefulWidget {
  const PriceTypeRadios({super.key});

  @override
  State<PriceTypeRadios> createState() => _PriceTypeRadiosState();
}

class _PriceTypeRadiosState extends State<PriceTypeRadios> {
  int? groupValue;

  @override
  Widget build(BuildContext context) {
    AdjustSalePriceProvider adjustSalePriceProvider = Provider.of(context);

    return Column(
      children: [
        const Divider(),
        const Text(
          "Tipo de preço",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: generateRadios(adjustSalePriceProvider),
        ),
      ],
    );
  }

  List<Widget> generateRadios(AdjustSalePriceProvider adjustSalePriceProvider) {
    List<Widget> radios = [];

    for (var i = 0; i < adjustSalePriceProvider.priceTypes.length; i++) {
      radios.add(
        Expanded(
          child: InkWell(
            onTap: () {
              adjustSalePriceProvider.updateSelectedPriceType(i);
              setState(() {
                groupValue = i;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RadioGroup(
                  groupValue: groupValue,
                  onChanged: (value) {
                    adjustSalePriceProvider.updateSelectedPriceType(i);
                    setState(() {
                      groupValue = value;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        adjustSalePriceProvider
                            .priceTypes[i].priceTypeName.name,
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                      Radio(value: i),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return radios;
  }
}
