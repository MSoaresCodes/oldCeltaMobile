import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import '../../../Models/enterprise/enterprise_model.dart';
import '../../../providers/providers.dart';
import '../../../utils/utils.dart';
import '../../../components/components.dart';

class InventoryItems extends StatelessWidget {
  const InventoryItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    InventoryProvider inventoryProvider = Provider.of(context);
    EnterpriseModel arguments =
        ModalRoute.of(context)!.settings.arguments as EnterpriseModel;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: inventoryProvider.inventoryCount,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    APPROUTES.COUNTINGS,
                    arguments: {
                      "codigoInternoInventario": inventoryProvider
                          .inventorys[index].codigoInternoInventario,
                      "enterprise": arguments,
                    },
                  );
                },
                //sem esse Card, não funciona o gesture detector no campo inteiro
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Empresa",
                          subtitle:
                              inventoryProvider.inventorys[index].nomeempresa,
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Tipo de estoque",
                          subtitle: inventoryProvider
                              .inventorys[index].nomeTipoEstoque,
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Responsável",
                          subtitle: inventoryProvider
                              .inventorys[index].nomefuncionario,
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Congelado em",
                          subtitle: DateFormat('dd/MM/yyyy HH:mm').format(
                              inventoryProvider.inventorys[index]
                                  .dataCongelamentoInventario),
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Observações",
                          subtitle: inventoryProvider
                                  .inventorys[index].obsInventario.isEmpty
                              ? 'Não há observações'
                              : inventoryProvider
                                  .inventorys[index].obsInventario,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
