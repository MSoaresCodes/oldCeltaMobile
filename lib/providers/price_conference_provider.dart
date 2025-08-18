import 'package:flutter/material.dart';

import '../api/api.dart';
import '../Models/models.dart';
import '../utils/utils.dart';
import './providers.dart';

class PriceConferenceProvider with ChangeNotifier {
  List<GetProductJsonModel> _products = [];

  List<GetProductJsonModel> get products => [..._products];
  int get productsCount => _products.length;
  bool _isLoading = false;

  get isLoading => _isLoading;
  String _errorMessage = "";

  get errorMessage => _errorMessage;

  clearProducts() {
    _products.clear();
    notifyListeners();
  }

  changeFocusToConsultProduct({required BuildContext context}) {
    FocusScope.of(context).requestFocus(consultProductFocusNode);
  }

  Future<void> _getProducts({
    required EnterpriseModel enterprise,
    required String controllerText, //em string pq vem de um texfFormField
    required BuildContext context,
    required ConfigurationsProvider configurationsProvider,
  }) async {
    _products.clear();
    _errorMessage = "";
    _isLoading = true;
    notifyListeners();

    FirebaseHelper.addSoapCallInFirebase(
      FirebaseCallEnum.priceConferenceGetProductOrSendToPrint,
    );

    dynamic value = int.tryParse(controllerText);
    //o valor pode ser em inteiro ou em texto
    if (value == null) {
      //retorna nulo quando não consegue converter para inteiro. Se não
      //conseguir converter precisa consultar por nome, por isso pode usar o
      //próprio texto do "controllerText"
      value = controllerText;
    }

    try {
      _products = await SoapHelper.getProductsJsonModel(
        enterprise: enterprise,
        searchValue: controllerText,
        configurationsProvider: configurationsProvider,
        enterprisesCodes: [enterprise.Code],
        routineTypeInt: 4,
      );

      _errorMessage = SoapRequestResponse.errorMessage;
    } catch (e) {
      //print("Erro para efetuar a requisição : $e");
      _errorMessage = DefaultErrorMessage.ERROR;
    }
    _isLoading = false;
    notifyListeners();
  }

  final consultProductFocusNode = FocusNode();

  Future<void> getProduct({
    required EnterpriseModel enterprise,
    required String controllerText,
    required BuildContext context,
    required ConfigurationsProvider configurationsProvider,
  }) async {
    await _getProducts(
      enterprise: enterprise,
      controllerText: controllerText,
      context: context,
      configurationsProvider: configurationsProvider,
    );

    if (_errorMessage != "") {
      //quando da erro para consultar os produtos, muda o foco novamente para o
      //campo de pesquisa dos produtos
      Future.delayed(const Duration(milliseconds: 100), () {
        //se não colocar em um future pra mudar o foco, não funciona corretamente
        FocusScope.of(context).requestFocus(consultProductFocusNode);
        //altera o foco para o campo de pesquisa novamente
      });
    }

    notifyListeners();
  }

  bool _isSendingToPrint = false;

  bool get isSendingToPrint => _isSendingToPrint;

  String _errorSendToPrint = "";

  String get errorSendToPrint => _errorSendToPrint;

  Future<void> sendToPrint({
    required int enterpriseCode,
    required int productPackingCode,
    required int index,
    required BuildContext context,
  }) async {
    _isSendingToPrint = true;
    _errorSendToPrint = "";
    notifyListeners();

    FirebaseHelper.addSoapCallInFirebase(
      FirebaseCallEnum.priceConferenceGetProductOrSendToPrint,
    );

    bool newValue = !(_products[index].pendantPrintLabel ?? false);

    try {
      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "enterpriseCode": enterpriseCode,
          "productPackingCode": productPackingCode,
          "send": newValue,
        },
        typeOfResponse: "SendToPrintResponse",
        SOAPAction: "SendToPrint",
        serviceASMX: "CeltaPriceConferenceService.asmx",
      );
      _errorSendToPrint = SoapRequestResponse.errorMessage;

      if (_errorSendToPrint == "") {
        _products[index].pendantPrintLabel =
            !(_products[index].pendantPrintLabel ?? false);
      }
      //como deu certo a marcação/desmarcação, precisa atualizar na lista local se está marcado ou não
    } catch (e) {
      //print("Erro para efetuar a requisição: $e");
      _errorSendToPrint = DefaultErrorMessage.ERROR;
    } finally {
      _isSendingToPrint = false;
      notifyListeners();
    }
  }

  orderByUpPrice() {
    _products.sort(
        (a, b) => a.retailPracticedPrice!.compareTo(b.retailPracticedPrice!));

    notifyListeners();
  }

  orderByDownPrice() {
    _products.sort(
        (a, b) => b.retailPracticedPrice!.compareTo(a.retailPracticedPrice!));

    notifyListeners();
  }

  orderByUpName() {
    _products.sort((a, b) => a.name!.compareTo(b.name!));

    notifyListeners();
  }

  orderByDownName() {
    _products.sort((a, b) => b.name!.compareTo(a.name!));
    notifyListeners();
  }
}
