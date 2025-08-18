import 'package:flutter/material.dart';

import '../../../Models/models.dart';
import '../../../utils/utils.dart';
import '../../components.dart';

class Costs extends StatelessWidget implements MoreInformationWidget {
  @override
  MoreInformationType get type => MoreInformationType.costs;
  @override
  String get moreInformationName => "Custos";

  final GetProductJsonModel product;
  const Costs({
    required this.product,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Text(
            "CUSTOS",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TitleAndSubtitle.titleAndSubtitle(
          subtitle: ConvertString.convertToBRL(
            product.fiscalCost ?? 0,
          ),
          title: "Fiscal",
        ),
        TitleAndSubtitle.titleAndSubtitle(
          subtitle: ConvertString.convertToBRL(
            product.fiscalLiquidCost ?? 0,
          ),
          title: "Fiscal líquido",
        ),
        TitleAndSubtitle.titleAndSubtitle(
          subtitle: ConvertString.convertToBRL(
            product.liquidCost ?? 0,
          ),
          title: "Líquido",
        ),
        TitleAndSubtitle.titleAndSubtitle(
          subtitle: ConvertString.convertToBRL(
            product.liquidCostMidle ?? 0,
          ),
          title: "Líquido médio",
        ),
        TitleAndSubtitle.titleAndSubtitle(
          subtitle: ConvertString.convertToBRL(
            product.operationalCost ?? 0,
          ),
          title: "Operacional",
        ),
        TitleAndSubtitle.titleAndSubtitle(
          subtitle: ConvertString.convertToBRL(
            product.realCost ?? 0,
          ),
          title: "Real",
        ),
        TitleAndSubtitle.titleAndSubtitle(
          subtitle: ConvertString.convertToBRL(
            product.realLiquidCost ?? 0,
          ),
          title: "Real líquido",
        ),
        TitleAndSubtitle.titleAndSubtitle(
          subtitle: ConvertString.convertToBRL(
            product.replacementCost ?? 0,
          ),
          title: "Reposição",
        ),
        TitleAndSubtitle.titleAndSubtitle(
          subtitle: ConvertString.convertToBRL(
            product.replacementCostMidle ?? 0,
          ),
          title: "Reposição médio",
        ),
      ],
    );
  }
}
