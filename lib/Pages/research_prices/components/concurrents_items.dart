import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../Models/research_prices/research_prices.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';

class ConcurrentsItems extends StatefulWidget {
  const ConcurrentsItems({Key? key}) : super(key: key);

  @override
  State<ConcurrentsItems> createState() => _ConcurrentsItemsState();
}

class _ConcurrentsItemsState extends State<ConcurrentsItems> {
  int selectedIndex = -1;

  String addressString(ResearchPricesConcurrentsModel concurrent) {
    String value =
        "${concurrent.Address?.Address}, ${concurrent.Address?.District}, ${concurrent.Address?.City}, ${concurrent.Address?.Number}. \nCEP: ${concurrent.Address?.Zip}";
    if (concurrent.Address?.Complement?.isEmpty == false) {
      value += "\nComplemento: ${concurrent.Address!.Complement!}";
    }
    if (concurrent.Address?.Reference?.isEmpty == false) {
      value += "\nReferência: ${concurrent.Address!.Reference!}";
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    ResearchPricesProvider researchPricesProvider =
        Provider.of(context, listen: true);

    Map? arguments = ModalRoute.of(context)!.settings.arguments as Map?;

    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: researchPricesProvider.concurrentsCount,
          itemBuilder: (context, index) {
            ResearchPricesConcurrentsModel concurrent =
                researchPricesProvider.concurrents[index];

            return Container(
              child: GestureDetector(
                onTap: () async {
                  researchPricesProvider.updateSelectedConcurrent(concurrent);
                  await researchPricesProvider
                      .associateConcurrentToResearchPrice(
                    context: context,
                    enterpriseCode: arguments?["enterpriseCode"],
                  );

                  if (researchPricesProvider
                          .errorAssociateConcurrentToResearch ==
                      "") {
                    ShowSnackbarMessage.show(
                      message: "O concorrente está associado à pesquisa",
                      context: context,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      secondsDuration: 1,
                    );
                    Navigator.of(context)
                        .pushNamed(APPROUTES.RESEARCH_PRICES_INSERT_PRICE);
                  } else {
                    ShowSnackbarMessage.show(
                      message: researchPricesProvider
                          .errorAssociateConcurrentToResearch,
                      context: context,
                    );
                  }
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TitleAndSubtitle.titleAndSubtitle(
                        //   title: "Código da pesquisa",
                        //   value: concurrent.ResearchOfPriceCode.toString(),
                        // ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Código",
                          subtitle: concurrent.ConcurrentCode.toString(),
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          subtitle: researchPricesProvider
                                  .selectedResearch!.Concurrents
                                  .any((e) =>
                                      e.ConcurrentCode ==
                                      concurrent.ConcurrentCode)
                              ? "Associado à pesquisa"
                              : "Não associado à pesquisa",
                          subtitleColor: researchPricesProvider
                                  .selectedResearch!.Concurrents
                                  .contains(concurrent)
                              ? Theme.of(context).colorScheme.primary
                              : Colors.red,
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Nome",
                          subtitle: concurrent.Name?.isEmpty == false
                              ? concurrent.Name
                              : "Não há",
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Observação",
                          subtitle: concurrent.Observation?.isNotEmpty == true
                              ? concurrent.Observation
                              : "Não há",
                        ),

                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Endereços",
                          subtitle: concurrent.Address?.Zip?.isEmpty == true
                              ? "Nenhum informado"
                              : addressString(concurrent),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            researchPricesProvider
                                .updateSelectedConcurrent(concurrent);
                            Navigator.of(context).pushNamed(
                              APPROUTES
                                  .RESERACH_PRICES_INSERT_UPDATE_CONCORRENT,
                              arguments: {
                                "enterpriseCode": arguments?["enterpriseCode"]
                              },
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: Text(
                            "Alterar concorrente",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
