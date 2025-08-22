import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../Models/models.dart';
import '../../../providers/providers.dart';

class Suplliers extends StatefulWidget {
  const Suplliers({Key? key}) : super(key: key);

  @override
  State<Suplliers> createState() => _SuplliersState();
}

class _SuplliersState extends State<Suplliers> {
  TextEditingController searchValueController = TextEditingController();
  FocusNode focusNodeConsultProduct = FocusNode();
  int _groupValue = -1;

  void updateSelectedSupplier({
    required int? value,
    required BuyRequestProvider buyRequestProvider,
    required SupplierModel supplier,
  }) {
    if (buyRequestProvider.selectedSupplier != null &&
        (buyRequestProvider.enterprisesCount > 0 ||
            buyRequestProvider.productsInCartCount > 0)) {
      ShowAlertDialog.show(
        context: context,
        title: "Alterar fornecedor",
        content: const SingleChildScrollView(
          child: Text(
            "Se você alterar o fornecedor, todas empresas e produtos serão removidos do pedido de compras.\n\nDeseja realmente alterar o fornecedor?",
            textAlign: TextAlign.center,
          ),
        ),
        function: () {
          setState(() {
            _groupValue = value!;
          });
          buyRequestProvider.selectedSupplier = supplier;
        },
      );
    } else {
      setState(() {
        _groupValue = value!;
      });
      buyRequestProvider.selectedSupplier = supplier;
    }
  }

  Future<void> getSuppliers(BuyRequestProvider buyRequestProvider) async {
    _groupValue = -1;
    await buyRequestProvider.getSuppliers(
      context: context,
      searchValue: searchValueController.text,
    );
    if (buyRequestProvider.suppliersCount > 0) {
      searchValueController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    BuyRequestProvider buyRequestProvider = Provider.of(context);
    _groupValue = buyRequestProvider.suppliers.indexWhere((element) =>
        element.CnpjCpfNumber ==
        buyRequestProvider.selectedSupplier?.CnpjCpfNumber);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchWidget(
          showConfigurationsIcon: false,
          hintText: "Fornecedor",
          labelText: "Consultar fornecedor",
          useCamera: false,
          autofocus: false,
          configurations: [],
          searchProductController: searchValueController,
          onPressSearch: () async {
            if (buyRequestProvider.enterprisesCount > 0) {
              ShowAlertDialog.show(
                context: context,
                title: "Pesquisar fornecedores",
                content: const SingleChildScrollView(
                  child: Text(
                    "Se você consultar os fornecedores novamente, todas empresas e produtos serão removidos.\n\nDeseja realmente pesquisar novamente?",
                    textAlign: TextAlign.center,
                  ),
                ),
                function: () async {
                  await getSuppliers(buyRequestProvider);
                },
              );
            } else {
              await getSuppliers(buyRequestProvider);
            }
          },
          searchFocusNode: focusNodeConsultProduct,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: buyRequestProvider.suppliersCount,
          itemBuilder: (context, index) {
            SupplierModel supplier = buyRequestProvider.suppliers[index];

            return InkWell(
              onTap: () {
                updateSelectedSupplier(
                  value: index,
                  buyRequestProvider: buyRequestProvider,
                  supplier: supplier,
                );
              },
              child: Card(
                child: RadioGroup(
                  groupValue: _groupValue,
                  onChanged: (int? value) {
                    updateSelectedSupplier(
                      value: value,
                      buyRequestProvider: buyRequestProvider,
                      supplier: supplier,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Código",
                          subtitle: supplier.Code.toString(),
                          otherWidget: Radio(value: index),
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Nome",
                          subtitle: supplier.Name,
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Nome fantasia",
                          subtitle: supplier.FantasizesName,
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "CPF/CNPJ",
                          subtitle: supplier.CnpjCpfNumber,
                        ),
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Tipo de comércio",
                          subtitle: supplier.SupplierType,
                        ),
                        if (supplier.Addresses != null)
                          Text(supplier.Addresses.toString()),
                        if (supplier.Telephones != null)
                          Text(supplier.Telephones.toString()),
                        if (supplier.Emails != null)
                          Text(supplier.Emails.toString()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (buyRequestProvider.isLoadingSupplier)
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    Text(
                      "Consultando fornecedores",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        if (buyRequestProvider.errorMessageSupplier != "")
          ErrorMessage(errorMessage: buyRequestProvider.errorMessageSupplier),
      ],
    );
  }
}
