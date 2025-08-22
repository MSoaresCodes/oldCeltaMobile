import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';

class OrderProducts extends StatefulWidget {
  const OrderProducts({Key? key}) : super(key: key);

  @override
  State<OrderProducts> createState() => _OrderProductsState();
}

class _OrderProductsState extends State<OrderProducts> {
  int? _groupValue = -1;
  bool _expanded = false;

  List<_Item> radios(BuyRequestProvider buyRequestProvider) => [
        _Item(
          name: "Empresas em ordem crescente",
          selected: false,
          sort: () => buyRequestProvider.orderUpByEnterprise(),
        ),
        _Item(
          name: "Empresas em ordem decrescente",
          selected: false,
          sort: () => buyRequestProvider.orderDownByEnterprise(),
        ),
        _Item(
          name: "Nome do produto em ordem crescente",
          selected: false,
          sort: () => buyRequestProvider.orderCartUpByName(),
        ),
        _Item(
          name: "Nome do produto em ordem decrescente",
          selected: false,
          sort: () => buyRequestProvider.orderCartDownByName(),
        ),
        _Item(
          name: "Custo total em ordem crescente",
          selected: false,
          sort: () => buyRequestProvider.orderCartUpByTotalCost(),
        ),
        _Item(
          name: "Custo total em ordem decrescente",
          selected: false,
          sort: () => buyRequestProvider.orderCartDownByTotalCost(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    BuyRequestProvider buyRequestProvider = Provider.of(context);

    var radioList = radios(buyRequestProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                      _expanded ? "Minimizar ordenação" : "Ordenar produtos"),
                ),
                const SizedBox(width: 10),
                Icon(
                  _expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                )
              ],
            ),
          ),
          if (_expanded)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(color: Colors.black26),
            ),
          Visibility(
            visible: _expanded,
            child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: radioList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        radioList[index].selected = !radioList[index].selected;
                        _groupValue = index;
                        radioList[index].sort();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: RadioGroup(
                        groupValue: _groupValue,
                        child: Row(
                          children: [
                            Expanded(child: Text(radioList[index].name)),
                            Radio(value: index),
                          ],
                        ),
                        onChanged: (int? value) {
                          setState(() {
                            radioList[index].selected =
                                !radioList[index].selected;
                            _groupValue = value;
                            radioList[index].sort();
                          });
                        },
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String name;
  bool selected;

  final Function sort;

  _Item({required this.name, required this.selected, required this.sort});
}
