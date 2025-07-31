import 'package:celta_inventario/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/models.dart';
import '../../components/components.dart';
import '../../providers/providers.dart';

class TransferBetweenStocksLotsPage extends StatefulWidget {
  const TransferBetweenStocksLotsPage({super.key});

  @override
  State<TransferBetweenStocksLotsPage> createState() =>
      _TransferBetweenStocksLotsPageState();
}

class _TransferBetweenStocksLotsPageState
    extends State<TransferBetweenStocksLotsPage> {
  final formKey = GlobalKey<FormState>();
  final quantityController = TextEditingController();
  final quantityFocusNode = FocusNode();
  int? selectedIndex;

  Future<void> changeProductQuantity(
      TransferBetweenStocksProvider provider) async {
    if (selectedIndex == null) {
      return;
    }

    bool updated = await provider.changeQuantityInLot(
      selectedIndex!,
      quantityController.text.toDouble(),
    );

    if (updated) {
      quantityController.clear();
      setState(() {
        selectedIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transferBetweenStocksProvider =
        Provider.of<TransferBetweenStocksProvider>(context);
    final theme = Theme.of(context);
    final enterprise =
        ModalRoute.of(context)!.settings.arguments as EnterpriseModel;

    final filteredProducts = transferBetweenStocksProvider.productsLots
        .where((e) => e.enterpriseCode == enterprise.Code)
        .toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text("Adicione produtos no lote"),
      );
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final lot = filteredProducts[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TitleAndSubtitle.titleAndSubtitle(
                  title: "Produto",
                  subtitle: '${lot.product.name} (${lot.product.plu})',
                ),
                TitleAndSubtitle.titleAndSubtitle(
                  title: "Justificativa",
                  subtitle: lot.justification.Descricao_JustMov,
                ),
                TitleAndSubtitle.titleAndSubtitle(
                  title: "De",
                  subtitle: lot.originStock.Nome_TipoEstoque,
                ),
                TitleAndSubtitle.titleAndSubtitle(
                  title: "Para",
                  subtitle: lot.destinyStock.Nome_TipoEstoque,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TitleAndSubtitle.titleAndSubtitle(
                        title: "Qtd",
                        subtitle: lot.quantity.toString().toBrazilianNumber(),
                      ),
                    ),
                    if (selectedIndex == index)
                      Expanded(
                        flex: 7,
                        child: TextFormField(
                          controller: quantityController,
                          focusNode: quantityFocusNode,
                          keyboardType: TextInputType.number,
                          decoration: FormFieldDecoration.decoration(
                            context: context,
                            hintText: "Nova qtd",
                            labelText: "Nova qtd",
                            suffixIcon: IconButton(
                              onPressed: () {
                                changeProductQuantity(
                                  transferBetweenStocksProvider,
                                );
                              },
                              icon: Icon(
                                Icons.save,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          onFieldSubmitted: (_) async {
                            changeProductQuantity(
                              transferBetweenStocksProvider,
                            );
                          },
                        ),
                      ),
                    IconButton(
                      onPressed: () {
                        if (selectedIndex == index) {
                          setState(() {
                            selectedIndex = null;
                          });
                        } else {
                          setState(() {
                            selectedIndex = index;
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              quantityFocusNode.requestFocus();
                              quantityController.clear();
                            });
                          });
                        }
                      },
                      icon: Icon(
                        selectedIndex != index
                            ? Icons.edit
                            : Icons.cancel_sharp,
                        color: selectedIndex != index
                            ? theme.colorScheme.primary
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
