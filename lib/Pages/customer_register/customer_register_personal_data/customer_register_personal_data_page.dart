import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/providers.dart';
import 'customer_register_personal_data.dart';

class CustomerRegisterPersonalDataPage extends StatefulWidget {
  final TextEditingController cpfCnpjController;
  final TextEditingController nameController;
  final TextEditingController passwordConfirmationController;
  final TextEditingController passwordController;
  final TextEditingController reducedNameController;
  final TextEditingController dateOfBirthController;
  final TextEditingController registrationNumberController;
  final void Function(String) changeCpfCnpj;
  final bool cpfCnpjIsValid;
  final FocusNode cpfCnpjFocusNode;
  final ValueNotifier<String?> selectedSexDropDown;
  final void Function(String?) changeSexDropDown;
  final GlobalKey<FormState> personFormKey;
  const CustomerRegisterPersonalDataPage({
    required this.cpfCnpjController,
    required this.nameController,
    required this.passwordConfirmationController,
    required this.passwordController,
    required this.reducedNameController,
    required this.dateOfBirthController,
    required this.registrationNumberController,
    required this.changeCpfCnpj,
    required this.cpfCnpjIsValid,
    required this.cpfCnpjFocusNode,
    required this.selectedSexDropDown,
    required this.changeSexDropDown,
    required this.personFormKey,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomerRegisterPersonalDataPage> createState() =>
      _CustomerRegisterPersonalDataPageState();
}

class _CustomerRegisterPersonalDataPageState
    extends State<CustomerRegisterPersonalDataPage> {
  final nameFocusNode = FocusNode();
  final reducedNameFocusNode = FocusNode();
  final sexTypeFocusNode = FocusNode();
  final dateOfBirthFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final passwordConfirmationFocusNode = FocusNode();
  final registrationNumberFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    nameFocusNode.dispose();
    reducedNameFocusNode.dispose();
    sexTypeFocusNode.dispose();
    dateOfBirthFocusNode.dispose();
    passwordFocusNode.dispose();
    passwordConfirmationFocusNode.dispose();
    registrationNumberFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EnterpriseProvider enterpriseProvider = Provider.of(context, listen: false);

    return SingleChildScrollView(
      primary: false,
      child: Form(
        key: widget.personFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CpfOrCnpjField(
              cpfCnpjFocusNode: widget.cpfCnpjFocusNode,
              nameFocusNode: nameFocusNode,
              changeCpfCnpj: widget.changeCpfCnpj,
              cpfCnpjController: widget.cpfCnpjController,
            ),
            Visibility(
              visible: widget.cpfCnpjIsValid,
              child: Column(
                children: [
                  if (widget.cpfCnpjController.text.length == 14 &&
                      enterpriseProvider.bsDate
                              ?.isAfter(DateTime(2025, 06, 27)) ==
                          true)
                    RegistrationNumberField(
                      nameFocusNode: nameFocusNode,
                      registrationNumberFocusNode: registrationNumberFocusNode,
                      validateFormKey:
                          widget.personFormKey.currentState?.validate,
                      registrationNumberController:
                          widget.registrationNumberController,
                    ),
                  NameField(
                    nameFocusNode: nameFocusNode,
                    reducedNameFocusNode: reducedNameFocusNode,
                    validateFormKey:
                        widget.personFormKey.currentState?.validate,
                    nameController: widget.nameController,
                  ),
                  ReducedNameField(
                    reducedNameFocusNode: reducedNameFocusNode,
                    cpfCnpjIsValid: widget.cpfCnpjIsValid,
                    dateOfBirthFocusNode: dateOfBirthFocusNode,
                    validateFormKey:
                        widget.personFormKey.currentState?.validate,
                    reducedNameController: widget.reducedNameController,
                  ),
                  BirthField(
                    cpfCnpjIsValid: widget.cpfCnpjIsValid,
                    dateOfBirthFocusNode: dateOfBirthFocusNode,
                    passwordFocusNode: passwordFocusNode,
                    validateFormKey:
                        widget.personFormKey.currentState?.validate,
                    dateOfBirthController: widget.dateOfBirthController,
                  ),
                  Password(
                    cpfCnpjIsValid: widget.cpfCnpjIsValid,
                    passwordFocusNode: passwordFocusNode,
                    passwordConfirmationFocusNode:
                        passwordConfirmationFocusNode,
                    validateFormKey:
                        widget.personFormKey.currentState?.validate,
                    passwordConfirmationController:
                        widget.passwordConfirmationController,
                    passwordController: widget.passwordController,
                    sexTypeFocusNode: sexTypeFocusNode,
                  ),
                  if (widget.cpfCnpjController.text.length == 11)
                    SexType(
                      cpfCnpjIsValid: widget.cpfCnpjIsValid,
                      selectedSexDropDown: widget.selectedSexDropDown,
                      sexTypeFocusNode: sexTypeFocusNode,
                      validateFormKey:
                          widget.personFormKey.currentState?.validate,
                      changeSexDropDown: widget.changeSexDropDown,
                    ),
                  ClearData(
                    clearControllers: widget.cpfCnpjIsValid == true
                        ? () {
                            widget.cpfCnpjController.clear();
                            widget.nameController.clear();
                            widget.reducedNameController.clear();
                            widget.dateOfBirthController.clear();
                            widget.passwordController.clear();
                            widget.passwordConfirmationController.clear();
                            widget.registrationNumberController.clear();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
