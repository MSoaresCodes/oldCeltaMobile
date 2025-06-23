import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';
import '../../../components/components.dart';

class CustomerRegisterFloatingActionButton extends StatefulWidget {
  final void Function(int index) updateSelectedIndex;
  final TextEditingController passwordController;
  final void Function() clearControllersInSuccess;

  const CustomerRegisterFloatingActionButton({
    required this.updateSelectedIndex,
    required this.passwordController,
    required this.clearControllersInSuccess,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomerRegisterFloatingActionButton> createState() =>
      _CustomerRegisterFloatingActionButtonState();
}

class _CustomerRegisterFloatingActionButtonState
    extends State<CustomerRegisterFloatingActionButton> {
  String buttonText(CustomerRegisterProvider customerRegisterProvider) {
    final name = customerRegisterProvider.customer?.Name;
    final cpfCnpj = customerRegisterProvider.customer?.CpfCnpjNumber;
    if (name == null || name.isEmpty || cpfCnpj == null || cpfCnpj.isEmpty) {
      return "Adicione\ndados\npessoais";
    } else {
      return "SALVAR";
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomerRegisterProvider customerRegisterProvider = Provider.of(context);
    AddressProvider addressProvider = Provider.of(context);

    return InkWell(
      onTap: () async {
        final customer = customerRegisterProvider.customer;
        if (customer?.Name == null ||
            customer?.CpfCnpjNumber?.isEmpty == true) {
          setState(() {
            widget.updateSelectedIndex(0);
          });
        } else {
          ShowAlertDialog.show(
            context: context,
            title: "Cadastrar cliente",
            content: const SingleChildScrollView(
              child: Text(
                "Deseja confirmar o cadastro do cliente?",
                textAlign: TextAlign.center,
              ),
            ),
            function: () async {
              await customerRegisterProvider.insertCustomer(
                addressProvider: addressProvider,
                password: widget.passwordController.text,
              );

              if (customerRegisterProvider.errorMessage == "") {
                setState(() {
                  widget.updateSelectedIndex(0);
                });

                widget.clearControllersInSuccess();

                ShowSnackbarMessage.show(
                  message: "Cliente inserido/atualizado com sucesso",
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  context: context,
                );
              } else {
                ShowSnackbarMessage.show(
                  message: customerRegisterProvider.errorMessage,
                  context: context,
                );
              }
            },
          );
        }
      },
      child: CircleAvatar(
        minRadius: 35,
        maxRadius: 35,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  buttonText(customerRegisterProvider),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if ((customerRegisterProvider.customer?.Addresses?.length ??
                        0) >
                    0)
                  const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 50,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
