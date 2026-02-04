import 'dart:convert';

import 'package:flutter/material.dart';

import '../Models/models.dart';
import '../api/api.dart';
import '../../components/components.dart';
import '../../providers/providers.dart';
import '../utils/utils.dart';

class ResearchPricesProvider with ChangeNotifier {
  bool _isLoadingGetResearchPrices = false;
  bool get isLoadingResearchPrices => _isLoadingGetResearchPrices;
  String _errorGetResearchPrices = "";
  String get errorGetResearchPrices => _errorGetResearchPrices;
  final List<ResearchPricesResearchModel> _researchPrices = [];
  List<ResearchPricesResearchModel> get researchPrices => [..._researchPrices];
  int get researchPricesCount => _researchPrices.length;

  bool _isLoadingAddOrUpdateOfResearch = false;
  bool get isLoadingAddOrUpdateOfResearch => _isLoadingAddOrUpdateOfResearch;
  String _errorAddOrUpdateOfResearch = "";
  String get errorAddOrUpdateOfResearch => _errorAddOrUpdateOfResearch;

  bool _isLoadingAssociateConcurrentToResearch = false;
  bool get isLoadingAssociateConcurrentToResearch =>
      _isLoadingAssociateConcurrentToResearch;
  String _errorAssociateConcurrentToResearch = "";
  String get errorAssociateConcurrentToResearch =>
      _errorAssociateConcurrentToResearch;

  bool _isLoadingAddOrUpdateConcurrents = false;
  bool get isLoadingAddOrUpdateConcurrents => _isLoadingAddOrUpdateConcurrents;
  String _errorAddOrUpdateConcurrents = "";
  String get errorAddOrUpdateConcurrents => _errorAddOrUpdateConcurrents;

  bool _isLoadingGetConcurrents = false;
  bool get isLoadingGetConcurrents => _isLoadingGetConcurrents;
  String _errorGetConcurrents = "";
  String get errorGetConcurrents => _errorGetConcurrents;
  List<ResearchPricesConcurrentsModel> _concurrents = [];
  List<ResearchPricesConcurrentsModel> get concurrents => [..._concurrents];
  int get concurrentsCount => _concurrents.length;
  FocusNode concurrentsFocusNode = FocusNode();

  List<ResearchPricesProductsModel> _associatedsProducts = [];
  List<ResearchPricesProductsModel> get associatedsProducts =>
      [..._associatedsProducts];
  int get associatedsProductsCount => _associatedsProducts.length;
  List<ResearchPricesProductsModel> _notAssociatedsProducts = [];
  List<ResearchPricesProductsModel> get notAssociatedProducts =>
      [..._notAssociatedsProducts];
  int get notAssociatedProductsCount => _notAssociatedsProducts.length;
  bool _isLoadingGetProducts = false;
  bool get isLoadingGetProducts => _isLoadingGetProducts;

  String _errorGetAssociatedsProducts = "";
  String get errorGetAssociatedsProducts => _errorGetAssociatedsProducts;
  String _errorGetNotAssociatedsProducts = "";
  String get errorGetNotAssociatedsProducts => _errorGetNotAssociatedsProducts;

  bool _isLoadingInsertConcurrentPrices = false;
  bool get isLoadingInsertConcurrentPrices => _isLoadingInsertConcurrentPrices;
  String _errorInsertConcurrentPrices = "";
  String get errorInsertConcurrentPrices => _errorInsertConcurrentPrices;

  ResearchPricesResearchModel? _selectedResearch;
  ResearchPricesResearchModel? get selectedResearch => _selectedResearch;
  updateSelectedResearch(ResearchPricesResearchModel? research) {
    _selectedResearch = research;
  }

  ResearchPricesConcurrentsModel? _selectedConcurrent;
  ResearchPricesConcurrentsModel? get selectedConcurrent => _selectedConcurrent;
  void updateSelectedConcurrent(ResearchPricesConcurrentsModel? concurrent) {
    _selectedConcurrent = concurrent;
  }

  int selectedIndexAssociatedProducts = -1;
  int selectedIndexNotAssociatedProducts = -1;

  void clearResearchPrices() {
    _researchPrices.clear();
    _errorGetResearchPrices = "";
    _isLoadingGetResearchPrices = false;
    updateSelectedResearch(null);
    notifyListeners();
  }

  void clearConcurrents() {
    _concurrents.clear();
    _errorAddOrUpdateConcurrents = "";
    _errorGetConcurrents = "";
    _isLoadingAddOrUpdateConcurrents = false;
    updateSelectedConcurrent(null);
  }

  bool _concurrentAlreadyIsAssociated() {
    return _selectedResearch!.Concurrents.contains(_selectedConcurrent);
  }

  void _addConcurrentInResearchs() {
    int index = _researchPrices.indexOf(_selectedResearch!);
    if (index != -1) {
      _researchPrices[index].Concurrents.add(_selectedConcurrent!);
    }
  }

  Future<void> associateConcurrentToResearchPrice({
    required BuildContext context,
    required int? enterpriseCode,
  }) async {
    if (_concurrentAlreadyIsAssociated()) return;
    _isLoadingAssociateConcurrentToResearch = true;
    _errorAssociateConcurrentToResearch = "";
    notifyListeners();

    try {
      await SoapRequest.soapPost(
        parameters: {
          "json": json.encode(
            {
              "CrossIdentity": UserData.crossIdentity,
              "Code": _selectedResearch!.Code,
              "IsAssociatingConcurrents": true,
              "Concurrents": [
                {
                  "ResearchOfPriceCode": _selectedResearch!.Code,
                  "ConcurrentCode": _selectedConcurrent!.ConcurrentCode,
                  "Observation": _selectedConcurrent?.Observation,
                }
              ],
            },
          ),
        },
        typeOfResponse: "InsertUpdateResearchOfPriceResponse",
        SOAPAction: "InsertUpdateResearchOfPrice",
        serviceASMX: "CeltaResearchOfPriceService.asmx",
        typeOfResult: "InsertUpdateResearchOfPriceResult",
      );

      _errorAssociateConcurrentToResearch = SoapRequestResponse.errorMessage;

      if (_errorAssociateConcurrentToResearch.isNotEmpty) {
        ShowSnackbarMessage.show(
          message: _errorAssociateConcurrentToResearch,
          context: context,
        );
      } else {
        _addConcurrentInResearchs();
      }
    } catch (e) {
      // print(e.toString());
      _errorAssociateConcurrentToResearch = SoapRequestResponse.errorMessage;
    }

    _isLoadingAssociateConcurrentToResearch = false;
    notifyListeners();
  }

  Future<void> getResearchPrices({
    required BuildContext context,
    required bool notifyListenersFromUpdate,
    required int enterpriseCode,
    required String searchText,
  }) async {
    _researchPrices.clear();
    _errorGetResearchPrices = "";
    _isLoadingGetResearchPrices = true;
    if (notifyListenersFromUpdate) notifyListeners();

    final jsonRequest = {
      "CrossIdentity": UserData.crossIdentity,
      "EnterpriseCode": enterpriseCode,
      // "InitialCreationDate": "0001-01-01T00:00:00",
      // "FinalCreationDate": DateTime.now().toIso8601String(),
      "SearchValue":
          int.tryParse(searchText) != null ? int.parse(searchText) : searchText,

      "SearchTypeInt": int.tryParse(searchText) != null ? 1 : 2,
    };

    try {
      await SoapRequest.soapPost(
        parameters: {"json": json.encode(jsonRequest)},
        typeOfResponse: "GetResearchOfPriceJsonResponse",
        SOAPAction: "GetResearchOfPriceJson",
        serviceASMX: "CeltaResearchOfPriceService.asmx",
        typeOfResult: "GetResearchOfPriceJsonResult",
      );
      SoapRequestResponse.responseAsMap;
      SoapRequestResponse.responseAsString;
      _errorGetResearchPrices = SoapRequestResponse.errorMessage;
    } catch (e) {
      _errorGetResearchPrices = DefaultErrorMessage.ERROR;
    }

    if (_errorGetResearchPrices == "") {
      _researchPrices.addAll(
        ResearchPricesResearchModel.convertResultToResearchModel(),
      );
    }

    _isLoadingGetResearchPrices = false;
    notifyListeners();
  }

  void _updateLocalSelectedResearch({
    String? name,
    String? observation,
  }) {
    int index = _researchPrices.indexOf(_selectedResearch!);

    if (index != -1) {
      _researchPrices[index].Name = name;
      _researchPrices[index].Observation = observation;
    }
  }

  Future<void> addOrUpdateResearchOfPrice({
    required BuildContext context,
    required int enterpriseCode,
    String? observation,
    String? name,
  }) async {
    _isLoadingAddOrUpdateOfResearch = true;
    _errorAddOrUpdateOfResearch = "";
    notifyListeners();

    try {
      await SoapRequest.soapPost(
        parameters: {
          "json": json.encode(
            {
              "CrossIdentity": UserData.crossIdentity,
              "Code": _selectedResearch == null
                  ? 0 //0 pra cadastrar um novo
                  : _selectedResearch?.Code,
              "EnterpriseCode": enterpriseCode,
              "Name": name,
              "Observation": observation,
            },
          ),
        },
        typeOfResponse: "InsertUpdateResearchOfPriceResponse",
        SOAPAction: "InsertUpdateResearchOfPrice",
        serviceASMX: "CeltaResearchOfPriceService.asmx",
        typeOfResult: "InsertUpdateResearchOfPriceResult",
      );

      _errorAddOrUpdateOfResearch = SoapRequestResponse.errorMessage;

      if (_errorAddOrUpdateOfResearch.isNotEmpty) {
        ShowSnackbarMessage.show(
          message: _errorAddOrUpdateOfResearch,
          context: context,
        );
      } else if (_selectedResearch != null) {
        //só precisa alterar a pesquisa se houver alguma selecionada. Se não
        //houver uma pesquisa selecionada, significa que está cadastrando uma
        //nova e por isso não precisa alterar
        _updateLocalSelectedResearch(name: name, observation: observation);
      } else if (_selectedResearch == null) {
        _researchPrices.add(ResearchPricesResearchModel.fromJson(
          json.decode(SoapRequestResponse.responseAsString),
        ));
      }
    } catch (e) {
      // print(e.toString());
      _errorAddOrUpdateOfResearch = SoapRequestResponse.errorMessage;
    }

    _isLoadingAddOrUpdateOfResearch = false;
    notifyListeners();
  }

  void _updateLocalSelectedConcurrent({
    String? name,
    String? observation,
    AddressModel? address,
  }) {
    int index = _concurrents.indexOf(_selectedConcurrent!);
    if (index == -1) return;

    final oldConcurrent = _concurrents[index];
    _concurrents[index] = ResearchPricesConcurrentsModel(
      Name: name,
      Observation: observation,
      Address: address,
      ConcurrentCode: oldConcurrent.ConcurrentCode,
    );
  }

  Future<void> addOrUpdateConcurrent({
    required BuildContext context,
    required String concurrentName,
    required String? observation,
  }) async {
    _errorAddOrUpdateConcurrents = "";
    _isLoadingAddOrUpdateConcurrents = true;
    notifyListeners();

    Map jsonBody = {
      "ConcurrentCode":
          _selectedConcurrent != null ? _selectedConcurrent!.ConcurrentCode : 0,
      "CrossIdentity": UserData.crossIdentity,
      "Name": concurrentName,
      "Observation": observation,
    };

    if (_selectedConcurrent?.Address != null) {
      jsonBody["Address"] = _selectedConcurrent?.Address?.toJson();
    }

    try {
      await SoapRequest.soapPost(
        parameters: {"json": json.encode(jsonBody)},
        typeOfResponse: "InsertUpdateConcurrentJsonResponse",
        SOAPAction: "InsertUpdateConcurrentJson",
        serviceASMX: "CeltaResearchOfPriceService.asmx",
        typeOfResult: "InsertUpdateConcurrentJsonResult",
      );
      _errorAddOrUpdateConcurrents = SoapRequestResponse.errorMessage;

      if (_errorAddOrUpdateConcurrents == "" && _selectedConcurrent != null) {
        _updateLocalSelectedConcurrent(
          address: _selectedConcurrent?.Address,
          name: concurrentName,
          observation: observation,
        );
      } else if (_selectedConcurrent == null) {
        _concurrents.add(
          ResearchPricesConcurrentsModel.fromJson(
            json.decode(SoapRequestResponse.responseAsString),
          ),
        );
      }
    } catch (e) {
      _errorAddOrUpdateConcurrents = DefaultErrorMessage.ERROR;
    }
    if (_errorAddOrUpdateConcurrents == "") {
      ShowSnackbarMessage.show(
        message: "Concorrente cadastrado/alterado com sucesso!",
        backgroundColor: Colors.green,
        context: context,
      );

      _selectedConcurrent = null;
    } else {
      ShowSnackbarMessage.show(
        message: _errorAddOrUpdateConcurrents,
        context: context,
      );
    }

    _isLoadingAddOrUpdateConcurrents = false;
    notifyListeners();
  }

  Future<void> getConcurrents({
    required String searchConcurrentControllerText,
    required bool getAllConcurrents,
  }) async {
    if (!getAllConcurrents) clearConcurrents();

    _isLoadingGetConcurrents = true;
    notifyListeners();

    var jsonBody = json.encode({
      "CrossIdentity": UserData.crossIdentity,
      "SearchValue": searchConcurrentControllerText,

      "SearchTypeInt": int.tryParse(searchConcurrentControllerText) != null
          ? 1
          : 2, // "SearchTypeInt - ExactCode = 1, ApproximateName = 2"
    });
    try {
      await SoapRequest.soapPost(
        parameters: {
          "json": jsonBody,
        },
        SOAPAction: "GetConcurrentJson",
        typeOfResponse: "GetConcurrentJsonResponse",
        serviceASMX: "CeltaResearchOfPriceService.asmx",
        typeOfResult: "GetConcurrentJsonResult",
      );
      _errorGetConcurrents = SoapRequestResponse.errorMessage;

      if (_errorGetConcurrents == "") {
        _concurrents.addAll(
          ResearchPricesConcurrentsModel.convertResultToListOfConcurrents()
              .where(
            (newConcurrent) => !_concurrents.any(
              (concurrent) =>
                  //adiciona o concorrente somente se não houver um com o mesmo
                  //código
                  concurrent.ConcurrentCode == newConcurrent.ConcurrentCode,
            ),
          ),
        );
      }
    } catch (e) {
      _errorGetConcurrents = DefaultErrorMessage.ERROR;
    }

    _isLoadingGetConcurrents = false;
    notifyListeners();
  }

  void clearAssociatedsProducts() {
    _associatedsProducts.clear();
    _errorGetAssociatedsProducts = "";
  }

  void clearNotAssociatedsProducts() {
    _notAssociatedsProducts.clear();
    _errorGetNotAssociatedsProducts = "";
  }

  Future<void> getAssociatedProducts({
    required String searchProductControllerText,
    required BuildContext context,
    required bool? withPrices,
    required ConfigurationsProvider configurationsProvider,
  }) async {
    _errorGetAssociatedsProducts = "";
    _isLoadingGetProducts = true;
    _associatedsProducts.clear();
    selectedIndexAssociatedProducts = -1;
    notifyListeners();

    int withPriceFilter() {
      if (withPrices == null) {
        return 0;
      } else if (withPrices == true) {
        return 1;
      } else {
        return 2;
      }
    }

    Map jsonGetProducts = {
      "CrossIdentity": UserData.crossIdentity,
      "RoutineInt": 7,
      "SearchValue": searchProductControllerText,
      "SearchTypeInt": SoapHelper.getSearchTypeInt(configurationsProvider),
      "ResearchOfPriceFilters": {
        "ResearchOfPriceCode": _selectedResearch!.Code,
        "ConcurrentCode": _selectedConcurrent!.ConcurrentCode,
        "OnlyAssociated": true,
        "InformedPrices": withPriceFilter(),
      },
    };

    try {
      await SoapRequest.soapPost(
        parameters: {
          "filters": json.encode(jsonGetProducts),
        },
        typeOfResponse: "GetProductsJsonResponse",
        SOAPAction: "GetProductsJson",
        serviceASMX: "CeltaProductService.asmx",
        typeOfResult: "GetProductsJsonResult",
      );

      _errorGetAssociatedsProducts = SoapRequestResponse.errorMessage;

      if (_errorGetAssociatedsProducts == "") {
        _associatedsProducts.addAll(
          ResearchPricesProductsModel.resultAsStringToProductsModel(),
        );

        _associatedsProducts.sort(
          (a, b) => a.ProductName.compareTo(b.ProductName),
        );
      } else {
        ShowSnackbarMessage.show(
          message: _errorGetAssociatedsProducts,
          context: context,
        );
      }
    } catch (e) {
      //print("Erro para obter os produtos: $e");
      _errorGetAssociatedsProducts = DefaultErrorMessage.ERROR;
    } finally {
      _isLoadingGetProducts = false;
      notifyListeners();
    }
  }

  Future<void> getNotAssociatedProducts({
    required String searchProductControllerText,
    required ConfigurationsProvider configurationsProvider,
  }) async {
    _errorGetNotAssociatedsProducts = "";
    _isLoadingGetProducts = true;
    _notAssociatedsProducts.clear();
    selectedIndexNotAssociatedProducts = -1;
    notifyListeners();

    Map jsonGetProducts = {
      "CrossIdentity": UserData.crossIdentity,
      "RoutineInt": 7,
      "SearchValue": searchProductControllerText,
      "SearchTypeInt": SoapHelper.getSearchTypeInt(configurationsProvider),
      "ResearchOfPriceFilters": {
        "ResearchOfPriceCode": _selectedResearch!.Code,
        "ConcurrentCode": _selectedConcurrent!.ConcurrentCode,
        "OnlyAssociated": false,
      },
    };

    try {
      await SoapRequest.soapPost(
        parameters: {
          "filters": json.encode(jsonGetProducts),
        },
        typeOfResponse: "GetProductsJsonResponse",
        SOAPAction: "GetProductsJson",
        serviceASMX: "CeltaProductService.asmx",
        typeOfResult: "GetProductsJsonResult",
      );

      _errorGetNotAssociatedsProducts = SoapRequestResponse.errorMessage;

      if (_errorGetNotAssociatedsProducts == "") {
        _notAssociatedsProducts.addAll(
          ResearchPricesProductsModel.resultAsStringToProductsModel(),
        );
        _associatedsProducts.sort(
          (a, b) => a.ProductName.compareTo(b.ProductName),
        );
      }
    } catch (e) {
      //print("Erro para obter os produtos: $e");
      _errorGetNotAssociatedsProducts = DefaultErrorMessage.ERROR;
    } finally {
      _isLoadingGetProducts = false;
      notifyListeners();
    }
  }

  void loadAssociatedsConcurrents() {
    _researchPrices.forEach((research) {
      if (research.Code == _selectedResearch!.Code) {
        _concurrents.clear();
        _concurrents.addAll(research.Concurrents);
      }
    });
    notifyListeners();
  }

  Map _jsonInsertConcurrentPrices({
    required int productCode,
    required String priceLookUp,
    // required String productName,
    required double? priceRetail,
    required double? offerRetail,
    required double? priceWhole,
    required double? offerWhole,
    required double? priceECommerce,
    required double? offerECommerce,
  }) {
    Map jsonInsertConcurrentPrices = {
      "CrossIdentity": UserData.crossIdentity,
      "ResearchOfPriceCode": _selectedResearch!.Code,
      "ConcurrentCode": _selectedConcurrent!.ConcurrentCode,
      "ProductPackingCode": productCode,
      "PriceLookUp": priceLookUp,
      // "ProductName": productName,
      // "PriceRetail": 1, //somente para teste
      // "OfferRetail": 2, //somente para teste
      // "PriceWhole": 3, //somente para teste
      // "OfferWhole": 4, //somente para teste
      // "PriceECommerce": 5, //somente para teste
      // "OfferECommerce": 6, //somente para teste
    };

    if (priceRetail != null) {
      jsonInsertConcurrentPrices.putIfAbsent("PriceRetail", () => priceRetail);
    }
    if (offerRetail != null) {
      jsonInsertConcurrentPrices.putIfAbsent("OfferRetail", () => offerRetail);
    }
    if (priceWhole != null) {
      jsonInsertConcurrentPrices.putIfAbsent("PriceWhole", () => priceWhole);
    }
    if (offerWhole != null) {
      jsonInsertConcurrentPrices.putIfAbsent("OfferWhole", () => offerWhole);
    }
    if (priceECommerce != null) {
      jsonInsertConcurrentPrices.putIfAbsent(
          "PriceECommerce", () => priceECommerce);
    }
    if (offerECommerce != null) {
      jsonInsertConcurrentPrices.putIfAbsent(
          "OfferECommerce", () => offerECommerce);
    }

    return jsonInsertConcurrentPrices;
  }

  void _updateLocalProductPrices({
    required bool isAssociatedProducts,
    required String PriceLookUp,
    required double? priceRetail,
    required double? offerRetail,
    required double? priceWhole,
    required double? offerWhole,
    required double? priceECommerce,
    required double? offerECommerce,
  }) {
    List<ResearchPricesProductsModel> listToModify =
        isAssociatedProducts ? _associatedsProducts : _notAssociatedsProducts;

    int index = listToModify
        .indexWhere((element) => element.PriceLookUp == PriceLookUp);

    listToModify[index].PriceRetail = priceRetail ?? 0;
    listToModify[index].OfferRetail = offerRetail ?? 0;
    listToModify[index].PriceWhole = priceWhole ?? 0;
    listToModify[index].OfferWhole = offerWhole ?? 0;
    listToModify[index].PriceECommerce = priceECommerce ?? 0;
    listToModify[index].OfferECommerce = offerECommerce ?? 0;
  }

  Future<void> insertConcurrentPrices({
    required int productCode,
    required String priceLookUp,
    required String productName,
    required double? priceRetail,
    required double? offerRetail,
    required double? priceWhole,
    required double? offerWhole,
    required double? priceECommerce,
    required double? offerECommerce,
    required bool isAssociatedProducts,
  }) async {
    _errorInsertConcurrentPrices = "";
    _isLoadingInsertConcurrentPrices = true;
    notifyListeners();

    Map jsonInsertConcurrentPrices = _jsonInsertConcurrentPrices(
      productCode: productCode,
      priceLookUp: priceLookUp,
      priceRetail: priceRetail,
      offerRetail: offerRetail,
      priceWhole: priceWhole,
      offerWhole: offerWhole,
      priceECommerce: priceECommerce,
      offerECommerce: offerECommerce,
    );

    try {
      await SoapRequest.soapPost(
        parameters: {
          "json": [json.encode(jsonInsertConcurrentPrices)],
        },
        typeOfResponse: "InsertConcurrentProductResponse",
        SOAPAction: "InsertConcurrentProduct",
        serviceASMX: "CeltaResearchOfPriceService.asmx",
      );

      _errorInsertConcurrentPrices = SoapRequestResponse.errorMessage;

      if (_errorInsertConcurrentPrices == "") {
        _updateLocalProductPrices(
          isAssociatedProducts: isAssociatedProducts,
          PriceLookUp: priceLookUp,
          priceRetail: priceRetail,
          offerRetail: offerRetail,
          priceWhole: priceWhole,
          offerWhole: offerWhole,
          priceECommerce: priceECommerce,
          offerECommerce: offerECommerce,
        );
      }

      FirebaseHelper.addSoapCallInFirebase(
        FirebaseCallEnum.researchPricesInsertPrice,
      );
    } catch (e) {
      //print("Erro para obter os produtos: $e");
      _errorInsertConcurrentPrices = DefaultErrorMessage.ERROR;
    } finally {
      _isLoadingInsertConcurrentPrices = false;
      notifyListeners();
    }
  }
}
