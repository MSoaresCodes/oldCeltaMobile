import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../providers/providers.dart';
import 'customer_register.dart';

class CustomerRegisterPage extends StatefulWidget {
  const CustomerRegisterPage({Key? key}) : super(key: key);

  @override
  State<CustomerRegisterPage> createState() => _CustomerRegisterPageState();
}

class _CustomerRegisterPageState extends State<CustomerRegisterPage> {
  final emailController = TextEditingController();
  final telephoneController = TextEditingController();
  final dddController = TextEditingController();
  final nameController = TextEditingController();
  final reducedNameController = TextEditingController();
  final cpfCnpjController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final registrationNumberController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  final passwordController = TextEditingController();

  final cpfCnpjFocusNode = FocusNode();

  int _selectedIndex = 0;
  ValueNotifier<String?> selectedSexDropDown = ValueNotifier<String?>(null);
  final personFormKey = GlobalKey<FormState>();

  static const List appBarTitles = [
    "Dados pessoais",
    "Endereços",
    "E-mails",
    "Telefones",
    "Convênios",
    "Confirmação de dados",
  ];

  @override
  dispose() {
    super.dispose();

    emailController.dispose();
    telephoneController.dispose();
    dddController.dispose();
    nameController.dispose();
    reducedNameController.dispose();
    cpfCnpjController.dispose();
    dateOfBirthController.dispose();
    registrationNumberController.dispose();
    passwordConfirmationController.dispose();
    passwordController.dispose();

    cpfCnpjFocusNode.dispose();
  }

  bool cpfCnpjIsValid = false;
  void changeCpfCnpj(
    String value,
    CustomerRegisterProvider customerRegisterProvider,
  ) async {
    if (FormFieldValidations.cpfOrCnpj(value) == null) {
      cpfCnpjFocusNode.unfocus();

      await customerRegisterProvider.getCustomer(cpfCnpjController.text);

      final customer = customerRegisterProvider.customer;

      selectedSexDropDown.value = customer?.SexType == null
          ? null
          : customer!.SexType == "M"
              ? "Masculino"
              : "Feminino";
      nameController.text = customer?.Name ?? "";
      reducedNameController.text = customer?.ReducedName ?? "";
      dateOfBirthController.text = customer?.DateOfBirth != null
          ? DateFormat("dd/MM/yyyy")
              .format(DateTime.parse(customer!.DateOfBirth!))
          : customer?.DateOfBirth ?? "";
      registrationNumberController.text = customer?.RegistrationNumber ?? "";
      setState(() {
        cpfCnpjIsValid = true;
      });
    } else {
      setState(() {
        cpfCnpjIsValid = false;
      });
    }
  }

  void updateSelectedIndex({
    required int index,
    required CustomerRegisterProvider customerRegisterProvider,
  }) {
    if (_selectedIndex == 0) {
      final cpfCnpj = cpfCnpjController.text;
      final name = nameController.text;

      if (personFormKey.currentState?.validate() != true) {
        return;
      }

      customerRegisterProvider.changePersonalData(
        cpfCnpj: cpfCnpj.isNotEmpty ? cpfCnpj : null,
        name: name.isNotEmpty ? name : null,
        sexType: selectedSexDropDown.value,
        birthDate: dateOfBirthController.text.isEmpty
            ? null
            : DateFormat("dd/MM/yyyy").parse(dateOfBirthController.text),
        password: passwordController.text,
        reducedName: reducedNameController.text,
        registrationNumber: registrationNumberController.text,
      );
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void clearAllData(CustomerRegisterProvider customerRegisterProvider) {
    cpfCnpjController.clear();
    nameController.clear();
    reducedNameController.clear();
    dateOfBirthController.clear();
    passwordController.clear();
    passwordConfirmationController.clear();
    registrationNumberController.clear();
    setState(() {
      cpfCnpjIsValid = false;
    });
    customerRegisterProvider.clearCustomer();
  }

  @override
  Widget build(BuildContext context) {
    CustomerRegisterProvider customerRegisterProvider = Provider.of(context);
    AddressProvider addressProvider = Provider.of(context);

    List<Widget> _pages = <Widget>[
      CustomerRegisterPersonalDataPage(
        personFormKey: personFormKey,
        changeSexDropDown: (value) {
          selectedSexDropDown.value = value;
        },
        selectedSexDropDown: selectedSexDropDown,
        cpfCnpjFocusNode: cpfCnpjFocusNode,
        changeCpfCnpj: (value) {
          changeCpfCnpj(value, customerRegisterProvider);
        },
        cpfCnpjIsValid: cpfCnpjIsValid,
        cpfCnpjController: cpfCnpjController,
        nameController: nameController,
        passwordConfirmationController: passwordConfirmationController,
        passwordController: passwordController,
        reducedNameController: reducedNameController,
        dateOfBirthController: dateOfBirthController,
        registrationNumberController: registrationNumberController,
      ),
      AddressComponent(
        canInsertMoreThanOneAddress: true,
        addresses: customerRegisterProvider.customer?.Addresses ?? [],
        addAddress: customerRegisterProvider.addAddress,
        removeAddress: customerRegisterProvider.removeAddress,
      ),
      CustomerRegisterEmailPage(emailController: emailController),
      CustomerRegisterTelephonePage(
        areaCodeController: dddController,
        phoneNumberController: telephoneController,
      ),
      const CustomerRegisterCovenantsPage(),
      CustomerRegisterAddPage(
        selectedSex: selectedSexDropDown.value,
        nameController: nameController,
        cpfCnpjController: cpfCnpjController,
        reducedNameController: reducedNameController,
        dateOfBirthController: dateOfBirthController,
      ),
    ];

    return PopScope(
      canPop: customerRegisterProvider.customer == null,
      onPopInvokedWithResult: (didPop, result) {
        if (customerRegisterProvider.customer != null) {
          ShowAlertDialog.show(
              context: context,
              title: "Sair",
              content: Text(
                "Deseja realmente sair? Todas alterações realizadas serão perdidas",
              ),
              function: () {
                customerRegisterProvider.clearCustomer();
                Navigator.of(context).pop();
              });
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(
                appBarTitles[_selectedIndex],
              ),
            ),
            bottomNavigationBar: CustomerRegisterBottomNavigationItems(
              updateSelectedIndex: (index) {
                updateSelectedIndex(
                  index: index,
                  customerRegisterProvider: customerRegisterProvider,
                );
              },
              selectedIndex: _selectedIndex,
            ),
            body: _pages.elementAt(_selectedIndex),
            floatingActionButton: _selectedIndex == 5
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomerRegisterClearAllData(
                        clearAllData: () {
                          clearAllData(customerRegisterProvider);
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                      ),
                      CustomerRegisterFloatingActionButton(
                        passwordController: passwordController,
                        clearControllersInSuccess: () {
                          clearAllData(customerRegisterProvider);
                        },
                        updateSelectedIndex: (index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                      )
                    ],
                  )
                : null,
          ),
          loadingWidget(addressProvider.isLoading),
          loadingWidget(customerRegisterProvider.isLoading),
        ],
      ),
    );
  }
}
