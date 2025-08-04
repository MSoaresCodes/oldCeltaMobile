import 'dart:convert';

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

  List<TransferBetweenStockLotProductsModel> _productsLots = [];
  List<TransferBetweenStockLotProductsModel> get productsLots => _productsLots;

  GetJustificationsModel? _selectedJustification;
  GetStockTypesModel? _selectedOrigin;
  GetStockTypesModel? _selectedDestiny;
  GetJustificationsModel? get selectedJustification => _selectedJustification;
  GetStockTypesModel? get selectedOrigin => _selectedOrigin;
  GetStockTypesModel? get selectedDestiny => _selectedDestiny;

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

  String get errorMessageAdjustStock => _errorMessageAdjustStock;
  static bool _isLoadingAdjustStock = false;

  bool get isLoadingAdjustStock => _isLoadingAdjustStock;
  static bool _isLoadingTypeStockAndJustifications = false;

  bool get isLoadingTypeStockAndJustifications =>
      _isLoadingTypeStockAndJustifications;

  String? _errorSelectedJustification;
  String? get errorSelectedJustification => _errorSelectedJustification;
  String? _errorSelectedOrigin;
  String? get errorSelectedOrigin => _errorSelectedOrigin;
  String? _errorSelectedDestiny;
  String? get errorSelectedDestiny => _errorSelectedDestiny;

  void clearAllData() {
    _justifications.clear();
    _originStockTypes.clear();
    _destinyStockTypes.clear();
    _products.clear();
    _selectedDestiny = null;
    _selectedOrigin = null;
    _selectedJustification = null;
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
    required String text,
    required BuildContext context,
    required ConfigurationsProvider configurationsProvider,
    required FocusNode searchFocusNode,
  }) async {
    _products.clear();
    notifyListeners();

    await _getProducts(
      enterprise: enterprise,
      controllerText: text,
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
        FocusScope.of(context).requestFocus(searchFocusNode);
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
    _selectedJustification = null;
    _selectedOrigin = null;
    _selectedDestiny = null;
    _errorSelectedDestiny = null;
    _errorSelectedOrigin = null;
    _errorSelectedJustification = null;
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
    required int enterpriseCode,
    required bool isPendingAdjust,
  }) async {
    _isLoadingAdjustStock = true;
    _errorMessageAdjustStock = "";
    notifyListeners();

    FirebaseHelper.addSoapCallInFirebase(
      FirebaseCallEnum.transferBetweenStocksConfirmAdjust,
    );

    try {
      await SoapHelper.confirmAdjustStock(
        _productsLots
            .where((e) => e.enterpriseCode == enterpriseCode)
            .map(
              (e) => TransferBetweenStockBodyModel(
                EnterpriseCode: e.enterpriseCode,
                ProductCode: e.product.productCode,
                ProductPackingCode: e.product.productPackingCode,
                JustificationCode: e.justification.CodigoInterno_JustMov,
                StockTypeCode: e.originStock.CodigoInterno_TipoEstoque,
                StockTypeRecipientCode:
                    e.destinyStock.CodigoInterno_TipoEstoque,
                Quantity: e.quantity,
                IsPendingAdjust: isPendingAdjust,
              ),
            )
            .toList(),
        isPendingAdjust,
      );
      _errorMessageAdjustStock = SoapRequestResponse.errorMessage;

      if (_errorMessageAdjustStock == "") {
        _productsLots.removeWhere((e) => e.enterpriseCode == enterpriseCode);
        await PrefsInstance.setString(
          prefsKeys: PrefsKeys.transferBetweenStocksProductslots,
          value: jsonEncode(_productsLots.map((e) => e.toJson()).toList()),
        );

        ShowSnackbarMessage.show(
          message: "Lote salvo com sucesso",
          context: NavigatorKey.key.currentState!.context,
          backgroundColor: Colors.green,
        );
      }

      if (SoapRequestResponse.errorMessage != "") {
        ShowSnackbarMessage.show(
          message: _errorMessageAdjustStock,
          context: NavigatorKey.key.currentState!.context,
        );
      }
    } catch (e) {
      _errorMessageAdjustStock = DefaultErrorMessage.ERROR;
      ShowSnackbarMessage.show(
        message: _errorMessageAdjustStock,
        context: NavigatorKey.key.currentState!.context,
      );
    }

    _isLoadingAdjustStock = false;
    notifyListeners();
  }

  Future<bool> addProductInLot({
    required GetProductJsonModel product,
    required double quantity,
    required int enterpriseCode,
  }) async {
    try {
      int equalProductIndex = _productsLots.indexWhere(
        (e) =>
            e.product.productCode == product.productCode &&
            e.product.productPackingCode == product.productPackingCode &&
            e.enterpriseCode == enterpriseCode,
      );

      final newProduct = TransferBetweenStockLotProductsModel(
        product: product,
        quantity: quantity,
        enterpriseCode: enterpriseCode,
        destinyStock: _selectedDestiny!,
        originStock: _selectedOrigin!,
        justification: _selectedJustification!,
      );

      if (equalProductIndex == -1) {
        _productsLots.add(newProduct);
      } else {
        _productsLots[equalProductIndex] = newProduct;
      }
      await PrefsInstance.setString(
        prefsKeys: PrefsKeys.transferBetweenStocksProductslots,
        value: jsonEncode(_productsLots.map((e) => e.toJson()).toList()),
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> changeQuantityInLot(int index, double quantity) async {
    try {
      final oldProduct = _productsLots[index];

      _productsLots[index] = oldProduct.copyWith(quantity: quantity);
      await PrefsInstance.setString(
        prefsKeys: PrefsKeys.transferBetweenStocksProductslots,
        value: jsonEncode(_productsLots.map((e) => e.toJson()).toList()),
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> removeProductFromLot(
    TransferBetweenStockLotProductsModel itemLot,
  ) async {
    int equalProductIndex = _productsLots.indexWhere((e) =>
        e.product.productCode == itemLot.product.productCode &&
        e.product.productPackingCode == itemLot.product.productPackingCode);

    if (equalProductIndex != -1) {
      _productsLots.removeAt(equalProductIndex);
    } else {
      //product not found. Never should happpen this
    }
    await PrefsInstance.setString(
      prefsKeys: PrefsKeys.transferBetweenStocksProductslots,
      value: jsonEncode(_productsLots.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  void changeSelectedJustification(GetJustificationsModel? value) {
    _selectedJustification = value;

    final fixedOrigin = getFixedOrigin();
    if (fixedOrigin != null) {
      changeSelectedOrigin(fixedOrigin);
    }
    _errorSelectedJustification = null;

    notifyListeners();
  }

  void changeSelectedOrigin(GetStockTypesModel? value) {
    _selectedOrigin = value;
    _errorSelectedOrigin = null;
    notifyListeners();
  }

  void changeSelectedDestiny(GetStockTypesModel? value) {
    _selectedDestiny = value;
    _errorSelectedDestiny = null;
    notifyListeners();
  }

  void validateDropdowns() {
    if (_selectedJustification == null) {
      _errorSelectedJustification = "Selecione uma justificativa!";
      _selectedJustification = null;
    } else {
      _errorSelectedJustification = null;
    }

    if (_selectedOrigin == null) {
      _errorSelectedOrigin = "Selecione a origem!";
      _selectedOrigin = null;
    } else {
      _errorSelectedOrigin = null;
    }

    if (_selectedDestiny == null) {
      _errorSelectedDestiny = "Selecione o destino!";
      _selectedDestiny = null;
    } else if (_selectedDestiny?.CodigoInterno_TipoEstoque ==
        _selectedOrigin?.CodigoInterno_TipoEstoque) {
      _errorSelectedDestiny = "Os estoques devem ser diferentes!";
      _selectedDestiny = null;
    } else {
      _errorSelectedDestiny = null;
    }
    notifyListeners();
  }

  GetStockTypesModel? getFixedOrigin() {
    if (_selectedJustification == null || _originStockTypes.isEmpty) {
      return null;
    }

    if (_selectedJustification
            ?.CodigoInterno_TipoEstoque.Nome_TipoEstoque.isEmpty ==
        true) {
      return null;
    }

    return _originStockTypes.firstWhere((e) =>
        _selectedJustification?.CodigoInterno_TipoEstoque.Nome_TipoEstoque ==
        e.Nome_TipoEstoque);
  }

  Future<void> restoreProductsLots() async {
    try {
      _isLoadingProducts = true;
      notifyListeners();

      // await PrefsInstance.removeKey(
      //     PrefsKeys.transferBetweenStocksProductslots);
      _productsLots.clear();
      final value = await PrefsInstance.getString(
          PrefsKeys.transferBetweenStocksProductslots);
      _productsLots = value.isEmpty
          ? []
          : (jsonDecode(value) as List)
              .map((e) => TransferBetweenStockLotProductsModel.fromJson(e))
              .toList();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }
}
