import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Models/models.dart';
import '../../../utils/utils.dart';
import '../../components.dart';

class LastBuyEntrance extends StatelessWidget implements MoreInformationWidget {
  @override
  MoreInformationType get type => MoreInformationType.lastBuyEntrance;
  @override
  String get moreInformationName => "Compras";

  final GetProductJsonModel product;
  const LastBuyEntrance({
    required this.product,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "ÚLTIMAS COMPRAS",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (product.lastBuyEntrance == null)
          const Text("Não há compras para esse produto"),
        if (product.lastBuyEntrance != null)
          Builder(builder: (context) {
            product.lastBuyEntrance!
                .sort((a, b) => b.entranceDate!.compareTo(a.entranceDate!));
            return Expanded(
              child: ListView.builder(
                itemCount: product.lastBuyEntrance!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final entrance = product.lastBuyEntrance![index];

                  return Column(
                    children: [
                      TitleAndSubtitle.titleAndSubtitle(
                        title: "Número",
                        subtitle: entrance.number,
                      ),
                      TitleAndSubtitle.titleAndSubtitle(
                        title: "Data",
                        subtitle: DateFormat('dd/MM/yyyy HH:mm')
                            .format(DateTime.parse(
                          entrance.entranceDate!,
                        )),
                      ),
                      TitleAndSubtitle.titleAndSubtitle(
                        title: "Fornecedor",
                        subtitle: entrance.supplier,
                      ),
                      TitleAndSubtitle.titleAndSubtitle(
                        title: "Quantitade",
                        subtitle:
                            entrance.quantity.toString().toBrazilianNumber(),
                      ),
                      if (entrance.Packing != null)
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Embalagem",
                          subtitle: entrance.Packing,
                        ),
                      if (entrance.fiscalCode != null &&
                          entrance.fiscalCode!.isNotEmpty)
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "CFOP",
                          subtitle: entrance.fiscalCode,
                        ),
                      if (index < product.lastBuyEntrance!.length - 1)
                        const Divider(),
                    ],
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}
