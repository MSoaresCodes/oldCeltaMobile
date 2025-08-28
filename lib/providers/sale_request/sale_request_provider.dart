import 'dart:convert';

import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';

import '../../api/api.dart';
import '../../components/components.dart';
import '../../Models/models.dart';

import '../../utils/utils.dart';
import '../providers.dart';

class SaleRequestProvider with ChangeNotifier implements ReceiptPdfGenerator {
  bool _isLoadingRequests = false;
  bool get isLoadingRequests => _isLoadingRequests;
  String _errorMessageRequests = "";
  String get errorMessageRequests => _errorMessageRequests;
  List<SaleRequestsModel> _requests = [];
  List<SaleRequestsModel> get requests => [..._requests];
  int get requestsCount => _requests.length;

  bool _needProcessCart = true;
  bool get needProcessCart => _needProcessCart;
  set needProcessCart(bool) {
    _needProcessCart = true;
  }

  bool _isLoadingCustomer = false;
  bool get isLoadingCustomer => _isLoadingCustomer;
  String _errorMessageCustomer = "";
  String get errorMessageCustomer => _errorMessageCustomer;
  Map<String, List<CustomerModel>> _customers = {};
  Map<String, List<CustomerModel>> get customers => _customers;

  bool _isLoadingProducts = false;
  bool get isLoadingProducts => _isLoadingProducts;
  String _errorMessageProducts = "";
  String get errorMessageProducts => _errorMessageProducts;
  List<GetProductJsonModel> _products = [];
  List<GetProductJsonModel> get products => [..._products];
  int get productsCount => _products.length;
  GetProductJsonModel? removedProduct;
  int? indexOfRemovedProduct;

  String _errorMessageSaveSaleRequest = "";
  get errorMessageSaveSaleRequest => _errorMessageSaveSaleRequest;
  bool _isLoadingSaveSaleRequest = false;
  get isLoadingSaveSaleRequest => _isLoadingSaveSaleRequest;

  String _errorMessageProcessCart = "";
  get errorMessageProcessCart => _errorMessageProcessCart;
  bool _isLoadingProcessCart = false;
  get isLoadingProcessCart => _isLoadingProcessCart;

  SaleRequestCartModel? _lastSaleRequestSaved;
  SaleRequestCartModel? get lastSaleRequestSaved => _lastSaleRequestSaved;

  SaleRequestCartModel? _currentCart;
  SaleRequestCartModel? get currentCart => _currentCart;

  bool _isPrinting = false;
  bool get isPrinting => _isPrinting;

  bool _userCanChangePrices = false;
  bool get userCanChangePrices => _userCanChangePrices;

  int customersCount(String enterpriseCode) {
    if (_customers[enterpriseCode] == null) {
      return 0;
    } else {
      return _customers[enterpriseCode]!.length;
    }
  }

  int get indexOfSelectedCovenant {
    int _indexOfSelectedCovenant = -1;
    _customers.forEach((key, value) {
      value.forEach((customer) {
        if (customer.selected == true && customer.CustomerCovenants != null) {
          _indexOfSelectedCovenant = customer.CustomerCovenants!
              .indexWhere((customer) => customer.isSelected);
        }
      });
    });
    return _indexOfSelectedCovenant;
  }

  int? getSelectedCovenantCode(String enterpriseCode) {
    if (_customers[enterpriseCode] != null) {
      final indexSelectedCustomer =
          _customers[enterpriseCode]!.indexWhere((e) => e.selected == true);

      if (indexSelectedCustomer != -1) {
        final indexSelectedCovenant =
            _customers[enterpriseCode]![indexSelectedCustomer]
                .CustomerCovenants
                ?.indexWhere((e) => e.isSelected);

        if (indexSelectedCovenant != -1 && indexSelectedCovenant != null) {
          return _customers[enterpriseCode]![indexSelectedCustomer]
              .CustomerCovenants![indexSelectedCovenant]
              .covenant!
              .Code;
        }
      }
    }
    return null;
  }

  CustomerModel? getSelectedCustomer(String enterpriseCode) {
    if (_customers[enterpriseCode] != null) {
      final customerIndex =
          _customers[enterpriseCode]!.indexWhere((e) => e.selected == true);
      if (customerIndex != -1) {
        return _customers[enterpriseCode]![customerIndex];
      }
    }

    return null;
  }

  Map<String, List<GetProductJsonModel>> _cartProducts = {};
  getCartProducts(int enterpriseCode) {
    return _cartProducts[enterpriseCode.toString()] ?? 0;
  }

  int cartProductsCount(String enterpriseCode) {
    if (_cartProducts[enterpriseCode] == null) {
      return 0;
    } else if (_cartProducts[enterpriseCode]!.isEmpty) {
      return 0;
    } else {
      return _cartProducts[enterpriseCode]!.length;
    }
  }

  void clearRequests() {
    _requests.clear();
    notifyListeners();
  }

  Future<void> _updateCustomerInDatabase() async {
    await PrefsInstance.setObject(
      prefsKeys: PrefsKeys.customers,
      object: _customers.map((key, value) {
        return MapEntry(
          key,
          value
              .map((e) => e)
              .toList()
              .where((x) => x.selected == true || x.Code == 1)
              .toList(),
        );
      }),
    );
  }

  Future<void> restorecustomers(String enterpriseCode) async {
    String customers = await PrefsInstance.getString(PrefsKeys.customers);

    if (customers.isEmpty) {
      _customers.clear();
    } else {
      final Map<String, dynamic> customersInDatabase = jsonDecode(customers);

      if (!customersInDatabase.containsKey(enterpriseCode)) return;

      _customers[enterpriseCode] = (customersInDatabase[enterpriseCode] as List)
          .map<CustomerModel>((e) => CustomerModel.fromJson(e))
          .toList();
    }
    notifyListeners();
  }

  _clearcustomers(String enterpriseCode) async {
    if (_customers[enterpriseCode] != null) {
      if (_customers[enterpriseCode]!.isNotEmpty) {
        _customers[enterpriseCode]!.clear();
      }
    }

    await _updateCustomerInDatabase();
    notifyListeners();
  }

  double getTotalItemValue({
    required GetProductJsonModel product,
    required TextEditingController? newQuantityController,
    required String enterpriseCode,
  }) {
    double totalQuantity = 1;

    if (newQuantityController != null &&
        newQuantityController.text.isNotEmpty) {
      totalQuantity = newQuantityController.text.toDouble();
    }

    totalQuantity += getTotalItensInCart(
      ProductPackingCode: product.productPackingCode!,
      enterpriseCode: enterpriseCode,
    );

    double practicedPrice = getPracticedPrice(
      quantityToAdd: totalQuantity,
      product: product,
      enterpriseCode: enterpriseCode,
    );

    return totalQuantity * practicedPrice;
  }

  double getNewItemPrice({
    required GetProductJsonModel product,
    required double newQuantity,
    required String enterpriseCode,
    required String? discountType,
    required TextEditingController? manualDiscountController,
    required TextEditingController? manualPriceController,
  }) {
    if (newQuantity <= 0) {
      newQuantity = 1;
    }

    if (manualPriceController != null &&
        manualPriceController.text.isNotEmpty &&
        manualPriceController.text.toDouble() > 0) {
      return manualPriceController.text.toDouble();
    }

    double price = getPracticedPrice(
      enterpriseCode: enterpriseCode,
      quantityToAdd: newQuantity,
      product: product,
    );

    if (discountType != null &&
        manualDiscountController?.text.toDouble() != -1) {
      if (discountType == "R\$") {
        price = price - manualDiscountController!.text.toDouble();
      } else {
        price = price * (1 - (manualDiscountController!.text.toDouble() / 100));
      }
    }

    return price;
  }

  double getPracticedPrice({
    required double quantityToAdd,
    required GetProductJsonModel product,
    required String enterpriseCode,
  }) {
    if (product.minimumWholeQuantity != null &&
        product.minimumWholeQuantity! > 0 &&
        product.wholePracticedPrice != null &&
        product.wholePracticedPrice! > 0 &&
        quantityToAdd >= product.minimumWholeQuantity!) {
      return product.wholePracticedPrice!;
    } else {
      return product.retailPracticedPrice!;
    }
  }

  // void _changeCursorToLastIndex(
  //     TextEditingController consultedProductController) {
  //   consultedProductController.selection = TextSelection.collapsed(
  //     offset: consultedProductController.text.length,
  //   );
  // }

  _updateCartInDatabase({bool updateToNeedProcessCartAgain = true}) async {
    await PrefsInstance.setObject(
      prefsKeys: PrefsKeys.cart,
      object: _cartProducts,
    );

    if (updateToNeedProcessCartAgain) {
      _needProcessCart = true;
    }
  }

  restoreProducts(String enterpriseCode) async {
    String cart = await PrefsInstance.getString(PrefsKeys.cart);

    if (cart.isEmpty) {
      _cartProducts.clear();
    } else {
      Map cartProductsInDatabase = jsonDecode(cart);

      List<GetProductJsonModel> cartProductsTemp = [];
      cartProductsInDatabase.forEach((key, value) {
        if (key == enterpriseCode) {
          value.forEach((element) {
            cartProductsTemp.add(GetProductJsonModel.fromJson(element));
          });
        }
      });

      _cartProducts[enterpriseCode] = cartProductsTemp;
    }
    notifyListeners();
  }

  void addProductInCart({
    required GetProductJsonModel product,
    required TextEditingController newQuantityController,
    required String enterpriseCode,
  }) async {
    double quantity = 1;

    if (newQuantityController.text.isNotEmpty) {
      quantity = newQuantityController.text.toDouble();
    }

    if (quantity <= 0) {
      quantity = 1;
    }

    final indexOfProductInCart =
        _cartProducts[enterpriseCode]?.indexWhere((e) => e.plu == product.plu);
    double? quantityInCart;
    if (indexOfProductInCart != null && indexOfProductInCart != -1) {
      quantityInCart =
          _cartProducts[enterpriseCode]![indexOfProductInCart].quantity;
    }

    final productPrice = getPracticedPrice(
      quantityToAdd:
          quantityInCart != null ? quantityInCart + quantity : quantity,
      product: product,
      enterpriseCode: enterpriseCode,
    );

    GetProductJsonModel cartProductsModel = product.copyWith(
      productPackingCode: product.productPackingCode!,
      name: product.name!,
      quantity: quantity,
      value: productPrice,
      IncrementPercentageOrValue: "0.0",
      IncrementValue: 0.0,
      DiscountPercentageOrValue: product.DiscountPercentageOrValue ?? "R\$",
      DiscountValue: product.DiscountValue ?? 0,
      // expectedDeliveryDate: "\"${DateTime.now().toString()}\"",
      packingQuantity: product.packingQuantity ?? "0",
      retailPracticedPrice: product.retailPracticedPrice ?? 0,
      retailSalePrice: product.retailSalePrice ?? 0,
      retailOfferPrice: product.retailOfferPrice ?? 0,
      wholePracticedPrice: product.wholePracticedPrice ?? 0,
      wholeSalePrice: product.wholeSalePrice ?? 0,
      wholeOfferPrice: product.wholeOfferPrice ?? 0,
      eCommercePracticedPrice: product.eCommercePracticedPrice ?? 0,
      eCommerceSalePrice: product.eCommerceSalePrice ?? 0,
      eCommerceOfferPrice: product.eCommerceOfferPrice ?? 0,
      minimumWholeQuantity: product.minimumWholeQuantity ?? 0,
      AutomaticDiscountPercentageOrValue:
          product.AutomaticDiscountPercentageOrValue ?? "R\$",
      AutomaticDiscountValue: product.AutomaticDiscountValue ?? 0,
    );

    if (alreadyContainsProduct(
      ProductPackingCode: product.productPackingCode!,
      enterpriseCode: enterpriseCode,
    )) {
      int index = _cartProducts[enterpriseCode]!.indexWhere((element) =>
          element.productPackingCode == product.productPackingCode);

      _cartProducts[enterpriseCode]![index].quantity += quantity;
      _cartProducts[enterpriseCode]![index].value = productPrice;
    } else {
      if (_cartProducts[enterpriseCode.toString()] != null) {
        _cartProducts[enterpriseCode.toString()]?.add(cartProductsModel);
      } else {
        _cartProducts.putIfAbsent(
            enterpriseCode.toString(), () => [cartProductsModel]);
      }
    }

    newQuantityController.text = "";

    await _updateCartInDatabase();
    notifyListeners();
  }

  Future<bool> updateProductInCart({
    required double quantity,
    required String enterpriseCode,
    required int index,
    required bool updateToNeedProcessCartAgain,
    required TextEditingController manualPriceController,
    required TextEditingController manualDiscountController,
    required String? discountType,
  }) async {
    final selectedProduct = _cartProducts[enterpriseCode]![index];

    final newItemPrice = manualPriceController.text.toDouble() != -1
        ? manualPriceController.text.toDouble()
        : getNewItemPrice(
            product: selectedProduct,
            newQuantity: quantity,
            enterpriseCode: enterpriseCode,
            discountType: discountType,
            manualDiscountController: manualDiscountController,
            manualPriceController: manualPriceController,
          );
    if (selectedProduct.priceCost?.RetailMinimumPrice != null &&
        newItemPrice < selectedProduct.priceCost!.RetailMinimumPrice!) {
      ShowSnackbarMessage.show(
        message:
            "O novo preço ($newItemPrice) não pode ser menor do que o preço mínimo (${selectedProduct.priceCost!.RetailMinimumPrice})",
        context: NavigatorKey.key.currentState!.context,
      );
      return false;
    }

    if (manualPriceController.text.isNotEmpty) {
      selectedProduct.value = manualPriceController.text.toDouble();
    } else {
      selectedProduct.value = getPracticedPrice(
        quantityToAdd: quantity,
        product: selectedProduct,
        enterpriseCode: enterpriseCode,
      );
    }

    if (discountType != null &&
        manualDiscountController.text.toDouble() != -1) {
      double discount = manualDiscountController.text.toDouble();

      if (discountType == "R\$") {
        selectedProduct.DiscountValue = discount;
        selectedProduct.AutomaticDiscountValue = null;
      } else {
        selectedProduct.DiscountValue = discount;
        selectedProduct.AutomaticDiscountValue = null;
      }

      selectedProduct.DiscountDescription = "Desconto manual";
      selectedProduct.DiscountPercentageOrValue =
          discountType == "%" ? "%" : "R\$";
      selectedProduct.DiscountDescription = "Desconto manual" +
          " - (${discount.toString().toBrazilianNumber()} ${discountType == "%" ? "%" : "R\$"}) por UN";
    } else {
      selectedProduct.DiscountDescription = null;
      selectedProduct.DiscountPercentageOrValue = null;
      selectedProduct.DiscountValue = 0;
      selectedProduct.AutomaticDiscountPercentageOrValue = null;
      selectedProduct.AutomaticDiscountValue = 0;
    }

    selectedProduct.TotalLiquid = quantity * (selectedProduct.value ?? 0);
    selectedProduct.quantity = quantity;

    await _updateCartInDatabase(
      updateToNeedProcessCartAgain: updateToNeedProcessCartAgain,
    );
    notifyListeners();
    return true;
  }

  double getTotalCartPrice(String enterpriseCode) {
    if (_cartProducts[enterpriseCode] == null) {
      return 0;
    } else {
      return _cartProducts[enterpriseCode]!.fold<double>(
        0,
        (previousValue, product) {
          double newPrice =
              previousValue + (product.value ?? 0) * product.quantity;

          double? discount = getProductDiscount(product);

          return newPrice - (discount ?? 0);
        },
      );
    }
  }

  void clearProducts() {
    _products.clear();
    notifyListeners();
  }

  Future<void> clearCart(String enterpriseCode) async {
    if (_cartProducts[enterpriseCode] != null) {
      _cartProducts[enterpriseCode]!.clear();
    }

    await _clearcustomers(enterpriseCode);
    clearProducts();
    await PrefsInstance.removeKey(PrefsKeys.cart);
    _needProcessCart = true;

    await getCustomers(
      context: NavigatorKey.key.currentState!.context,
      controllerText: "",
      enterpriseCode: enterpriseCode,
      configurationsProvider: ConfigurationsProvider(),
      searchOnlyDefaultCustomer: true,
    );

    notifyListeners();
  }

  removeProductFromCart({
    required int ProductPackingCode,
    required String enterpriseCode,
  }) async {
    // removedProduct = _cartProducts[enterpriseCode]!.firstWhere(
    //     (element) => element.ProductPackingCode == ProductPackingCode);

    indexOfRemovedProduct = _cartProducts[enterpriseCode]!.indexWhere(
        (element) => element.productPackingCode == ProductPackingCode);

    removedProduct =
        _cartProducts[enterpriseCode]!.removeAt(indexOfRemovedProduct!);

    // _cartProducts[enterpriseCode]!.removeWhere(
    //     (element) => element.ProductPackingCode == ProductPackingCode);

    await _updateCartInDatabase();

    notifyListeners();
  }

  restoreProductRemoved(String enterpriseCode) async {
    _cartProducts[enterpriseCode]!
        .insert(indexOfRemovedProduct!, removedProduct!);

    await _updateCartInDatabase();
    notifyListeners();
  }

  alreadyContainsProduct({
    required int ProductPackingCode,
    required String enterpriseCode,
  }) {
    bool alreadyContainsProduct = false;

    if (_cartProducts[enterpriseCode] == null) {
      return false;
    } else {
      _cartProducts[enterpriseCode]!.forEach((element) {
        if (ProductPackingCode == element.productPackingCode) {
          alreadyContainsProduct = true;
        }
      });

      return alreadyContainsProduct;
    }
  }

  String? getDiscountDescription(
    GetProductJsonModel product,
    String enterpriseCode,
  ) {
    return _cartProducts[enterpriseCode]!
        .firstWhere((element) =>
            element.productPackingCode == product.productPackingCode)
        .DiscountDescription;
  }

  double getTotalItensInCart({
    required int ProductPackingCode,
    required String enterpriseCode,
  }) {
    double atualQuantity = 0;

    if (_cartProducts[enterpriseCode] == null) {
      return 0;
    } else {
      _cartProducts[enterpriseCode]!.forEach((element) {
        // print(element["ProductPackingCode"]);
        if (element.productPackingCode == ProductPackingCode) {
          atualQuantity = element.quantity;
        }
      });

      return atualQuantity;
    }
  }

  Future<void> getRequests({
    required int enterpriseCode,
    required BuildContext context,
    bool? isConsultingAgain = false,
  }) async {
    if (_isLoadingRequests) return;
    _isLoadingRequests = true;
    _errorMessageRequests = "";
    _requests.clear();

    if (isConsultingAgain!) notifyListeners();

    try {
      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "simpleSearchValue": "",
          "enterpriseCode": enterpriseCode,
          "inclusiveTransfer": false,
          "inclusiveBuy": false,
          "inclusiveSale": true,
        },
        typeOfResponse: "GetRequestTypesJsonResponse",
        SOAPAction: "GetRequestTypesJson",
        serviceASMX: "CeltaRequestTypeService.asmx",
        typeOfResult: "GetRequestTypesJsonResult",
      );

      _errorMessageRequests = SoapRequestResponse.errorMessage;

      if (_errorMessageRequests == "") {
        _requests = (json.decode(SoapRequestResponse.responseAsString) as List)
            .map((e) => SaleRequestsModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _errorMessageRequests = DefaultErrorMessage.ERROR;
    }

    _isLoadingRequests = false;
    notifyListeners();
  }

  Future<void> processCart({
    required BuildContext context,
    required int enterpriseCode,
    required int requestTypeCode,
  }) async {
    _isLoadingProcessCart = true;
    _errorMessageProcessCart = "";
    notifyListeners();

    try {
      List processCartItems =
          SaleRequestProductProcessCartModel.cartProductsToProcessCart(
        _cartProducts[enterpriseCode.toString()]!,
      );

      var jsonBody = json.encode({
        "crossId": UserData.crossIdentity,
        "EnterpriseCode": enterpriseCode,
        "RequestTypeCode": requestTypeCode,
        "CovenantCode": getSelectedCovenantCode(enterpriseCode.toString()) ?? 0,
        "CustomerCode":
            getSelectedCustomer(enterpriseCode.toString())?.Code ?? 0,
        "Products": processCartItems,
      });

      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "json": jsonBody,
        },
        typeOfResponse: "ProcessCartResponse",
        SOAPAction: "ProcessCart",
        serviceASMX: "CeltaSaleRequestService.asmx",
        typeOfResult: "ProcessCartResult",
      );

      _errorMessageProcessCart = SoapRequestResponse.errorMessage;

      if (_errorMessageProcessCart == "") {
        final processedCart = SaleRequestProcessCartModel.fromJson(
          json.decode(SoapRequestResponse.responseAsString),
        );

        // _cartProducts[enterpriseCode.toString()] =
        if (processedCart.Products == null) {
          throw Exception();
        }

        _cartProducts[enterpriseCode.toString()] =
            processedCart.Products!.map((e) {
          int indexSameProductInCart = _cartProducts[enterpriseCode.toString()]!
              .indexWhere((element) =>
                  element.productPackingCode == e.ProductPackingCode);

          return GetProductJsonModel.fromProcessedCart(
            oldProduct: _cartProducts[enterpriseCode.toString()]![
                indexSameProductInCart],
            processedProductCart: e,
          );
        }).toList();

        _needProcessCart = false;
      } else {
        ShowSnackbarMessage.show(
          message: _errorMessageProcessCart,
          context: context,
        );
      }
    } catch (e) {
      //print("Erro para obter os preços do carrinho: $e");
      ShowSnackbarMessage.show(
        message: _errorMessageProcessCart,
        context: context,
      );
    }

    _isLoadingProcessCart = false;
    notifyListeners();
  }

  void updateSelectedCustomer({
    required int index,
    required bool value,
    required String enterpriseCode,
  }) async {
    _customers[enterpriseCode]?.forEach((element) {
      element.selected = false;
    });
    _customers[enterpriseCode]?[index].selected = value;

    _needProcessCart = true;

    _customers[enterpriseCode]?.forEach((element) {
      element.CustomerCovenants?.forEach((element) {
        element.isSelected =
            false; //tira a seleção de todos convênios se alterar o cleinte selecionado
      });
    });
    await _updateCustomerInDatabase();
    notifyListeners();
  }

  void updateSelectedCovenant({
    required String enterpriseCode,
    required int indexOfCustomer,
    required int indexOfCovenants,
    required bool isSelected,
  }) {
    _customers[enterpriseCode]?[indexOfCustomer]
        .CustomerCovenants
        ?.forEach((element) {
      element.isSelected = false;
    });

    _customers[enterpriseCode]?[indexOfCustomer]
        .CustomerCovenants?[indexOfCovenants]
        .isSelected = isSelected;

    _updateCustomerInDatabase();

    _needProcessCart = true;
  }

  Future<void> getCustomers({
    required BuildContext context,
    required String controllerText,
    required String enterpriseCode,
    required ConfigurationsProvider configurationsProvider,
    bool? searchOnlyDefaultCustomer = false,
  }) async {
// 1=ExactCnpjCpfNumber
// 2=ExactCode
// 3=ApproximateName
// 4=PersonalizedCode

    await _clearcustomers(enterpriseCode);

    final defaultCustomer = await _getCustomersOldSearch(
      searchTypeInt: 2, //exactCode
      controllerText: "-1", //consumidor
      enterpriseCode: enterpriseCode,
    );

    if (searchOnlyDefaultCustomer == true) {
      _customers[enterpriseCode] = [
        if (defaultCustomer != null) ...defaultCustomer,
      ];
      return;
    }

    int? codeValue = int.tryParse(controllerText);

    List<CustomerModel>? customers;
    if (codeValue == null) {
      customers = await _getCustomersOldSearch(
        searchTypeInt: 3, //ApproximateName
        controllerText: controllerText,
        enterpriseCode: enterpriseCode,
      );
    } else if (configurationsProvider.customerPersonalizedCode?.value == true) {
      customers = await _getCustomersOldSearch(
        searchTypeInt: 4, //PersonalizedCode
        controllerText: controllerText,
        enterpriseCode: enterpriseCode,
      );
    } else if (CPFValidator.isValid(codeValue.toString())) {
      customers = await _getCustomersOldSearch(
        searchTypeInt: 1, //ExactCnpjCpfNumber
        controllerText: controllerText,
        enterpriseCode: enterpriseCode,
      );
    } else {
      customers = await _getCustomersOldSearch(
        searchTypeInt: 2, //exactCode
        controllerText: controllerText,
        enterpriseCode: enterpriseCode,
      );
    }

    if (SoapRequestResponse.errorMessage != "") {
      ShowSnackbarMessage.show(
        message: SoapRequestResponse.errorMessage,
        context: context,
      );
    }

    _customers[enterpriseCode] = [
      if (defaultCustomer != null) ...defaultCustomer,
      if (customers != null) ...customers,
    ];

    await _updateCustomerInDatabase();
  }

  Future<List<CustomerModel>?> _getCustomersOldSearch({
    required int searchTypeInt,
    required String controllerText,
    required String enterpriseCode,
  }) async {
// 1=ExactCnpjCpfNumber
// 2=ExactCode
// 3=ApproximateName
// 4=PersonalizedCode

    _errorMessageCustomer = "";
    _isLoadingCustomer = true;
    notifyListeners();

    try {
      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "customerData": controllerText,
          "customerDataType": searchTypeInt,
        },
        typeOfResponse: "GetCustomerJsonResponse",
        SOAPAction: "GetCustomerJson",
        serviceASMX: "CeltaCustomerService.asmx",
        typeOfResult: "GetCustomerJsonResult",
      );

      _errorMessageCustomer = SoapRequestResponse.errorMessage;
      if (_errorMessageCustomer ==
          "O formato dos filtros informado está inválido") {
        await _getCustomersNewSearch(
          searchTypeInt: searchTypeInt,
          controllerText: controllerText,
          enterpriseCode: enterpriseCode,
        );
      }
      if (_errorMessageCustomer == "") {
        if (_customers[enterpriseCode] == null) {
          _customers[enterpriseCode] = [];
        }

        return (json.decode(SoapRequestResponse.responseAsString) as List)
            .map((e) => CustomerModel.fromJson(e))
            .cast<CustomerModel>()
            .toList();
      }
    } catch (e) {
      //print("Erro para obter os clientes: $e");
      _errorMessageCustomer = DefaultErrorMessage.ERROR;
      return null;
    } finally {
      _isLoadingCustomer = false;
      notifyListeners();
    }
    return null;
  }

  Future<void> _getCustomersNewSearch({
    required int searchTypeInt,
    required String controllerText,
    required String enterpriseCode,
  }) async {
// 1=ExactCnpjCpfNumber
// 2=ExactCode
// 3=ApproximateName
// 4=PersonalizedCode

    _errorMessageCustomer = "";

    try {
      await SoapRequest.soapPost(
        parameters: {
          "filters": json.encode({
            "crossIdentity": UserData.crossIdentity,
            "customerData": controllerText,
            "customerDataType": searchTypeInt,
            "enterpriseCode": enterpriseCode,
          }),
        },
        typeOfResponse: "GetCustomerJsonResponse",
        SOAPAction: "GetCustomerJson",
        serviceASMX: "CeltaCustomerService.asmx",
        typeOfResult: "GetCustomerJsonResult",
      );

      _errorMessageCustomer = SoapRequestResponse.errorMessage;
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> getProducts({
    required EnterpriseModel enterprise,
    required String controllerText,
    required BuildContext context,
    required ConfigurationsProvider configurationsProvider,
    required int requestTypeCode,
  }) async {
    _products.clear();
    _errorMessageProducts = "";
    _isLoadingProducts = true;
    notifyListeners();

    try {
      _products = await SoapHelper.getProductsJsonModel(
        enterprise: enterprise,
        searchValue: controllerText,
        configurationsProvider: configurationsProvider,
        routineTypeInt: 1,
        enterprisesCodes: [enterprise.Code],
      );

      _errorMessageProducts = SoapRequestResponse.errorMessage;
    } catch (e) {
      //print("Erro para obter os produtos: $e");
      _errorMessageProducts = DefaultErrorMessage.ERROR;
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  bool allProductsHasPrice({
    required BuildContext context,
    required String enterpriseCode,
  }) {
    bool allProductsHasPrice = true;

    if (_cartProducts[enterpriseCode] == null) {
      return false;
    } else {
      _cartProducts[enterpriseCode]!
                  .indexWhere((e) => e.value == null || e.value == 0) ==
              -1
          ? allProductsHasPrice = true
          : allProductsHasPrice = false;

      if (!allProductsHasPrice) {
        ShowSnackbarMessage.show(
          message: "Não é possível salvar produtos sem preço!",
          context: context,
        );
      }

      return allProductsHasPrice;
    }
  }

  Future<void> saveSaleRequest({
    required String enterpriseCode,
    required int requestTypeCode,
    required BuildContext context,
    required TextEditingController instructionsController,
    required TextEditingController observationsController,
  }) async {
    if (!allProductsHasPrice(
        context: context, enterpriseCode: enterpriseCode)) {
      return;
    }
    _errorMessageSaveSaleRequest = "";
    _isLoadingSaveSaleRequest = true;
    notifyListeners();

    FirebaseHelper.addSoapCallInFirebase(
      FirebaseCallEnum.saleRequestSave,
    );
    try {
      final selectedCustomer = getSelectedCustomer(enterpriseCode);

      final encodedJson = json.encode(
        SaleRequestProcessCartModel(
          crossId: UserData.crossIdentity,
          EnterpriseCode: enterpriseCode.toInt(),
          RequestTypeCode: requestTypeCode,
          SellerCode:
              0, //já vincula o vendedor se tiver um funcionário que é vendedor vinculado ao usuário
          CovenantCode: getSelectedCovenantCode(enterpriseCode) ?? 0,
          CustomerCode: selectedCustomer?.Code ?? 0,
          Instructions: instructionsController.text,
          Observations: observationsController.text,
          Products: _cartProducts[enterpriseCode]!
              .map((e) =>
                  SaleRequestProductProcessCartModel.fromGetProductJsonModel(e))
              .toList(),
        ).toJson(),
      );

      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "json": encodedJson,
          "printerName": "",
        },
        typeOfResponse: "InsertResponse",
        SOAPAction: "Insert",
        serviceASMX: "CeltaSaleRequestService.asmx",
      );

      _errorMessageSaveSaleRequest = SoapRequestResponse.errorMessage;

      if (_errorMessageSaveSaleRequest == "") {
        ShowSnackbarMessage.show(
          message: "O pedido foi salvo com sucesso!",
          context: context,
          backgroundColor: Theme.of(context).colorScheme.primary,
        );

        RegExp regex = RegExp(
            r'\((.*?)\)'); // Expressão regular para capturar o conteúdo entre parênteses

        Match? match = regex.firstMatch(SoapRequestResponse
            .responseAsString); // Encontrar o primeiro match na string

        if (match != null) {
          _lastSaleRequestSaved = SaleRequestCartModel(
            cartProducts: [..._cartProducts[enterpriseCode]!],
            selectedCustomer: selectedCustomer,
            lastSaleRequestSaved: match.group(1)!,
            enterpriseCode: enterpriseCode,
            instructions: instructionsController.text,
            observations: observationsController.text,
          );

          await PrefsInstance.setObject(
            prefsKeys: PrefsKeys.saleRequestLastSavedCart,
            object: _lastSaleRequestSaved?.toJson(),
          );
        } else {
          //print("Nenhum conteúdo entre parênteses encontrado.");
        }

        instructionsController.clear();
        observationsController.clear();
        await clearCart(enterpriseCode);
        await _clearcustomers(enterpriseCode);
        await getCustomers(
          context: context,
          controllerText: "",
          enterpriseCode: enterpriseCode,
          configurationsProvider: ConfigurationsProvider(),
          searchOnlyDefaultCustomer: true,
        );
      } else {
        _isLoadingSaveSaleRequest = false;

        ShowSnackbarMessage.show(
          message: _errorMessageSaveSaleRequest,
          context: context,
        );
      }
    } catch (e) {
      //print("Erro para salvar o pedido: $e");
      _errorMessageSaveSaleRequest = DefaultErrorMessage.ERROR;
      ShowSnackbarMessage.show(
        message: _errorMessageSaveSaleRequest,
        context: context,
      );
    } finally {
      _isLoadingSaveSaleRequest = false;
      notifyListeners();
    }
  }

  double? getProductDiscount(GetProductJsonModel product) {
    if (product.AutomaticDiscountValue == null &&
            product.DiscountValue == null ||
        (product.AutomaticDiscountValue == 0 && product.DiscountValue == 0)) {
      return null;
    } else if (product.DiscountValue != null &&
        product.DiscountValue! > 0 &&
        product.DiscountPercentageOrValue == "R\$") {
      return product.DiscountValue! * product.quantity;
    } else if (product.DiscountValue != null &&
        product.DiscountValue! > 0 &&
        product.DiscountPercentageOrValue == "%") {
      return (product.value! * product.quantity) *
          (product.DiscountValue! / 100);
    } else {
      return product.AutomaticDiscountValue;
    }
  }

  Future<void> verifyUserCanChangePrices(
    EnterpriseProvider enterpriseProvider,
  ) async {
    if (enterpriseProvider.bsDate != null &&
        enterpriseProvider.bsDate!.isBefore(DateTime(2025, 2, 5))) {
      _userCanChangePrices = false;
    } else {
      _userCanChangePrices = await SoapHelper.userCanAccessResource(
        resourceCode: 666,
        routineInt: 0,
      );
    }
  }

  Future<void> getSaleRequestByCode({
    required int enterpriseCode,
    required String saleRequestCode,
  }) async {
    _isLoadingRequests = true;

    try {
      SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "enterpriseCode": enterpriseCode,
          "saleRequestCode": saleRequestCode,
        },
        typeOfResponse: "GetSaleRequestResponse",
        SOAPAction: "GetSaleRequest",
        serviceASMX: "CeltaSaleRequestService.asmx",
        typeOfResult: "GetSaleRequestResult",
      );

      SoapRequestResponse.errorMessage;
      SoapRequestResponse.responseAsMap;
      SoapRequestResponse.responseAsString;
    } catch (e) {
      _errorMessageRequests = DefaultErrorMessage.ERROR;
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  Future<void> restoreLastSavedSaleRequest() async {
    await PrefsInstance.getString(PrefsKeys.saleRequestLastSavedCart)
        .then((value) {
      if (value.isNotEmpty) {
        _lastSaleRequestSaved =
            SaleRequestCartModel.fromJson(jsonDecode(value));
      }
    });
  }

  Future<void> printPdf(BuildContext context, String ip) async {
    _isPrinting = true;
    notifyListeners();

    await PrefsInstance.setString(
      prefsKeys: PrefsKeys.ipPrintSaleRequest,
      value: ip,
    );

    await ReceiptPdfGenerator.printReceiptDirectly(
      _lastSaleRequestSaved!,
      this,
      ip,
      context,
    );

    _isPrinting = false;
    notifyListeners();
  }
}
