import 'dart:convert';

import 'package:flutter/material.dart';

import '../../Models/models.dart';

import '../../providers/providers.dart';
import '../../utils/utils.dart';
import 'soap.dart';

class SoapHelper {
  SoapHelper._();

  static Future<void> getStockTypesModel(
    List<GetStockTypesModel> listToAdd,
  ) async {
    try {
      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "simpleSearchValue": "undefined",
        },
        typeOfResponse: "GetStockTypesResponse",
        SOAPAction: "GetStockTypes",
        serviceASMX: "CeltaProductService.asmx",
        typeOfResult: "GetStockTypesResult",
      );

      if (SoapRequestResponse.errorMessage != "") {
        throw Exception();
      }

      GetStockTypesModel.resultAsStringToGetStockTypesModel(
        resultAsString: SoapRequestResponse.responseAsString,
        listToAdd: listToAdd,
      );
    } catch (e) {
      e;
    }
  }

  static Future<void> getJustifications({
    required int justificationTransferType,
    required List<GetJustificationsModel> listToAdd,
  }) async {
    try {
      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          'simpleSearchValue': 'undefined',
          "justificationTransferType": justificationTransferType,
        },
        typeOfResponse: "GetJustificationsResponse",
        typeOfResult: "GetJustificationsResult",
        SOAPAction: "GetJustifications",
        serviceASMX: "CeltaProductService.asmx",
      );

      if (SoapRequestResponse.errorMessage != "") {
        throw Exception();
      }

      GetJustificationsModel.resultAsStringToJustificationsModel(
        resultAsString: SoapRequestResponse.responseAsString,
        listToAdd: listToAdd,
      );
    } catch (e) {
      e;
    }
  }

  static int getSearchTypeInt(ConfigurationsProvider configurationsProvider) {
    //  {
    //       Generic = 0,
    //       SaleRequest = 1,
    //       BuyRequest = 2,
    //       TransferRequest = 3,
    //       PriceConference = 4,
    //       AdjustStock = 5,
    //       GoodsReceiving = 6,
    //       ResearchOfPrice = 7,
    //       AdjustSalePrice = 8
    //       BuyQuotation = 9
    //       Todos produtos contados no recebimento = 19,
    //   }
    if (configurationsProvider.legacyCode?.value == true) {
      return 11;
    } else if (configurationsProvider.productPersonalizedCode?.value == true) {
      return 5;
    } else {
      return 0;
    }
  }

  static String changeSearchValueIfIsBalanceCode(
    String searchValue,
    EnterpriseModel enterprise,
  ) {
    bool searchByBalanceCode = searchValue.length == 13 &&
        searchValue.startsWith("2") &&
        enterprise.ProductCodeSizeOfBalanceLabel != null &&
        enterprise.ProductCodeWithCheckerDigit != null;

    String pluFromBalanceCode = "";

    if (searchByBalanceCode) {
      pluFromBalanceCode =
          searchValue.replaceFirst(RegExp(r'2'), '').replaceRange(
                enterprise.ProductCodeSizeOfBalanceLabel!,
                null,
                enterprise.ProductCodeWithCheckerDigit == true ? "" : ".",
              );
      return pluFromBalanceCode;
    } else {
      return searchValue;
    }
  }

  static Future<List<GetProductJsonModel>> getProductsJsonModel({
    required EnterpriseModel enterprise,
    required String searchValue,
    required ConfigurationsProvider configurationsProvider,
    required int routineTypeInt,
    required List<int> enterprisesCodes,
  }) async {
    try {
      await SoapRequest.soapPost(
        // CrossIdentity = "CrossIdentity",
        //             TopQuantity = 100,
        //             RoutineInt = 0,
        //             SearchValue = "SearchValue",
        //             SearchType = SearchProduct.Dynamic,
        //             RequestTypeCode = 0,
        //             EnterpriseCodes = new List<int> { 1, 2 },
        //             EnterpriseDestinyCode = 0,
        //             SupplierCode = 0,
        //             ResearchOfPriceFilters = new JsonProductResearchOfPriceFilters() { ResearchOfPriceCode = 1, ConcurrentCode = 2, OnlyAssociated = false }
        parameters: {
          "filters": json.encode({
            "CrossIdentity": UserData.crossIdentity,
            "EnterpriseCodes": enterprisesCodes,
            "SearchValue": searchValue,
            "SearchType": getSearchTypeInt(configurationsProvider),
            "RoutineInt": routineTypeInt,
            "LastBuyEntranceQuantity": 5,
          }),
        },
        typeOfResponse: "GetProductsJsonResponse",
        typeOfResult: "GetProductsJsonResult",
        SOAPAction: "GetProductsJson",
        serviceASMX: "CeltaProductService.asmx",
      );

      if (SoapRequestResponse.responseAsString == "") {
        await SoapRequest.soapPost(
          parameters: {
            "filters": json.encode({
              "CrossIdentity": UserData.crossIdentity,
              "EnterpriseCodes": enterprisesCodes,
              "SearchValue":
                  changeSearchValueIfIsBalanceCode(searchValue, enterprise),
              "SearchType": getSearchTypeInt(configurationsProvider),
              "RoutineInt": routineTypeInt,
              "LastBuyEntranceQuantity": 5,
            }),
          },
          typeOfResponse: "GetProductsJsonResponse",
          typeOfResult: "GetProductsJsonResult",
          SOAPAction: "GetProductsJson",
          serviceASMX: "CeltaProductService.asmx",
        );
      }

      if (SoapRequestResponse.errorMessage != "") {
        return [];
      }

      return (json.decode(SoapRequestResponse.responseAsString) as List)
          .map((e) => GetProductJsonModel.fromJson(e))
          .toList();
    } catch (e) {
      e;
      return [];
    }
  }

  static Future<void> confirmAdjustStock(
    Map<String, dynamic> jsonAdjustStock, //TODO remove this
    // TransferBetweenStockBodyModel jsonAdjustStock,
  ) async {
    try {
      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "jsonAdjustStock": jsonAdjustStock,
        },
        typeOfResponse: "ConfirmAdjustStockResponse",
        SOAPAction: "ConfirmAdjustStock",
        serviceASMX: "CeltaProductService.asmx",
      );

      if (SoapRequestResponse.errorMessage != "") {
        throw Exception();
      }
    } catch (e) {
      e;
    }
  }

  static Future<void> getProductInventory({
    required EnterpriseModel enterprise,
    required String searchValue,
    required ConfigurationsProvider configurationsProvider,
    required int inventoryProcessCode,
    required int inventoryCountingCode,
    required List<InventoryProductModel> products,
  }) async {
    try {
      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "enterpriseCode": enterprise.Code,
          "searchValue":
              changeSearchValueIfIsBalanceCode(searchValue, enterprise),
          "searchTypeInt": getSearchTypeInt(configurationsProvider),
          "inventoryProcessCode": inventoryProcessCode,
          "inventoryCountingCode": inventoryCountingCode,
        },
        typeOfResponse: "GetProductResponse",
        SOAPAction: "GetProduct",
        serviceASMX: "CeltaInventoryService.asmx",
        typeOfResult: "GetProductResult",
      );

      if (SoapRequestResponse.errorMessage != "") {
        throw Exception();
      }

      InventoryProductModel.responseInStringToInventoryProductModel(
        data: SoapRequestResponse.responseAsMap["Produtos"],
        listToAdd: products,
      );
    } catch (e) {
      e;
    }
  }

  static Future<void> getProductReceipt({
    required ConfigurationsProvider configurationsProvider,
    required String searchValue,
    required int docCode,
    required bool isSearchAllCountedProducts,
    required EnterpriseModel enterprise,
  }) async {
    try {
      await SoapRequest.soapPost(
        parameters: {
          "crossIdentity": UserData.crossIdentity,
          "searchTypeInt": isSearchAllCountedProducts
              ? 19
              : getSearchTypeInt(configurationsProvider),
          "searchValue":
              changeSearchValueIfIsBalanceCode(searchValue, enterprise),
          "grDocCode": docCode,
        },
        typeOfResponse: "GetProductResponse",
        SOAPAction: "GetProduct",
        serviceASMX: "CeltaGoodsReceivingService.asmx",
        typeOfResult: "GetProductResult",
      );

      if (SoapRequestResponse.errorMessage != "") {
        throw Exception();
      }
    } catch (e) {
      e;
    }
  }

  static Future<List<GetProductJsonModel>> getProductTransferRequest({
    required String enterpriseOriginCode,
    required String enterpriseDestinyCode,
    required String requestTypeCode,
    required String searchValue,
    required ConfigurationsProvider configurationsProvider,
    required DateTime? bsDate,
  }) async {
    try {
      Map<String, dynamic> parameters;
      if (bsDate == null || bsDate.isBefore(DateTime(2025, 2, 27))) {
        parameters = {
          "crossIdentity": UserData.crossIdentity,
          "enterpriseCode": enterpriseOriginCode,
          "enterpriseDestinyCode": enterpriseDestinyCode,
          "requestTypeCode": requestTypeCode,
          "searchValue": searchValue,
          "searchTypeInt": getSearchTypeInt(configurationsProvider),
          // "routineTypeInt": 3,
        };
      } else {
        parameters = {
          "crossIdentity": UserData.crossIdentity,
          "enterpriseCode": enterpriseOriginCode,
          "enterpriseDestinyCode": enterpriseDestinyCode,
          "requestTypeCode": requestTypeCode,
          "searchValue": searchValue,
          // "searchTypeInt": 3,
          "routineTypeInt": 3,
        };
      }
      await SoapRequest.soapPost(
        parameters: parameters,
        typeOfResponse: "GetProductJsonByRequestTypeResponse",
        SOAPAction: "GetProductJsonByRequestType",
        serviceASMX: "CeltaProductService.asmx",
        typeOfResult: "GetProductJsonByRequestTypeResult",
      );

      if (SoapRequestResponse.errorMessage != "") {
        throw Exception();
      }

      return (json.decode(SoapRequestResponse.responseAsString) as List)
          .map((e) => GetProductJsonModel.fromJson(e))
          .toList();
    } catch (e) {
      e;
      return [];
    }
  }

  static Future<void> getProductBuyRequest({
    required String searchValue,
    required ConfigurationsProvider configurationsProvider,
    required int selectedRequestModelCode,
    required List<int> enterpriseCodes,
    required int selectedSupplierCode,
    required List<GetProductJsonModel> products,
  }) async {
    Map jsonGetProducts = {
      "CrossIdentity": UserData.crossIdentity,
      "RoutineInt": 2,
      "SearchValue": searchValue,
      "RequestTypeCode": selectedRequestModelCode,
      "EnterpriseCodes": enterpriseCodes,
      "SupplierCode": selectedSupplierCode,
      // "EnterpriseDestinyCode": 0,
      "SearchTypeInt": getSearchTypeInt(configurationsProvider),
      // "SearchType": 0,
      // "Routine": 0,
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

      if (SoapRequestResponse.errorMessage != "") {
        throw Exception();
      }

      products.addAll(
          (json.decode(SoapRequestResponse.responseAsString) as List)
              .map((e) => GetProductJsonModel.fromJson(e))
              .toList());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<BuyerModel>> getBuyers() async {
    try {
      Map jsonGetBuyer = {
        "CrossIdentity": UserData.crossIdentity,
        "RoutineInt": 2,
      };

      await SoapRequest.soapPost(
        parameters: {
          "filters": json.encode(jsonGetBuyer),
        },
        typeOfResponse: "GetEmployeeJsonResponse",
        SOAPAction: "GetEmployeeJson",
        serviceASMX: "CeltaEmployeeService.asmx",
        typeOfResult: "GetEmployeeJsonResult",
      );

      if (SoapRequestResponse.errorMessage != "") {
        throw Exception();
      }

      return (json.decode(SoapRequestResponse.responseAsString) as List)
          .map((e) => BuyerModel.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<bool> userCanAccessResource({
    required int resourceCode,
    required int routineInt,
  }) async {
    //  {
    //       Generic = 0,
    //       SaleRequest = 1,
    //       BuyRequest = 2,
    //       TransferRequest = 3,
    //       PriceConference = 4,
    //       AdjustStock = 5,
    //       GoodsReceiving = 6,
    //       ResearchOfPrice = 7,
    //       AdjustSalePrice = 8
    //       BuyQuotation = 9
    //   }
    try {
      final encoded = json.encode({
        "CrossIdentity": UserData.crossIdentity,
        "ResourceCode": resourceCode,
        "RoutineInt": routineInt,
      });

      await SoapRequest.soapPost(
        parameters: {
          "jsonParameters": encoded,
        },
        typeOfResponse: "UserCanAccessCrossResourceResponse",
        SOAPAction: "UserCanAccessCrossResource",
        serviceASMX: "CeltaSecurityService.asmx",
        typeOfResult: "UserCanAccessCrossResourceResult",
      );

      if (SoapRequestResponse.errorMessage != "") {
        return false;
      } else {
        return json.decode(SoapRequestResponse.responseAsString)["CanAccess"];
      }
    } catch (e) {
      return false;
    }
  }

  static Future<DateTime?> bsAlreadyInLatestVersion() async {
    try {
      await SoapRequest.soapPost(
        parameters: {},
        typeOfResponse: "GetVersionDateResponse",
        SOAPAction: "GetVersionDate",
        serviceASMX: "CeltaSecurityService.asmx",
        typeOfResult: "GetVersionDateResult",
      );

      if (SoapRequestResponse.errorMessage != "") {
        return null;
      } else {
        return DateTime.parse(
            (json.decode(SoapRequestResponse.responseAsString))["VersionDate"]);
      }
    } catch (e) {
      return null;
    }
  }

  static Future<CustomerModel> getCustomer({
    required int searchTypeInt,
    required String controllerText,
    required String enterpriseCode,
  }) async {
// 1=ExactCnpjCpfNumber
// 2=ExactCode
// 3=ApproximateName
// 4=PersonalizedCode

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

      if (SoapRequestResponse.errorMessage != "") {
        throw Exception();
      }

      return (json.decode(SoapRequestResponse.responseAsString) as List)
          .map((e) => CustomerModel.fromJson(e))
          .cast<CustomerModel>()
          .toList()
          .first;
    } catch (e) {
      throw Exception();
    }
  }
}
