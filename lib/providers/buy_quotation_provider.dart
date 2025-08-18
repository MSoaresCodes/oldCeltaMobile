import 'dart:convert';

import 'package:flutter/material.dart';

import '../api/api.dart';
import '../components/components.dart';

import '../Models/models.dart';
import '../utils/utils.dart';
import 'providers.dart';

class BuyQuotationProvider with ChangeNotifier {
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<GetProductJsonModel> _searchedProductsToFilter = [];
  List<GetProductJsonModel> get searchedProductsToFilter =>
      [..._searchedProductsToFilter];
  GetProductJsonModel? _productToFilter;
  GetProductJsonModel? get productToFilter => _productToFilter;

  List<SupplierModel> _searchedSuppliers = [];
  List<SupplierModel> get searchedSuppliers => [..._searchedSuppliers];
  SupplierModel? _selectedSupplier;
  SupplierModel? get selectedSupplier => _selectedSupplier;

  List<BuyerModel> _searchedBuyers = [];
  List<BuyerModel> get searchedBuyers => [..._searchedBuyers];
  BuyerModel? _selectedBuyer;
  BuyerModel? get selectedBuyer => _selectedBuyer;

  List<BuyQuotationModel?> _buyQuotations = [];
  List<BuyQuotationModel?> get buyQuotations => [..._buyQuotations];
  BuyQuotationModel? _selectedBuyQuotation;
  BuyQuotationModel? get selectedBuyQuotation => _selectedBuyQuotation;

  List<EnterpriseModel> _allEnterprises = [];
  List<EnterpriseModel> get allEnterprises => [..._allEnterprises];

  List<BuyQuotationProductsModel> _productsWithNewValues = [];
  List<BuyQuotationProductsModel> get productsWithNewValues =>
      [..._productsWithNewValues];

  List<GetProductJsonModel> _searchedProductsToAdd = [];
  List<GetProductJsonModel> get searchedProductsToAdd =>
      [..._searchedProductsToAdd];

  List<GetProductJsonModel> _selectedsProductsToAdd = [];
  List<GetProductJsonModel> get selectedsProductsToAdd =>
      _selectedsProductsToAdd;

  List<BuyerModel> _buyers = [];
  List<BuyerModel> get buyers => [..._buyers];

  void doOnPopScreen() {
    _searchedBuyers.clear();
    _searchedProductsToFilter.clear();
    _searchedSuppliers.clear();
    _selectedBuyer = null;
    _productToFilter = null;
    _selectedSupplier = null;
    _searchedProductsToAdd.clear();
  }

  Future<bool> insertUpdateBuyQuotation({
    required bool isInserting,
    required TextEditingController observationsController,
  }) async {
    _isLoading = true;
    _errorMessage = "";

    FirebaseHelper.addSoapCallInFirebase(FirebaseCallEnum.buyQuotation);

    try {
      List<BuyQuotationProductsModel> productWithCorrectIsInsertingValue =
          _productsWithNewValues.map((e) {
        int? indexProductInBuyQuotation = _selectedBuyQuotation?.Products
            ?.indexWhere((x) => x.Product?.plu == e.Product?.plu);

        return BuyQuotationProductsModel.fromJson(
          e.toJson(
              isInserting: indexProductInBuyQuotation == null ||
                  indexProductInBuyQuotation == -1),
        );
      }).toList();

      int getEnterpriseCode(EnterpriseModel enterprise) {
        final equal = _selectedBuyQuotation?.Enterprises
            ?.where((e) => e.enterprise.Code == enterprise.Code)
            .first;

        if (equal != null) {
          return equal.Code!;
        }
        return 0;
      }

      final filters = BuyQuotationModel(
        CrossIdentity: UserData.crossIdentity,
        Code: _selectedBuyQuotation?.Code,
        DateOfCreation: _selectedBuyQuotation?.DateOfCreation ??
            DateTime.now().toIso8601String(),
        DateOfLimit: _selectedBuyQuotation?.DateOfLimit,
        PersonalizedCode: _selectedBuyQuotation?.PersonalizedCode,
        Observations: observationsController
            .text, //quando acessa a página já altero o controller pra ser igual às observações da cotação
        Buyer: _selectedBuyer,
        Enterprises: _allEnterprises
            .where((e) => e.isSelected)
            .map((e) => BuyQuotationEnterpriseModel(
                  Code: getEnterpriseCode(e),
                  enterprise: BuyQuotationEnterprise(
                    PersonalizedCode: e.PersonalizedCode.toString(),
                    Name: e.Name,
                    CnpjNumber: e.CnpjNumber.toString(),
                    InscriptionNumber: e.InscriptionNumber,
                    Code: e.Code,
                  ),
                ))
            .toList(),
        Products: productWithCorrectIsInsertingValue,
      ).toJson(isInserting: isInserting);

      await SoapRequest.soapPost(
        parameters: {
          "json": json.encode(filters),
        },
        typeOfResponse: "InsertUpdateBuyQuotationResponse",
        SOAPAction: "InsertUpdateBuyQuotation",
        serviceASMX: "CeltaBuyRequestService.asmx",
        typeOfResult: "InsertUpdateBuyQuotationResult",
      );

      if (SoapRequestResponse.errorMessage != "") {
        ShowSnackbarMessage.show(
          message: SoapRequestResponse.errorMessage,
          context: NavigatorKey.key.currentContext!,
        );
        return false;
      } else {
        ShowSnackbarMessage.show(
          message: "Alteração realizada com sucesso",
          context: NavigatorKey.key.currentContext!,
          backgroundColor:
              Theme.of(NavigatorKey.key.currentContext!).colorScheme.primary,
        );
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
      ShowSnackbarMessage.show(
        message: SoapRequestResponse.errorMessage,
        context: NavigatorKey.key.currentContext!,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getBuyQuotation({
    required BuildContext context,
    required String valueToSearch,
    required bool searchByPersonalizedCode,
    required int enterpriseCode,
    DateTime? initialDateOfCreation,
    DateTime? finalDateOfCreation,
    DateTime? initialDateOfLimit,
    DateTime? finalDateOfLimit,
    int? supplierCode,
    // int? buyerCode,
    bool? inclusiveExpired,
    bool? complete = false,
    bool? searchAll,
  }) async {
    _isLoading = true;
    _errorMessage = "";
    _selectedBuyQuotation = null;
    if (complete == false) {
      _buyQuotations.clear();
    }

    notifyListeners();

    try {
      final filters = {
        "CrossIdentity": UserData.crossIdentity,
        "Complete": complete,
        "Data": valueToSearch.isEmpty ? "%" : valueToSearch,
        "DataType": searchByPersonalizedCode
            ? 2 // 2-Codigo personalizado
            : 1, //1-Codigo
        "InitialDateOfCreation": initialDateOfCreation?.toIso8601String(),
        "FinalDateOfCreation": finalDateOfCreation?.toIso8601String(),
        "InitialDateOfLimit": initialDateOfLimit?.toIso8601String(),
        "FinalDateOfLimit": finalDateOfLimit?.toIso8601String(),
        "ProductCode": searchAll == true ? null : _productToFilter?.productCode,
        "ProductPackingCode":
            searchAll == true ? null : _productToFilter?.productPackingCode,
        "SupplierCode": supplierCode,
        "BuyerCode":
            null, //se mandar o código 0, leva em consideração o funcionário vinculado ao usuário. Vou deixar sem esse filtro
        "EnterpriseCode": enterpriseCode,
        "InclusiveExpired": inclusiveExpired == true,
      };
      await SoapRequest.soapPost(
        parameters: {
          "filters": json.encode(filters),
        },
        typeOfResponse: "GetBuyQuotationJsonResponse",
        SOAPAction: "GetBuyQuotationJson",
        serviceASMX: "CeltaBuyRequestService.asmx",
        typeOfResult: "GetBuyQuotationJsonResult",
      );

      _errorMessage = SoapRequestResponse.errorMessage;

      if (_errorMessage != "") {
        ShowSnackbarMessage.show(
          message: _errorMessage,
          context: context,
        );
      } else {
        if (complete == true) {
          _selectedBuyQuotation =
              (json.decode(SoapRequestResponse.responseAsString) as List)
                  .map((e) => BuyQuotationModel.fromJson(e))
                  .toList()
                  .first;
        } else {
          _buyQuotations = (json.decode(
                      SoapRequestResponse.responseAsString.removeBreakLines())
                  as List)
              .map((e) => BuyQuotationModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = DefaultErrorMessage.ERROR;
      ShowSnackbarMessage.show(
        message: _errorMessage,
        context: context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProductToFilter({
    required EnterpriseModel enterprise,
    required TextEditingController searchProductController,
    required ConfigurationsProvider configurationsProvider,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = "";
    _searchedProductsToFilter.clear();
    _productToFilter = null;
    notifyListeners();

    try {
      _searchedProductsToFilter = await SoapHelper.getProductsJsonModel(
        enterprise: enterprise,
        searchValue: searchProductController.text,
        configurationsProvider: configurationsProvider,
        enterprisesCodes: [enterprise.Code],
        routineTypeInt: 9,
      );

      _errorMessage = SoapRequestResponse.errorMessage;

      if (_errorMessage != "") {
        ShowSnackbarMessage.show(
          message: _errorMessage,
          context: context,
        );
      } else {
        _searchedProductsToFilter =
            (json.decode(SoapRequestResponse.responseAsString) as List)
                .map((e) => GetProductJsonModel.fromJson(e))
                .toList();

        if (_searchedProductsToFilter.length == 1) {
          updateSelectedProductToFilter(_searchedProductsToFilter[0]);
        }
      }

      searchProductController.text = "";
    } catch (e) {
      ShowSnackbarMessage.show(
        message: e.toString(),
        context: context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSelectedProductToFilter(GetProductJsonModel? product) {
    _searchedProductsToFilter.clear();
    _productToFilter = product;
    notifyListeners();
  }

  void updateSelectedSupplier(SupplierModel? supplier) {
    _searchedSuppliers.clear();
    _selectedSupplier = supplier;
    notifyListeners();
  }

  Future<void> searchSupplier({
    required BuildContext context,
    required TextEditingController searchController,
  }) async {
    _isLoading = false;
    _errorMessage = "";
    _searchedSuppliers.clear();
    _selectedSupplier = null;
    notifyListeners();

    Map jsonGetSupplier = {
      "CrossIdentity": UserData.crossIdentity,
      "SearchValue": searchController.text,
      "RoutineInt": 9,
    };

    try {
      await SoapRequest.soapPost(
        parameters: {
          "filters": json.encode(jsonGetSupplier),
        },
        serviceASMX: "CeltaSupplierService.asmx",
        typeOfResponse: "GetSupplierJsonResponse",
        SOAPAction: "GetSupplierJson",
        typeOfResult: "GetSupplierJsonResult",
      );

      _errorMessage = SoapRequestResponse.errorMessage;

      if (_errorMessage != "") {
        ShowSnackbarMessage.show(message: _errorMessage, context: context);
      } else {
        _searchedSuppliers =
            (json.decode(SoapRequestResponse.responseAsString) as List)
                .map((e) => SupplierModel.fromJson(e))
                .toList();
        if (_searchedSuppliers.length == 1) {
          _selectedSupplier = _searchedSuppliers[0];
        }
      }
    } catch (e) {
      ShowSnackbarMessage.show(message: e.toString(), context: context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSelectedBuyer(BuyerModel? buyer) {
    _selectedBuyer = buyer;
    notifyListeners();
  }

  Future<void> searchBuyer(BuildContext context) async {
    _isLoading = false;
    _errorMessage = "";
    _searchedBuyers.clear();
    _selectedBuyer = null;
    notifyListeners();

    try {
      _searchedBuyers = await SoapHelper.getBuyers();

      if (SoapRequestResponse.errorMessage != "") {
        ShowSnackbarMessage.show(
          message: SoapRequestResponse.errorMessage,
          context: context,
        );
      } else if (_searchedBuyers.length == 1) {
        _selectedBuyer = _searchedBuyers[0];
      }
    } catch (e) {
      ShowSnackbarMessage.show(message: e.toString(), context: context);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSelectedsValues({
    required EnterpriseProvider enterpriseProvider,
    required bool isInserting,
  }) {
    _allEnterprises.clear();
    _productsWithNewValues.clear();

    if (isInserting) {
      _allEnterprises
          .addAll(enterpriseProvider.enterprises.map((e) => EnterpriseModel(
                isSelected: true,
                Code: e.Code,
                PersonalizedCode: e.PersonalizedCode,
                Name: e.Name,
                CnpjNumber: e.CnpjNumber,
                CodigoInternoVendaMobile_ModeloPedido:
                    e.CodigoInternoVendaMobile_ModeloPedido,
                useEcommerceSale: e.useEcommerceSale,
                useRetailSale: e.useRetailSale,
                useWholeSale: e.useWholeSale,
                EnterpriseParticipateEnterpriseGroup:
                    e.EnterpriseParticipateEnterpriseGroup,
                ProductCodeSizeOfBalanceLabel: e.ProductCodeSizeOfBalanceLabel,
                ProductCodeWithCheckerDigit: e.ProductCodeWithCheckerDigit,
                InscriptionNumber: e.InscriptionNumber,
              )));
      _selectedBuyer = null;
      _selectedBuyQuotation = null;
    } else {
      if (_selectedBuyQuotation?.Enterprises != null &&
          _selectedBuyQuotation?.Enterprises!.isNotEmpty == true) {
        final enterprises =
            _selectedBuyQuotation!.Enterprises!.map((buyQuotationEnterprise) {
          return enterpriseProvider.enterprises.firstWhere(
            (e) =>
                e.CnpjNumber.toString() ==
                buyQuotationEnterprise.enterprise.CnpjNumber
                    ?.toInt()
                    .toString(),
          );
        }).toList();

        _allEnterprises.addAll(enterprises.map((e) => EnterpriseModel(
              Code: e.Code,
              PersonalizedCode: e.PersonalizedCode,
              Name: e.Name,
              CnpjNumber: e.CnpjNumber,
              CodigoInternoVendaMobile_ModeloPedido:
                  e.CodigoInternoVendaMobile_ModeloPedido,
              useEcommerceSale: e.useEcommerceSale,
              useRetailSale: e.useRetailSale,
              useWholeSale: e.useWholeSale,
              EnterpriseParticipateEnterpriseGroup:
                  e.EnterpriseParticipateEnterpriseGroup,
              ProductCodeSizeOfBalanceLabel: e.ProductCodeSizeOfBalanceLabel,
              ProductCodeWithCheckerDigit: e.ProductCodeWithCheckerDigit,
              InscriptionNumber: e.InscriptionNumber,
              isSelected: true,
            )));

        int indexOfBuyer = _buyers.indexWhere(
          (e) => e.Code == _selectedBuyQuotation?.Buyer?.Code,
        );
        if (indexOfBuyer != -1) {
          _selectedBuyer = _buyers[indexOfBuyer];
        }
      }

      if (_selectedBuyQuotation?.Products != null &&
          _selectedBuyQuotation?.Products!.isNotEmpty == true) {
        _productsWithNewValues =
            _selectedBuyQuotation!.Products!.map((product) => product).toList();
      }
    }

    notifyListeners();
  }

  void updateEnterpriseIsSelected(EnterpriseModel enterprise) {
    int enterpriseIndex = _allEnterprises
        .indexWhere((e) => e.CnpjNumber == enterprise.CnpjNumber);

    final oldEnterprise = _allEnterprises[enterpriseIndex];
    oldEnterprise.isSelected = !oldEnterprise.isSelected;
    notifyListeners();
  }

  void updateProductQuantity({
    required List<double> quantitys,
    required int productIndex,
  }) {
    final selectedProduct = _productsWithNewValues[productIndex];

    List<ProductEnterprise> newProductsEnterprise = [];

    for (var x = 0; x < quantitys.length; x++) {
      newProductsEnterprise.add(
        ProductEnterprise(
          Code: selectedProduct.ProductEnterprises?[x].Code,
          EnterpriseCode: selectedProduct.ProductEnterprises?[x].EnterpriseCode,
          Quantity: quantitys[x],
        ),
      );
    }

    _productsWithNewValues[productIndex] = BuyQuotationProductsModel(
      Code: selectedProduct.Code,
      Product: selectedProduct.Product,
      ProductEnterprises: newProductsEnterprise,
    );
  }

  Future<void> searchProductsToAdd({
    required EnterpriseModel enterprise,
    required TextEditingController searchProductController,
    required ConfigurationsProvider configurationsProvider,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _errorMessage = "";
    _searchedProductsToAdd.clear();
    notifyListeners();

    try {
      _searchedProductsToAdd = await SoapHelper.getProductsJsonModel(
        enterprise: enterprise,
        searchValue: searchProductController.text,
        configurationsProvider: configurationsProvider,
        enterprisesCodes: [enterprise.Code],
        routineTypeInt: 9,
      );

      _errorMessage = SoapRequestResponse.errorMessage;

      if (_errorMessage != "") {
        ShowSnackbarMessage.show(
          message: _errorMessage,
          context: context,
        );
      } else {
        _searchedProductsToAdd =
            (json.decode(SoapRequestResponse.responseAsString) as List)
                .map((e) => GetProductJsonModel.fromJson(e))
                .toList();

        if (_searchedProductsToAdd.length == 1) {
          insertNewProductInProductsWithNewValues(
            products: _searchedProductsToAdd,
            enterprise: enterprise,
            configurationsProvider: configurationsProvider,
          );
        }
      }

      searchProductController.text = "";
    } catch (e) {
      ShowSnackbarMessage.show(
        message: e.toString(),
        context: context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void insertNewProductInProductsWithNewValues({
    required List<GetProductJsonModel> products,
    required EnterpriseModel enterprise,
    required ConfigurationsProvider configurationsProvider,
  }) async {
    products.forEach((product) {
      if (_productsWithNewValues
          .map((e) => e.Product?.plu)
          .contains(product.plu)) {
        ShowSnackbarMessage.show(
          message:
              "O produto ${product.name} de PLU (${product.plu}) já foi adicionado",
          context: NavigatorKey.key.currentState!.context,
        );
        return;
      }

      final enterpriseCodes = _allEnterprises
          .where((e) => e.isSelected)
          .map((e) => e.Code)
          .toList();

      _productsWithNewValues.insert(
        0,
        BuyQuotationProductsModel(
          Code: 0,
          Product: product,
          ProductEnterprises: enterpriseCodes
              .map(
                (e) => ProductEnterprise(
                  Code: 0,
                  EnterpriseCode: e,
                  Quantity: 0,
                ),
              )
              .toList(),
        ),
      );
    });
  }

  void removeProductWithNewValue(int index) {
    _productsWithNewValues.removeAt(index);
    notifyListeners();
  }

  Future<void> getBuyers({
    required BuildContext context,
  }) async {
    _errorMessage = "";
    _isLoading = true;
    _buyers.clear();
    notifyListeners();

    try {
      _buyers = await SoapHelper.getBuyers();

      _errorMessage = SoapRequestResponse.errorMessage;

      if (_errorMessage != "") {
        ShowSnackbarMessage.show(
          message:
              "Ocorreu um erro não esperado para consultar os compradores. Verifique a sua internet",
          context: context,
        );
      }
    } catch (e) {
      //print("Erro para obter os compradores: $e");
      _errorMessage = DefaultErrorMessage.ERROR;
      ShowSnackbarMessage.show(
        message: _errorMessage,
        context: context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSelectedBuyQuotation(BuyQuotationModel? buyQuotation) {
    _selectedBuyQuotation = buyQuotation;
  }

  void updateDateOfLimit(DateTime? date) {
    final updated = BuyQuotationModel(
      DateOfLimit: date?.toIso8601String(),
      CrossIdentity: _selectedBuyQuotation?.CrossIdentity,
      Code: _selectedBuyQuotation?.Code,
      DateOfCreation: _selectedBuyQuotation?.DateOfCreation,
      PersonalizedCode: _selectedBuyQuotation?.PersonalizedCode,
      Observations: _selectedBuyQuotation?.Observations,
      Buyer: _selectedBuyQuotation?.Buyer,
      Enterprises: _selectedBuyQuotation?.Enterprises,
      Products: _selectedBuyQuotation?.Products,
    );

    _selectedBuyQuotation = updated;
  }

  void addOrRemoveSelectedProduct(GetProductJsonModel product) {
    if (_selectedsProductsToAdd.contains(product)) {
      _selectedsProductsToAdd.remove(product);
    } else {
      _selectedsProductsToAdd.add(product);
    }
    notifyListeners();
  }
}
