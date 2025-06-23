import 'package:flutter/material.dart';

import '../api/api.dart';
import '../components/components.dart';
import '../Models/models.dart';
import '../utils/utils.dart';
import './providers.dart';

class TransferBetweenStocksProvider with ChangeNotifier {
  List<GetProductJsonModel> _products = [];
  List<GetProductJsonModel> get products => _products;

  List<GetStockTypesModel> _originStockTypes = [];
  List<GetStockTypesModel> get originStockTypes => _originStockTypes;

  List<GetStockTypesModel> _destinyStockTypes = [];
  List<GetStockTypesModel> get destinyStockTypes => _destinyStockTypes;

  List<GetJustificationsModel> _justifications = [];
  List<GetJustificationsModel> get justifications => _justifications;

  TransferBetweenStockBodyModel? _jsonAdjustStock;
  TransferBetweenStockBodyModel? get jsonAdjustStock => _jsonAdjustStock;

  int get productsCount => _products.length;
  int get justificationsCount => _justifications.length;
  int get originStockTypesCount => _originStockTypes.length;
  int get destinyStockTypesCount => _destinyStockTypes.length;
  String _errorMessageGetProducts = '';

  String get errorMessageGetProducts => _errorMessageGetProducts;
  static bool _isLoadingProducts = false;

  bool get isLoadingProducts => _isLoadingProducts;
  String _errorMessageTypeStockAndJustifications = '';

  String get errorMessageTypeStockAndJustifications =>
      _errorMessageTypeStockAndJustifications;
  String _errorMessageAdjustStock = '';

  String _justificationStockTypeName = ""; //TODO remove this
  String get justificationStockTypeName => _justificationStockTypeName;
  void updateJustificationStockTypeName(String newValue) {
    _justificationStockTypeName = newValue;
    notifyListeners();
  }

  String _lastUpdatedQuantity = "";
  int _indexOfLastProductChangedStockQuantity = -1;
  String get lastUpdatedQuantity => _lastUpdatedQuantity;
  int get indexOfLastProductChangedStockQuantity =>
      _indexOfLastProductChangedStockQuantity;

  String get errorMessageAdjustStock => _errorMessageAdjustStock;
  static bool _isLoadingAdjustStock = false;

  bool get isLoadingAdjustStock => _isLoadingAdjustStock;
  static bool _isLoadingTypeStockAndJustifications = false;

  bool get isLoadingTypeStockAndJustifications =>
      _isLoadingTypeStockAndJustifications;
  var consultProductFocusNode = FocusNode();
  var consultedProductFocusNode = FocusNode();

  bool _justificationHasStockType = false; //TODO remove this
  bool get justificationHasStockType => _justificationHasStockType;
  set justificationHasStockType(bool value) {
    _justificationHasStockType = value;
    notifyListeners();
  }

  void clearProductsJustificationsStockTypesAndJsonAdjustStock() {
    _justifications.clear();
    _originStockTypes.clear();
    _destinyStockTypes.clear();
    _products.clear();
    _jsonAdjustStock = null;
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

    await _getProducts(
      enterprise: enterprise,
      controllerText: controllerText,
      context: context,
      configurationsProvider: configurationsProvider,
    );

    if (_justifications.isEmpty ||
        _destinyStockTypes.isEmpty ||
        _originStockTypes.isEmpty) {
      await getStockTypeAndJustifications(context);
    }

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

  _getStockType(BuildContext context) async {
    _originStockTypes.clear();
    _destinyStockTypes.clear();
    notifyListeners();
    try {
      await SoapHelper.getStockTypesModel(_originStockTypes);
      await SoapHelper.getStockTypesModel(_destinyStockTypes);
      _errorMessageTypeStockAndJustifications =
          SoapRequestResponse.errorMessage;
    } catch (e) {
      //print("Erro para efetuar a requisição stockTypes: $e");
      ShowSnackbarMessage.show(
        message: _errorMessageTypeStockAndJustifications,
        context: context,
      );
    }
    notifyListeners();
  }

  _getJustificationsType(BuildContext context) async {
    _justifications.clear();
    notifyListeners();
    try {
      await SoapHelper.getJustifications(
        justificationTransferType: 1,
        listToAdd: _justifications,
      );

      _errorMessageTypeStockAndJustifications =
          SoapRequestResponse.errorMessage;
    } catch (e) {
      //print("Erro para efetuar a requisição justifications: $e");
      _errorMessageTypeStockAndJustifications = DefaultErrorMessage.ERROR;
      ShowSnackbarMessage.show(
        message: _errorMessageTypeStockAndJustifications,
        context: context,
      );
    }
    notifyListeners();
  }

  Future<void> getStockTypeAndJustifications(BuildContext context) async {
    _isLoadingTypeStockAndJustifications = true;
    _errorMessageTypeStockAndJustifications = "";
    _justificationHasStockType = false;
    notifyListeners();

    await _getStockType(context);

    await _getJustificationsType(context);

    if (_errorMessageTypeStockAndJustifications != "") {
      ShowSnackbarMessage.show(
        message: _errorMessageTypeStockAndJustifications,
        context: context,
      );
    }

    _isLoadingTypeStockAndJustifications = false;
    notifyListeners();
  }

  Future<void> confirmAdjustStock({
    required BuildContext context,
    required int indexOfProduct,
    required String consultedProductControllerText,
    required double quantity,
    required int enterpriseCode,
  }) async {
    _isLoadingAdjustStock = true;
    _errorMessageAdjustStock = "";
    notifyListeners();

    FirebaseHelper.addSoapCallInFirebase(
      FirebaseCallEnum.transferBetweenStocksConfirmAdjust,
    );

    try {
      updateBody(
        enterpriseCode: enterpriseCode,
        quantity: quantity,
      );
      await SoapHelper.confirmAdjustStock(jsonAdjustStock!.toJson());

      _errorMessageAdjustStock = SoapRequestResponse.errorMessage;

      if (_errorMessageAdjustStock == "") {
        _lastUpdatedQuantity = ConvertString.convertToBrazilianNumber(
            jsonAdjustStock?.Quantity?.toString());
        _indexOfLastProductChangedStockQuantity = indexOfProduct;
      }

      if (SoapRequestResponse.errorMessage != "") {
        ShowSnackbarMessage.show(
          message: _errorMessageAdjustStock,
          context: context,
        );
      }
    } catch (e) {
      //print("Erro para confirmar o ajuste: $e");
      _errorMessageAdjustStock = DefaultErrorMessage.ERROR;
      ShowSnackbarMessage.show(
        message: _errorMessageAdjustStock,
        context: context,
      );
    }

    _isLoadingAdjustStock = false;
    notifyListeners();
  }

  void updateBody({
    GetStockTypesModel? originStock,
    GetStockTypesModel? destinyStock,
    GetJustificationsModel? justification,
    GetProductJsonModel? product,
    int? enterpriseCode,
    double? quantity,
  }) {
    final oldBody = _jsonAdjustStock;
    final hasFixedDestinyStock =
        justification?.CodigoInterno_TipoEstoque.CodigoInterno_TipoEstoque !=
            -1;

    if (hasFixedDestinyStock) {
      _justificationStockTypeName =
          justification?.CodigoInterno_TipoEstoque.Nome_TipoEstoque ??
              _justificationStockTypeName;
    }

    _jsonAdjustStock = TransferBetweenStockBodyModel(
      EnterpriseCode: enterpriseCode ?? oldBody?.EnterpriseCode,
      StockTypeCode: hasFixedDestinyStock &&
              justification
                      ?.CodigoInterno_TipoEstoque.CodigoInterno_TipoEstoque !=
                  null
          ? justification?.CodigoInterno_TipoEstoque.CodigoInterno_TipoEstoque
          : (originStock?.CodigoInterno_TipoEstoque ?? oldBody?.StockTypeCode),
      ProductCode: product?.productCode ?? oldBody?.ProductCode,
      ProductPackingCode:
          product?.productPackingCode ?? oldBody?.ProductPackingCode,
      JustificationCode:
          justification?.CodigoInterno_JustMov ?? oldBody?.JustificationCode,
      StockTypeRecipientCode: destinyStock?.CodigoInterno_TipoEstoque ??
          oldBody?.StockTypeRecipientCode,
      Quantity: quantity ?? oldBody?.Quantity,
    );
  }
}
