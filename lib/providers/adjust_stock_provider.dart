import 'package:flutter/material.dart';

import '../api/api.dart';
import '../components/components.dart';

import '../Models/models.dart';
import '../utils/utils.dart';
import './providers.dart';

class AdjustStockProvider with ChangeNotifier {
  List<GetProductJsonModel> _products = [];
  List<GetProductJsonModel> get products => _products;

  List<GetStockTypesModel> _stockTypes = [];
  List<GetStockTypesModel> get stockTypes => _stockTypes;

  List<GetJustificationsModel> _justifications = [];
  List<GetJustificationsModel> get justifications => _justifications;

  int get productsCount => _products.length;
  int get justificationsCount => _justifications.length;
  int get stockTypesCount => _stockTypes.length;
  String _errorMessageGetProducts = '';

  String get errorMessageGetProducts => _errorMessageGetProducts;
  static bool _isLoadingProducts = false;

  bool get isLoadingProducts => _isLoadingProducts;
  String _errorMessageTypeStockAndJustifications = '';

  String get errorMessageTypeStockAndJustifications =>
      _errorMessageTypeStockAndJustifications;
  String _errorMessageAdjustStock = '';

  String _justificationStockTypeName = "";
  String get justificationStockTypeName => _justificationStockTypeName;
  updateJustificationStockTypeName(String newValue) {
    _justificationStockTypeName = newValue;
    notifyListeners();
  }

  String _lastUpdatedQuantity = "";
  int _indexOfLastProductChangedStockQuantity =
      -1; //index do último produto alterado. Serve para só exibir a mensagem da última quantidade alterada no produto correto

  String stockTypeName =
      ""; //quando clica no tipo de estoque altera o valor da variável. É utilizado pra se for o estoque atual, já atualizar no produto consultado
  String typeOperator =
      ""; //quando clica na opção de justificativa, obtém o tipo de operador "-" ou "+". Isso é usado pra atualizar o estoque do produto consultado após confirmar a alteração

  String get lastUpdatedQuantity => _lastUpdatedQuantity;
  int get indexOfLastProductChangedStockQuantity =>
      _indexOfLastProductChangedStockQuantity;

  String get errorMessageAdjustStock => _errorMessageAdjustStock;
  static bool _isLoadingAdjustStock = false;

  bool get isLoadingAdjustStock => _isLoadingAdjustStock;
  static bool _isLoadingTypeStockAndJustifications = false;
  set isLoadingAdjustStock(bool newValue) {
    _isLoadingAdjustStock = newValue;
  }

  bool get isLoadingTypeStockAndJustifications =>
      _isLoadingTypeStockAndJustifications;
  var consultProductFocusNode = FocusNode();
  var consultedProductFocusNode = FocusNode();

  bool _justificationHasStockType = false;
  bool get justificationHasStockType => _justificationHasStockType;
  set justificationHasStockType(bool value) {
    _justificationHasStockType = value;
    notifyListeners();
  }

  Map<String, dynamic> jsonAdjustStock = {
    "EnterpriseCode": "", //esse parâmetro vem da tela de empresas
    "ProductCode": "", //quando clica no produto, altera o código
    "ProductPackingCode": "", //quando clica no produto, altera o código
    "JustificationCode":
        "", //sempre que seleciona a opção do dropdown altera o valor aqui
    "StockTypeCode":
        0, //sempre que seleciona a opção do dropdown altera o valor aqui
    "Quantity":
        "" //quando clica em "alterar", valida se a quantidade é válida e se os dropdowns do estoque e justificativa estão selecionados. Caso esteja tudo certo, altera a quantidade do json de acordo com o que o usuário digitou
  };

  // _updateCurrentStock({
  //   required int index,
  //   required String consultedProductControllerText,
  // }) {
  //   _products[index].CurrentStock =
  //       _products[index].CurrentStock.replaceAll(RegExp(r'\,'), '');
  //   _products[index].SaldoEstoqueVenda =
  //       _products[index].SaldoEstoqueVenda.replaceAll(RegExp(r'\,'), '');

  //   double currentStockInDouble =
  //       double.tryParse(_products[index].CurrentStock)!;
  //   double saldoEstoqueVendaInDouble =
  //       double.tryParse(_products[index].SaldoEstoqueVenda)!;
  //   double consultedProductControllerInDouble =
  //       double.tryParse(consultedProductControllerText)!;

  //   if (typeOperator.contains("+")) {
  //     _products[index].CurrentStock =
  //         (currentStockInDouble + consultedProductControllerInDouble)
  //             .toString();

  //     _products[index].SaldoEstoqueVenda =
  //         (saldoEstoqueVendaInDouble + consultedProductControllerInDouble)
  //             .toString();
  //   } else {
  //     _products[index].CurrentStock =
  //         (currentStockInDouble - consultedProductControllerInDouble)
  //             .toString();

  //     _products[index].SaldoEstoqueVenda =
  //         (currentStockInDouble - consultedProductControllerInDouble)
  //             .toString();
  //   }
  // }

  clearProductsJustificationsStockTypesAndJsonAdjustStock() {
    _justifications.clear();
    _stockTypes.clear();
    _products.clear();
    jsonAdjustStock.clear();
    _lastUpdatedQuantity = "";
    _indexOfLastProductChangedStockQuantity = -1;
    _justificationHasStockType = false;
    notifyListeners();
  }

  Future<void> _getProducts({
    required EnterpriseModel enterprise,
    required String controllerText, //em string pq vem de um texfFormField
    required BuildContext context,
    required ConfigurationsProvider configurationsProvider,
  }) async {
    _errorMessageGetProducts = "";
    _isLoadingProducts = true;
    // _stockTypes.clear();
    // _justifications.clear();
    // _justificationStockTypeName = "";
    // _justificationHasStockType = false;

    notifyListeners();

    try {
      _products = await SoapHelper.getProductsJsonModel(
        enterprise: enterprise,
        searchValue: controllerText,
        configurationsProvider: configurationsProvider,
        enterprisesCodes: [enterprise.Code],
        routineTypeInt: 4,
      );

      _errorMessageGetProducts = SoapRequestResponse.errorMessage;
    } catch (e) {
      //print("Erro para efetuar a requisição na nova forma de consulta: $e");
      _errorMessageGetProducts = DefaultErrorMessage.ERROR;
    }
    _isLoadingProducts = false;
    notifyListeners();
  }

  Future<void> getProducts({
    required EnterpriseModel enterprise,
    required String controllerText,
    required BuildContext context,
    required ConfigurationsProvider configurationsProvider,
  }) async {
    _lastUpdatedQuantity = "";
    _indexOfLastProductChangedStockQuantity = -1;
    _products.clear();
    notifyListeners();

    if (_justifications.isEmpty || _stockTypes.isEmpty) {
      await getStockTypeAndJustifications(context);
    }

    await _getProducts(
      enterprise: enterprise,
      controllerText: controllerText,
      context: context,
      configurationsProvider: configurationsProvider,
    );

    if (_errorMessageGetProducts != "") {
      //quando da erro para consultar os produtos, muda o foco novamente para o
      //campo de pesquisa dos produtos
      Future.delayed(const Duration(milliseconds: 100), () {
        //se não colocar em um future pra mudar o foco, não funciona corretamente
        FocusScope.of(context).requestFocus(consultProductFocusNode);
        //altera o foco para o campo de pesquisa novamente
      });
      // ShowErrorMessage.showErrorMessage(
      //   error: _errorMessageGetProducts,
      //   context: context,
      // );
    }
    notifyListeners();
  }

  _getStockType() async {
    _stockTypes.clear();
    notifyListeners();
    try {
      await SoapHelper.getStockTypesModel(_stockTypes);
      _errorMessageTypeStockAndJustifications =
          SoapRequestResponse.errorMessage;
    } catch (e) {
      //print("Erro para efetuar a requisição stockTypes: $e");
      _errorMessageTypeStockAndJustifications = DefaultErrorMessage.ERROR;
    }
    notifyListeners();
  }

  _getJustificationsType() async {
    _justifications.clear();
    notifyListeners();
    try {
      await SoapHelper.getJustifications(
        justificationTransferType: 3,
        listToAdd: _justifications,
      );

      _errorMessageTypeStockAndJustifications =
          SoapRequestResponse.errorMessage;
    } catch (e) {
      //print("Erro para efetuar a requisição justifications: $e");
      _errorMessageTypeStockAndJustifications = DefaultErrorMessage.ERROR;
    }
    notifyListeners();
  }

  Future<void> getStockTypeAndJustifications(BuildContext context) async {
    _isLoadingTypeStockAndJustifications = true;
    _errorMessageTypeStockAndJustifications = "";
    _justificationHasStockType = false;
    notifyListeners();

    await _getStockType();

    await _getJustificationsType();

    if (_errorMessageTypeStockAndJustifications != "") {
      ShowSnackbarMessage.show(
        message: _errorMessageTypeStockAndJustifications,
        context: context,
      );
    }

    _isLoadingTypeStockAndJustifications = false;
    notifyListeners();
  }

  _updateProductCodeAndProductPackingCode(int indexOfProduct) {
    jsonAdjustStock["ProductPackingCode"] =
        _products[indexOfProduct].productPackingCode;
    jsonAdjustStock["ProductCode"] = _products[indexOfProduct].productCode;
  }

  Future<void> confirmAdjustStock({
    required BuildContext context,
    required int indexOfProduct,
    required String consultedProductControllerText,
  }) async {
    _isLoadingAdjustStock = true;
    _errorMessageAdjustStock = "";
    notifyListeners();

    FirebaseHelper.addSoapCallInFirebase(
      FirebaseCallEnum.adjustStockConfirmQuantity,
    );
    //print(jsonAdjustStock.toString());

    _updateProductCodeAndProductPackingCode(indexOfProduct);

    try {
      await SoapHelper.confirmAdjustStock(
        [
          TransferBetweenStockBodyModel(
            EnterpriseCode:
                jsonAdjustStock['EnterpriseCode'].toString().toInt(),
            ProductCode: jsonAdjustStock['ProductCode'],
            ProductPackingCode: jsonAdjustStock['ProductPackingCode'],
            JustificationCode: jsonAdjustStock['JustificationCode'],
            StockTypeCode: jsonAdjustStock['StockTypeCode'],
            StockTypeRecipientCode: null,
            Quantity: jsonAdjustStock['Quantity'].toString().toDouble(),
            IsPendingAdjust: false,
          ),
        ],
        false,
      );

      _errorMessageAdjustStock = SoapRequestResponse.errorMessage;
      if (_errorMessageAdjustStock == "") {
        typeOperator = typeOperator
            .replaceAll(RegExp(r'\('), '')
            .replaceAll(RegExp(r'\)'), '');
        _lastUpdatedQuantity = typeOperator + jsonAdjustStock["Quantity"]!;
        _indexOfLastProductChangedStockQuantity = indexOfProduct;
      } else {
        ShowSnackbarMessage.show(
          message: _errorMessageAdjustStock,
          context: context,
        );
      }
    } catch (e) {
      //print("Erro para efetuar a requisição justifications: $e");
      _errorMessageAdjustStock = DefaultErrorMessage.ERROR;

      ShowSnackbarMessage.show(
        message: _errorMessageAdjustStock,
        context: context,
      );
    }

    _isLoadingAdjustStock = false;
    notifyListeners();
  }
}
