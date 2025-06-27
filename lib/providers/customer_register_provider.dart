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

    _customer = CustomerModel(
      Emails: [...oldCustomer?.Emails ?? [], emailController.text],
      Name: customer?.Name,
      Code: customer?.Code,
      PersonalizedCode: customer?.PersonalizedCode,
      ReducedName: customer?.ReducedName,
      CpfCnpjNumber: customer?.CpfCnpjNumber,
      RegistrationNumber: customer?.RegistrationNumber,
      DateOfBirth: customer?.DateOfBirth,
      SexType: customer?.SexType,
      PersonType: customer?.PersonType,
      Telephones: customer?.Telephones,
      Addresses: customer?.Addresses,
      selected: customer?.selected == true,
      password: customer?.password,
      CustomerCovenants: customer?.CustomerCovenants,
    );

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
    final oldCustomer = _customer;

    _customer = CustomerModel(
      Telephones: [
        ...oldCustomer?.Telephones ?? [],
        newTelephone,
      ],
      Name: oldCustomer?.Name,
      Code: oldCustomer?.Code,
      PersonalizedCode: oldCustomer?.PersonalizedCode,
      ReducedName: oldCustomer?.ReducedName,
      CpfCnpjNumber: oldCustomer?.CpfCnpjNumber,
      RegistrationNumber: oldCustomer?.RegistrationNumber,
      DateOfBirth: oldCustomer?.DateOfBirth,
      SexType: oldCustomer?.SexType,
      PersonType: oldCustomer?.PersonType,
      Emails: oldCustomer?.Emails,
      Addresses: oldCustomer?.Addresses,
      selected: oldCustomer?.selected == true,
      password: oldCustomer?.password,
      CustomerCovenants: oldCustomer?.CustomerCovenants,
    );

    notifyListeners();

    return true;
  }

  void removeEmail(int index) {
    final newEmails =
        customer?.Emails?.where((e) => e != customer?.Emails?[index]).toList();

    _customer = CustomerModel(
      Emails: newEmails,
      Name: customer?.Name,
      Code: customer?.Code,
      PersonalizedCode: customer?.PersonalizedCode,
      ReducedName: customer?.ReducedName,
      CpfCnpjNumber: customer?.CpfCnpjNumber,
      RegistrationNumber: customer?.RegistrationNumber,
      DateOfBirth: customer?.DateOfBirth,
      SexType: customer?.SexType,
      PersonType: customer?.PersonType,
      Telephones: customer?.Telephones,
      Addresses: customer?.Addresses,
      selected: customer?.selected == true,
      password: customer?.password,
      CustomerCovenants: customer?.CustomerCovenants,
    );
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
      "Name": customer?.Name,
      "ReducedName": customer?.ReducedName,
      "CpfCnpjNumber": customer?.CpfCnpjNumber,
      "Password": password,
      "SexType": customer?.SexType == "Masculino" ? "M" : "F",
      "PersonType": customer?.CpfCnpjNumber?.length == 11 ? "F" : "J",
      "RegistrationNumber": "", //TODO in UI this parameter
      "Emails": customer?.Emails,
      "Telephones": customer?.Telephones?.map((e) => e.toJson()).toList(),
      "Addresses": customer?.Addresses?.map((e) => e.toJson()).toList(),
      // "Covenants": null,
    };
    if ((customer?.CustomerCovenants?.length ?? 0) > 0) {
      _jsonInsertCustomer["CustomerCovenants"] = customer?.CustomerCovenants!
          .map(
            (e) => CustomerRegisterCustomerCovenantModel(
              Code: e.covenant!.Code!.toInt(),
              Matriculate: "",
              LimitOfPurchase: e.LimitOfPurchase!,
            ).toJson(),
          )
          .toList();
    }
    if (customer?.DateOfBirth != null) {
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
    final oldCustomer = _customer;
    _customer = CustomerModel(
      CustomerCovenants: [
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
      ],
      Name: oldCustomer?.Name,
      Code: oldCustomer?.Code,
      PersonalizedCode: oldCustomer?.PersonalizedCode,
      ReducedName: oldCustomer?.ReducedName,
      CpfCnpjNumber: oldCustomer?.CpfCnpjNumber,
      RegistrationNumber: oldCustomer?.RegistrationNumber,
      DateOfBirth: oldCustomer?.DateOfBirth,
      SexType: oldCustomer?.SexType,
      PersonType: oldCustomer?.PersonType,
      Emails: oldCustomer?.Emails,
      Telephones: oldCustomer?.Telephones,
      Addresses: oldCustomer?.Addresses,
      selected: oldCustomer?.selected == true,
      password: oldCustomer?.password,
    );

    _selectedCovenant = null;
    notifyListeners();
  }

  void unbindCovenant(int index) {
    final oldCustomer = _customer;
    oldCustomer?.CustomerCovenants?.removeAt(index);

    _customer = CustomerModel(
      Name: oldCustomer?.Name,
      Code: oldCustomer?.Code,
      PersonalizedCode: oldCustomer?.PersonalizedCode,
      ReducedName: oldCustomer?.ReducedName,
      CpfCnpjNumber: oldCustomer?.CpfCnpjNumber,
      RegistrationNumber: oldCustomer?.RegistrationNumber,
      DateOfBirth: oldCustomer?.DateOfBirth,
      SexType: oldCustomer?.SexType,
      PersonType: oldCustomer?.PersonType,
      Emails: oldCustomer?.Emails,
      Telephones: oldCustomer?.Telephones,
      Addresses: oldCustomer?.Addresses,
      selected: oldCustomer?.selected == true,
      password: oldCustomer?.password,
      CustomerCovenants: oldCustomer?.CustomerCovenants,
    );
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

    final oldCustomer = _customer;

    _customer = CustomerModel(
      Addresses: [
        ...oldCustomer?.Addresses ?? [],
        address,
      ],
      Name: oldCustomer?.Name ?? "",
      Code: oldCustomer?.Code,
      PersonalizedCode: oldCustomer?.PersonalizedCode,
      ReducedName: oldCustomer?.ReducedName,
      CpfCnpjNumber: oldCustomer?.CpfCnpjNumber ?? "",
      RegistrationNumber: oldCustomer?.RegistrationNumber,
      DateOfBirth: oldCustomer?.DateOfBirth,
      SexType: oldCustomer?.SexType ?? "M",
      PersonType: oldCustomer?.PersonType ?? "M",
      Emails: oldCustomer?.Emails,
      Telephones: oldCustomer?.Telephones,
      selected: oldCustomer?.selected == true,
      CustomerCovenants: oldCustomer?.CustomerCovenants,
      password: oldCustomer?.password,
    );
    notifyListeners();
    return true;
  }

  void removeAddress(int index) {
    final oldCustomer = _customer;
    oldCustomer?.Addresses?.removeAt(index);
    _customer = CustomerModel(
      Addresses: oldCustomer?.Addresses,
      Name: customer?.Name,
      Code: customer?.Code,
      PersonalizedCode: customer?.PersonalizedCode,
      ReducedName: customer?.ReducedName,
      CpfCnpjNumber: customer?.CpfCnpjNumber,
      RegistrationNumber: customer?.RegistrationNumber,
      DateOfBirth: customer?.DateOfBirth,
      SexType: customer?.SexType,
      PersonType: customer?.PersonType,
      Emails: customer?.Emails,
      Telephones: customer?.Telephones,
      selected: customer?.selected == true,
      password: customer?.password,
      CustomerCovenants: customer?.CustomerCovenants,
    );

    notifyListeners();
  }

  void changePersonalData({
    required String? cpfCnpj,
    required String? name,
    required String? sexType,
    String? reducedName,
    DateTime? birthDate,
    String? password,
  }) {
    final oldCustomer = _customer;
    _customer = CustomerModel(
      CpfCnpjNumber: cpfCnpj,
      Name: name,
      SexType: sexType,
      ReducedName: reducedName,
      DateOfBirth: birthDate?.toIso8601String(),
      password: password,
      Addresses: oldCustomer?.Addresses,
      Code: oldCustomer?.Code,
      PersonalizedCode: oldCustomer?.PersonalizedCode,
      RegistrationNumber: oldCustomer?.RegistrationNumber,
      PersonType: oldCustomer?.PersonType ?? "F",
      Emails: oldCustomer?.Emails,
      Telephones: oldCustomer?.Telephones,
      selected: oldCustomer?.selected == true,
      CustomerCovenants: oldCustomer?.CustomerCovenants,
    );
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
