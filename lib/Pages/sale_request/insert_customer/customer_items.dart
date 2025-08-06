import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';
import '../../../components/components.dart';
import 'insert_customer.dart';

class CustomersItems extends StatefulWidget {
  final int enterpriseCode;
  const CustomersItems({required this.enterpriseCode, super.key});

  @override
  State<CustomersItems> createState() => _CustomersItemsState();
}

class _CustomersItemsState extends State<CustomersItems> {
  @override
  Widget build(BuildContext context) {
    SaleRequestProvider saleRequestProvider = Provider.of(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: saleRequestProvider
          .customers[widget.enterpriseCode.toString()]?.length,
      itemBuilder: (context, index) {
        CustomerModel? customer = saleRequestProvider
            .customers[widget.enterpriseCode.toString()]![index];

        final allowRequest = customer.saleBlockadeModel?.AllowSaleRequest ??
            true; //if the bs is not enabled, must not treat this value. This is why I am returning true as default

        final tooltipKey = GlobalKey<TooltipState>();
        if (customer.Code == 1) {
          return Card(
            child: CheckboxListTile(
                activeColor: Theme.of(context).colorScheme.primary,
                title: const Text("Cliente consumidor"),
                value: customer.selected,
                onChanged: saleRequestProvider.isLoadingCustomer
                    ? null
                    : (bool? value) {
                        setState(() {
                          saleRequestProvider.updateSelectedCustomer(
                            index: index,
                            value: value!,
                            enterpriseCode: widget.enterpriseCode.toString(),
                          );
                        });
                      }),
          );
        }

        return Card(
          child: Column(
            children: [
              CheckboxListTile(
                enabled: allowRequest,
                value: customer.selected,
                visualDensity: VisualDensity.compact,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: saleRequestProvider.isLoadingCustomer
                    ? null
                    : (value) {
                        setState(() {
                          saleRequestProvider.updateSelectedCustomer(
                            index: index,
                            value: value!,
                            enterpriseCode: widget.enterpriseCode.toString(),
                          );
                        });
                      },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Código",
                      subtitle: customer.Code.toString(),
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Nome",
                      subtitle: customer.Name.toString(),
                    ),
                    if (customer.ReducedName != "")
                      TitleAndSubtitle.titleAndSubtitle(
                        title: "Nome reduzido",
                        subtitle: customer.ReducedName.toString(),
                      ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "CPF/CNPJ",
                      subtitle: customer.CpfCnpjNumber,
                    ),
                    TitleAndSubtitle.titleAndSubtitle(
                      title: "Código personalizado",
                      subtitle: customer.PersonalizedCode.toString(),
                    ),
                    if (!allowRequest)
                      Tooltip(
                          showDuration: const Duration(seconds: 3),
                          key: tooltipKey,
                          message:
                              '''Instrução: ${customer.saleBlockadeInstructionModel?.Description}
Descrição: ${customer.saleBlockadeModel?.Description}''',
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            icon: const Icon(Icons.info),
                            label: const Text("Cliente bloqueado"),
                            onPressed: () {
                              tooltipKey.currentState?.ensureTooltipVisible();
                              Future.delayed(const Duration(seconds: 3), () {
                                tooltipKey.currentState?.setState(() {});
                              });
                            },
                          ))
                  ],
                ),
              ),
              if (customer.selected == true &&
                  customer.CustomerCovenants != null)
                CovenantsItems(
                  covenants: customer.CustomerCovenants ?? [],
                  indexOfCustomer: index,
                  enterpriseCode: widget.enterpriseCode.toString(),
                ),
            ],
          ),
        );
      },
    );
  }
}
