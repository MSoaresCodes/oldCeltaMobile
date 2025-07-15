import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../components/components.dart';
import '../../../../Models/models.dart';
import '../../../../providers/providers.dart';
import '../../../../utils/utils.dart';
import '../../components/components.dart';

class SubEnterprisesItems extends StatelessWidget {
  const SubEnterprisesItems({super.key});

  void goToAddOrEditSubEnterprisePage({
    required SubEnterpriseModel? selectedSubEnterprise,
    required BuildContext context,
    required bool updatingAllSubenterprises,
  }) {
    Navigator.of(context).pushNamed(
      APPROUTES.ADD_UPDATE_SUB_ENTERPRISE,
      arguments: {
        "selectedSubEnterprise": selectedSubEnterprise,
        "updatingAllSubenterprises": updatingAllSubenterprises,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WebProvider webProvider = Provider.of(context);

    return Column(
      children: [
        const Divider(),
        const Row(
          children: [
            Expanded(
              child: Text(
                "CNPJs",
                style: TextStyle(
                  fontFamily: "BebasNeue",
                  fontSize: 30,
                ),
              ),
            ),
            AddEnterpriseButton(isAddingNewCnpj: true),
          ],
        ),
        if (webProvider.isGeneratingVersionToAdministration &&
            webProvider.enterprises.isNotEmpty &&
            webProvider.indexOfSelectedEnterprise != -1 &&
            webProvider.enterprises[webProvider.indexOfSelectedEnterprise]
                    .subEnterprises?.length !=
                null &&
            webProvider.enterprises[webProvider.indexOfSelectedEnterprise]
                    .subEnterprises!.length >
                1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: TextButton(
              onPressed: () {
                goToAddOrEditSubEnterprisePage(
                  selectedSubEnterprise: null,
                  context: context,
                  updatingAllSubenterprises: true,
                );
              },
              child: const Text(
                "Deixar módulos iguais em todos CNPJs",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (webProvider.indexOfSelectedEnterprise != -1)
          ListView.builder(
            itemCount: webProvider
                    .enterprises[webProvider.indexOfSelectedEnterprise]
                    .subEnterprises
                    ?.length ??
                0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = webProvider
                  .enterprises[webProvider.indexOfSelectedEnterprise]
                  .subEnterprises?[index];

              return InkWell(
                onTap: () {
                  goToAddOrEditSubEnterprisePage(
                    selectedSubEnterprise: item,
                    context: context,
                    updatingAllSubenterprises: false,
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Apelido: ${item?.surname}"),
                            Text("Cnpj: ${item?.cnpj}"),
                            Wrap(
                              children: Modules.values.map(
                                (e) {
                                  final equalModule = item?.modules
                                      ?.where((itemModule) =>
                                          itemModule.module == e.name)
                                      .toList();

                                  final color = equalModule?.isEmpty == true ||
                                          equalModule?.first.enabled == false
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary;

                                  return Text(
                                    e.description + "; ",
                                    style: TextStyle(color: color),
                                  );
                                },
                              ).toList(),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () async {
                                ShowAlertDialog.show(
                                    context: context,
                                    title: "Remover CNPJ?",
                                    function: () async {
                                      await webProvider
                                          .removeSubEnterprise(index);
                                    });
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                goToAddOrEditSubEnterprisePage(
                                  selectedSubEnterprise: item,
                                  context: context,
                                  updatingAllSubenterprises: false,
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
