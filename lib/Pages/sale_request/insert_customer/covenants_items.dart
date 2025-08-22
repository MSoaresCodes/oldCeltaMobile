import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';

class CovenantsItems extends StatefulWidget {
  final List<CustomerCovenantModel> covenants;
  final int indexOfCustomer;
  final String enterpriseCode;
  const CovenantsItems({
    required this.covenants,
    required this.indexOfCustomer,
    required this.enterpriseCode,
    Key? key,
  }) : super(key: key);

  @override
  State<CovenantsItems> createState() => _CovenantsItemsState();
}

class _CovenantsItemsState extends State<CovenantsItems> {
  // bool updatedCovenantInFirstLoadPage =
  //     false; //variável usada para não ficar atualizando direto no itembuilder da lista
  @override
  Widget build(BuildContext context) {
    SaleRequestProvider saleRequestProvider =
        Provider.of(context, listen: true);
    int? _selectedIndex = saleRequestProvider.indexOfSelectedCovenant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Divider(
            height: 4,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        FittedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.covenants.length == 0
                  ? "Não há convênios para esse cliente"
                  : "Convênios",
              style: TextStyle(
                fontFamily: "BebasNeue",
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: widget.covenants.length == 0
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                fontSize: 25,
              ),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.covenants.length,
          itemBuilder: (context, index) {
            // if (widget.covenants[index].selected &&
            //     !updatedCovenantInFirstLoadPage) {
            //   saleRequestProvider.updateSelectedCovenant(
            //     enterpriseCode: widget.enterpriseCode,
            //     indexOfCustomer: widget.indexOfCustomer,
            //     indexOfCovenants: index,
            //     isSelected: widget.covenants[index].selected,
            //   );
            //   updatedCovenantInFirstLoadPage = true;
            // }

            return GestureDetector(
              onTap: () {
                saleRequestProvider.updateSelectedCovenant(
                  enterpriseCode: widget.enterpriseCode,
                  indexOfCustomer: widget.indexOfCustomer,
                  indexOfCovenants: index,
                  isSelected: !widget.covenants[index].isSelected,
                );
                setState(() {});
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    color: _selectedIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black12,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 0,
                color: const Color.fromARGB(255, 242, 241, 241),
                child: ListTile(
                  title: Text(
                    widget.covenants[index].covenant?.Name ?? "",
                    style: TextStyle(
                        color: _selectedIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  leading: RadioGroup(
                    groupValue: _selectedIndex,
                    child: Radio(value: index),
                    onChanged: (int? value) {
                      saleRequestProvider.updateSelectedCovenant(
                        enterpriseCode: widget.enterpriseCode,
                        indexOfCustomer: widget.indexOfCustomer,
                        indexOfCovenants: index,
                        isSelected: !widget.covenants[index].isSelected,
                      );
                      setState(() {});
                    },
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
