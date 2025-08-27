import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';
import '../buy_quotation.dart';

class BuyQuotationsItems extends StatelessWidget {
  final EnterpriseModel enterprise;
  const BuyQuotationsItems({
    required this.enterprise,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BuyQuotationProvider buyQuotationProvider = Provider.of(context);

    if (buyQuotationProvider.buyQuotations.isEmpty) {
      return SliverToBoxAdapter(
        child: TextButton.icon(
          onPressed: () async {
            await buyQuotationProvider.getBuyQuotation(
              context: context,
              valueToSearch: "%",
              searchByPersonalizedCode: true,
              enterpriseCode: enterprise.Code,
              searchAll: true,
            );
          },
          label: const Text(
            "Consultar todas cotações",
          ),
          icon: const Icon(Icons.replay),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: buyQuotationProvider.buyQuotations.length,
        (context, index) {
          final buyQuotation = buyQuotationProvider.buyQuotations[index];

          return InkWell(
            onTap: () {
              buyQuotationProvider.updateSelectedBuyQuotation(buyQuotation);
              Navigator.of(context).pushNamed(
                APPROUTES.BUY_QUOTATION_INSERT_UPDATE,
                arguments: {
                  "enterprise": enterprise,
                  "isInserting": false,
                },
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Code",
                      subtitle: buyQuotation?.Code.toString(),
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Data de criação",
                      subtitle: dateFormatted(buyQuotation?.DateOfCreation),
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: dateFormatted(buyQuotation?.DateOfLimit) == null
                          ? null
                          : "Data de limite",
                      subtitle: dateFormatted(buyQuotation?.DateOfLimit) == null
                          ? "Sem data de limite"
                          : dateFormatted(buyQuotation?.DateOfLimit),
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Código personalizado",
                      subtitle: buyQuotation?.PersonalizedCode,
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: buyQuotation?.Observations?.isEmpty == true
                          ? null
                          : "Observações",
                      subtitle: buyQuotation?.Observations?.isEmpty == true
                          ? "Sem observações"
                          : buyQuotation?.Observations,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    // return SliverList(
    //   shrinkWrap: true,
    //   itemCount: buyQuotationProvider.buyQuotations.length,
    //   itemBuilder: (context, index) {
    //     final buyQuotation = buyQuotationProvider.buyQuotations[index];

    //     return InkWell(
    //       onTap: () {
    //         buyQuotationProvider.updateSelectedBuyQuotation(buyQuotation);
    //         Navigator.of(context).pushNamed(
    //           APPROUTES.BUY_QUOTATION_INSERT_UPDATE,
    //           arguments: {
    //             "enterprise": enterprise,
    //             "isInserting": false,
    //           },
    //         );
    //       },
    //       child: Card(
    //         child: Padding(
    //           padding: const EdgeInsets.all(8),
    //           child: Column(
    //             children: [
    //               TitleAndSubtitle.titleAndSubtitle(
    //                 title: "Code",
    //                 subtitle: buyQuotation?.Code.toString(),
    //               ),
    //               TitleAndSubtitle.titleAndSubtitle(
    //                 title: "Data de criação",
    //                 subtitle: dateFormatted(buyQuotation?.DateOfCreation),
    //               ),
    //               TitleAndSubtitle.titleAndSubtitle(
    //                 title: dateFormatted(buyQuotation?.DateOfLimit) == null
    //                     ? null
    //                     : "Data de limite",
    //                 subtitle: dateFormatted(buyQuotation?.DateOfLimit) == null
    //                     ? "Sem data de limite"
    //                     : dateFormatted(buyQuotation?.DateOfLimit),
    //               ),
    //               TitleAndSubtitle.titleAndSubtitle(
    //                 title: "Código personalizado",
    //                 subtitle: buyQuotation?.PersonalizedCode,
    //               ),
    //               TitleAndSubtitle.titleAndSubtitle(
    //                 title: buyQuotation?.Observations?.isEmpty == true
    //                     ? null
    //                     : "Observações",
    //                 subtitle: buyQuotation?.Observations?.isEmpty == true
    //                     ? "Sem observações"
    //                     : buyQuotation?.Observations,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}
