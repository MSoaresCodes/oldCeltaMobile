import 'dart:convert';
import '../Models/models.dart';
import '../components/components.dart';
import '../providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/api.dart';
import '../utils/utils.dart';
import './address_provider.dart';

class CustomerRegisterProvider with ChangeNotifier {
  CustomerModel? _customer;
  CustomerModel? get customer => _customer;

  CustomerRegisterCovenantModel? _selectedCovenant;
  CustomerRegisterCovenantModel? get selectedCovenant => _selectedCovenant;
  List<CustomerRegisterCovenantModel> _covenants = [];
  List<CustomerRegisterCovenantModel> get covenants => [..._covenants];
  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void clearTelephoneControllers({
    required TextEditingController telephoneController,
    required TextEditingController dddController,
  }) {
    telephoneController.text = "";
    dddController.text = "";
  }

  void addEmail(TextEditingController emailController) {
    final oldCustomer = _customer;

    if (oldCustomer?.Emails?.contains(emailController.text) == true) {
      ShowSnackbarMessage.show(
          message: "Esse email já foi adicionado",
          context: NavigatorKey.key.currentState!.context);
      return;
    }
    _customer = oldCustomer
        ?.copyWith(Emails: [...oldCustomer.Emails ?? [], emailController.text]);

    emailController.text = "";

    notifyListeners();
  }

  bool addTelephone({
    required String phoneNumber,
    required String areaCode,
  }) {
    final newTelephone = CustomerTelephoneModel(
      AreaCode: areaCode,
      PhoneNumber: phoneNumber,
    );

    if (_customer?.Telephones
            ?.where((e) =>
                e.AreaCode == newTelephone.AreaCode &&
                e.PhoneNumber == newTelephone.PhoneNumber)
            .isNotEmpty ==
        true) {
      ShowSnackbarMessage.show(
          message: "Esse telefone já foi inserido!",
          context: NavigatorKey.key.currentState!.context);
      return false;
    }

    _customer = _customer
        ?.copyWith(Telephones: [..._customer?.Telephones ?? [], newTelephone]);

    notifyListeners();

    return true;
  }

  void removeEmail(int index) {
    final newEmails =
        customer?.Emails?.where((e) => e != customer?.Emails?[index]).toList();

    _customer = _customer?.copyWith(Emails: newEmails);
    notifyListeners();
  }

  void removeTelephone(int index) {
    _customer?.Telephones?.removeAt(index);

    notifyListeners();
  }

  Map<String, dynamic> _getJsonInsertCustomer({
    required AddressProvider addressProvider,
    required String? password,
  }) {
    Map<String, dynamic> _jsonInsertCustomer = {
      "Name": _customer?.Name,
      "ReducedName": _customer?.ReducedName,
      "CpfCnpjNumber": _customer?.CpfCnpjNumber,
      "Password": password,
      "SexType": _customer?.SexType == "Masculino" ? "M" : "F",
      "PersonType": _customer?.CpfCnpjNumber?.length == 11 ? "F" : "J",
      "RegistrationNumber": _customer?.RegistrationNumber,
      "Emails": _customer?.Emails,
      "Telephones": _customer?.Telephones?.map((e) => e.toJson()).toList(),
      "Addresses": _customer?.Addresses?.map((e) => e.toJson()).toList(),
      // "Covenants": null,
    };
    if ((_customer?.CustomerCovenants?.length ?? 0) > 0) {
      _jsonInsertCustomer["CustomerCovenants"] = _customer?.CustomerCovenants!
          .map(
            (e) => CustomerRegisterCustomerCovenantModel(
              Code: e.covenant!.Code!.toInt(),
              Matriculate: "",
              LimitOfPurchase: e.LimitOfPurchase!,
            ).toJson(),
          )
          .toList();
    }
    if (_customer?.DateOfBirth != null) {
      _jsonInsertCustomer["DateOfBirth"] = DateFormat("yyyy-MM-dd'T'HH:mm:ss.")
          .parse(customer!.DateOfBirth!)
          .toString();
    }

    _jsonInsertCustomer.toString();
    return _jsonInsertCustomer;
  }

  void changeIsLoadingInsertCustomer() {
    _isLoading = false;
  }

  Future<void> insertCustomer({
    required AddressProvider addressProvider,
    required String? password,
  }) async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final jsonInsertCustomer = _getJsonInsertCustomer(
        addressProvider: addressProvider,
        password: password,
      );

      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "json": json.encode(jsonInsertCustomer),
        },
        typeOfResponse: "InsertUpdateCustomerResponse",
        SOAPAction: "InsertUpdateCustomer",
        serviceASMX: "CeltaCustomerService.asmx",
        typeOfResult: "InsertUpdateCustomerResult",
      );

      _errorMessage = SoapRequestResponse.errorMessage;

      if (_errorMessage == "") {
        FirebaseHelper.addSoapCallInFirebase(FirebaseCallEnum.customerRegister);

        clearCustomer();
      }
    } catch (e) {
      //print('Erro para cadastrar o cliente: $e');
      _errorMessage = DefaultErrorMessage.ERROR;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCovenants() async {
    if (_covenants.isNotEmpty) {
      //não precisa consultar novamente se já houver dados
      return;
    }
    _isLoading = true;
    _errorMessage = "";
    _covenants.clear();
    notifyListeners();

    try {
      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "covenantData": "%",
          "covenantDataType": 3, //approximate name
        },
        typeOfResponse: "GetCovenantJsonResponse",
        SOAPAction: "GetCovenantJson",
        serviceASMX: "CeltaCustomerService.asmx",
        typeOfResult: "GetCovenantJsonResult",
      );

      _errorMessage = SoapRequestResponse.errorMessage;

      if (_errorMessage == "") {
        CustomerRegisterCovenantModel.responseAsStringToModel(
          listToAdd: _covenants,
          response: SoapRequestResponse.responseAsString,
        );
      }
    } catch (e) {
      _errorMessage = DefaultErrorMessage.ERROR;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void bindCovenant({
    required double limit,
  }) {
    final newCovenant = _selectedCovenant;
    _customer = _customer?.copyWith(CustomerCovenants: [
      ..._customer?.CustomerCovenants ?? [],
      CustomerCovenantModel(
        covenant: CovenantModel(
          Code: newCovenant?.Codigo_Convenio?.toInt(),
          PersonalizedCode: newCovenant?.CodigoLegado_Convenio?.toString(),
          Name: newCovenant?.Nome_Convenio,
        ),
        Matriculate: "99",
        LimitOfPurchase: limit,
        isSelected: true,
      )
    ]);

    _selectedCovenant = null;
    notifyListeners();
  }

  void unbindCovenant(int index) {
    final oldCustomer = _customer;
    oldCustomer?.CustomerCovenants?.removeAt(index);

    _customer = oldCustomer;
    notifyListeners();
  }

  Future<void> getCustomer(String cpfCnpjText) async {
    _isLoading = true;
    _errorMessage = "";
    _customer = null;
    notifyListeners();

    try {
      _customer = await SoapHelper.getCustomer(
        searchTypeInt: 1, //cpf/cnpj
        controllerText: cpfCnpjText,
        enterpriseCode: "1",
      );
    } catch (e) {
      debugPrint(SoapRequestResponse.errorMessage);
      _errorMessage = SoapRequestResponse.errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool addAddress(AddressModel address) {
    if (_customer?.Addresses
            ?.where((e) => e.Zip == address.Zip && e.Number == address.Number)
            .isEmpty ==
        false) {
      ShowSnackbarMessage.show(
        message: "Esse endereço já foi adicionado",
        context: NavigatorKey.key.currentState!.context,
      );
      return false;
    }

    _customer = _customer?.copyWith(Addresses: [
      ..._customer?.Addresses ?? [],
      address,
    ]);
    notifyListeners();
    return true;
  }

  void removeAddress(int index) {
    _customer?.Addresses?.removeAt(index);

    notifyListeners();
  }

  void changePersonalData({
    required String? cpfCnpj,
    required String? name,
    required String? sexType,
    required String? reducedName,
    required DateTime? birthDate,
    required String? password,
    required String? registrationNumber,
  }) {
    if (_customer != null) {
      _customer = _customer?.copyWith(
        CpfCnpjNumber: cpfCnpj,
        Name: name,
        SexType: sexType,
        ReducedName: reducedName,
        DateOfBirth: birthDate?.toIso8601String(),
        password: password,
        RegistrationNumber: registrationNumber,
      );
    } else {
      _customer = CustomerModel(
        CpfCnpjNumber: cpfCnpj,
        Name: name,
        SexType: sexType,
        ReducedName: reducedName,
        DateOfBirth: birthDate?.toIso8601String(),
        password: password,
        RegistrationNumber: registrationNumber,
        Code: null,
        PersonalizedCode: null,
        PersonType: null,
        Emails: null,
        Telephones: null,
        Addresses: null,
        selected: false,
        CustomerCovenants: null,
        saleBlockadeInstructionModel: null,
        saleBlockadeModel: null,
      );
    }
    notifyListeners();
  }

  void updateSelectedCovenant(CustomerRegisterCovenantModel? value) {
    if (_selectedCovenant == value) {
      _selectedCovenant = null;
    } else {
      _selectedCovenant = value;
    }
    notifyListeners();
  }

  void clearCustomer() {
    _customer = null;
  }
}
