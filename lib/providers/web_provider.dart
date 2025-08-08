import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/components.dart';
import '../../utils/utils.dart';
import '../api/api.dart';
import '../Models/models.dart';

enum Months {
  AtualMonth,
  PenultimateMonth,
  AntiPenultimateMonth,
}

class WebProvider with ChangeNotifier {
  bool _loggedUserIsAdmin = false;
  bool get loggedUserIsAdmin => _loggedUserIsAdmin;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessageClients = "";
  String get errorMessageClients => _errorMessageClients;

  String _errorMessageSoapActions = "";
  String get errorMessageSoapActions => _errorMessageSoapActions;

  int selectedBottomNavigationBarIndex = 0;

  List<FirebaseEnterpriseModel> _enterprises = [];
  List<FirebaseEnterpriseModel> get enterprises => [..._enterprises];

  Set<String> _enterprisesNames = {};
  Set<String> get enterprisesNames => _enterprisesNames;

  Map<String, List<SoapActionsModel>> _dataFromLastTrheeMonths = {
    Months.AtualMonth.name: <SoapActionsModel>[],
    Months.PenultimateMonth.name: <SoapActionsModel>[],
    Months.AntiPenultimateMonth.name: <SoapActionsModel>[],
  };
  Map<String, List<SoapActionsModel>> get dataFromLastTrheeMonths =>
      _dataFromLastTrheeMonths;

  int _indexOfSelectedEnterprise = -1;
  int get indexOfSelectedEnterprise => _indexOfSelectedEnterprise;
  set indexOfSelectedEnterprise(int newValue) {
    _indexOfSelectedEnterprise = newValue;
  }

  SoapActionsModel _sumMonthRequests({
    required List<SoapActionsModel> monthsData,
    required String enterpriseName,
  }) {
    int adjustSalePrice = 0;
    int productsConference = 0;
    int adjustStockConfirmQuantity = 0;
    int priceConferenceGetProductOrSendToPrint = 0;
    int inventoryEntryQuantity = 0;
    int receiptEntryQuantity = 0;
    int receiptLiberate = 0;
    int saleRequestSave = 0;
    int transferBetweenStocksConfirmAdjust = 0;
    int transferBetweenPackageConfirmAdjust = 0;
    int transferRequestSave = 0;
    int customerRegister = 0;
    int buyRequestSave = 0;
    int researchPricesInsertPrice = 0;
    int reports = 0;

    for (var monthData in monthsData) {
      if (monthData.adjustSalePrice != null) {
        adjustSalePrice += monthData.adjustSalePrice!;
      }
      if (monthData.productsConference != null) {
        productsConference += monthData.productsConference!;
      }
      if (monthData.adjustStockConfirmQuantity != null) {
        adjustStockConfirmQuantity += monthData.adjustStockConfirmQuantity!;
      }
      if (monthData.priceConferenceGetProductOrSendToPrint != null) {
        priceConferenceGetProductOrSendToPrint +=
            monthData.priceConferenceGetProductOrSendToPrint!;
      }
      if (monthData.inventoryEntryQuantity != null) {
        inventoryEntryQuantity += monthData.inventoryEntryQuantity!;
      }
      if (monthData.receiptEntryQuantity != null) {
        receiptEntryQuantity += monthData.receiptEntryQuantity!;
      }
      if (monthData.receiptLiberate != null) {
        receiptLiberate += monthData.receiptLiberate!;
      }
      if (monthData.saleRequestSave != null) {
        saleRequestSave += monthData.saleRequestSave!;
      }
      if (monthData.transferBetweenStocksConfirmAdjust != null) {
        transferBetweenStocksConfirmAdjust +=
            monthData.transferBetweenStocksConfirmAdjust!;
      }
      if (monthData.transferBetweenPackageConfirmAdjust != null) {
        transferBetweenPackageConfirmAdjust +=
            monthData.transferBetweenPackageConfirmAdjust!;
      }
      if (monthData.transferRequestSave != null) {
        transferRequestSave += monthData.transferRequestSave!;
      }
      if (monthData.customerRegister != null) {
        customerRegister += monthData.customerRegister!;
      }
      if (monthData.buyRequestSave != null) {
        buyRequestSave += monthData.buyRequestSave!;
      }
      if (monthData.researchPricesInsertPrice != null) {
        researchPricesInsertPrice += monthData.researchPricesInsertPrice!;
      }
      if (monthData.reports != null) {
        reports += monthData.reports!;
      }
    }

    return SoapActionsModel(
      documentId: enterpriseName,
      datesUsed: [],
      users: [],
      reports: reports == 0 ? null : reports,
      adjustSalePrice: adjustSalePrice == 0 ? null : adjustSalePrice,
      productsConference: productsConference == 0 ? null : productsConference,
      adjustStockConfirmQuantity:
          adjustStockConfirmQuantity == 0 ? null : adjustStockConfirmQuantity,
      priceConferenceGetProductOrSendToPrint:
          priceConferenceGetProductOrSendToPrint == 0
              ? null
              : priceConferenceGetProductOrSendToPrint,
      inventoryEntryQuantity:
          inventoryEntryQuantity == 0 ? null : inventoryEntryQuantity,
      receiptEntryQuantity:
          receiptEntryQuantity == 0 ? null : receiptEntryQuantity,
      receiptLiberate: receiptLiberate == 0 ? null : receiptLiberate,
      saleRequestSave: saleRequestSave == 0 ? null : saleRequestSave,
      transferBetweenStocksConfirmAdjust:
          transferBetweenStocksConfirmAdjust == 0
              ? null
              : transferBetweenStocksConfirmAdjust,
      transferBetweenPackageConfirmAdjust:
          transferBetweenPackageConfirmAdjust == 0
              ? null
              : transferBetweenPackageConfirmAdjust,
      transferRequestSave:
          transferRequestSave == 0 ? null : transferRequestSave,
      customerRegister: customerRegister == 0 ? null : customerRegister,
      buyRequestSave: buyRequestSave == 0 ? null : buyRequestSave,
      researchPricesInsertPrice:
          researchPricesInsertPrice == 0 ? null : researchPricesInsertPrice,
    );
  }

  SoapActionsModel mergeLastThreeMonths(String enterpriseName) {
    final monthsThatHaveData = <SoapActionsModel>[];

    final atualMonthData = _dataFromLastTrheeMonths[Months.AtualMonth.name]
        ?.where((element) => element.documentId == enterpriseName);
    if (atualMonthData?.isEmpty == false) {
      monthsThatHaveData.add(atualMonthData!.first);
    }

    final penultimateMonth =
        _dataFromLastTrheeMonths[Months.PenultimateMonth.name]
            ?.where((element) => element.documentId == enterpriseName);
    if (penultimateMonth?.isEmpty == false) {
      monthsThatHaveData.add(penultimateMonth!.first);
    }

    final antiPenultimateMonth =
        _dataFromLastTrheeMonths[Months.AntiPenultimateMonth.name]
            ?.where((element) => element.documentId == enterpriseName);
    if (antiPenultimateMonth?.isEmpty == false) {
      monthsThatHaveData.add(antiPenultimateMonth!.first);
    }

    return _sumMonthRequests(
        monthsData: monthsThatHaveData, enterpriseName: enterpriseName);
  }

  void _orderEnterprisesByName() {
    _enterprises.sort((a, b) => a.enterpriseName.compareTo(b.enterpriseName));
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessageClients = "";
    notifyListeners();

    try {
      await FirebaseHelper.signIn(
        email: email,
        password: password,
      );
    } catch (e) {
      _errorMessageClients = DefaultErrorMessage.ERROR;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllClients() async {
    _isLoading = true;
    _errorMessageClients = "";
    _enterprises.clear();
    notifyListeners();

    try {
      final clients = await FirebaseHelper.getAllClients();

      _enterprises = clients
          .map(
            (element) => FirebaseEnterpriseModel.fromJson(
              json: element.data() as Map,
              id: element.id,
            ),
          )
          .toList();

      _orderEnterprisesByName();
    } catch (e) {
      _errorMessageClients = DefaultErrorMessage.ERROR;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> yearAndMonthFromLastTrheeMonths() {
    DateTime now = DateTime.now();
    List<String> lastThreeMonths = [];

    for (int i = 0; i < 3; i++) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      String formattedDate = DateFormat('yyyy-MM').format(date);
      lastThreeMonths.add(formattedDate);
    }

    return lastThreeMonths;
  }

  Future<dynamic> getLastThreeMonthsSoapActions() async {
    _isLoading = true;
    _errorMessageSoapActions = "";

    notifyListeners();

    try {
      List<String> lastThreeMonths = yearAndMonthFromLastTrheeMonths();

      final atualMonth =
          await FirebaseHelper.getAllSoapActions(lastThreeMonths[0]);

      final penultimateMonth =
          await FirebaseHelper.getAllSoapActions(lastThreeMonths[1]);
      final antiPenultimateMonth =
          await FirebaseHelper.getAllSoapActions(lastThreeMonths[2]);

      if (atualMonth != null &&
          penultimateMonth != null &&
          antiPenultimateMonth != null) {
        _dataFromLastTrheeMonths[Months.AtualMonth.name] = atualMonth
            .map((element) => SoapActionsModel.fromJson(
                  documentId: element.id,
                  json: element.data() as Map<String, dynamic>,
                ))
            .toList();

        _dataFromLastTrheeMonths[Months.PenultimateMonth.name] =
            penultimateMonth
                .map((element) => SoapActionsModel.fromJson(
                      documentId: element.id,
                      json: element.data() as Map<String, dynamic>,
                    ))
                .toList();

        _dataFromLastTrheeMonths[Months.AntiPenultimateMonth.name] =
            antiPenultimateMonth
                .map((element) => SoapActionsModel.fromJson(
                      documentId: element.id,
                      json: element.data() as Map<String, dynamic>,
                    ))
                .toList();

        for (var atualMonthData in atualMonth) {
          _enterprisesNames.add(atualMonthData.id);
        }
        for (var atualMonthData in penultimateMonth) {
          _enterprisesNames.add(atualMonthData.id);
        }
        for (var atualMonthData in antiPenultimateMonth) {
          _enterprisesNames.add(atualMonthData.id);
        }

        final ordenatedList = _enterprisesNames.toList()..sort();
        _enterprisesNames = ordenatedList.toSet();
      } else {
        throw Exception();
      }
    } catch (e) {
      _errorMessageSoapActions = DefaultErrorMessage.ERROR;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getTotalSoapActions({
    required List<Months> months,
    required String clientName,
  }) {
    int totalRequests = 0;

    for (var month in months) {
      bool contains = _dataFromLastTrheeMonths[month.name]!
          .any((element) => element.documentId == clientName);

      if (!contains) {
        continue;
      }

      final clientData = _dataFromLastTrheeMonths[month.name]!
          .where((element) => element.documentId == clientName)
          .first;

      totalRequests += clientData.adjustStockConfirmQuantity ?? 0;
      totalRequests += clientData.adjustSalePrice ?? 0;
      totalRequests += clientData.productsConference ?? 0;
      totalRequests += clientData.priceConferenceGetProductOrSendToPrint ?? 0;
      totalRequests += clientData.inventoryEntryQuantity ?? 0;
      totalRequests += clientData.receiptEntryQuantity ?? 0;
      totalRequests += clientData.receiptLiberate ?? 0;
      totalRequests += clientData.saleRequestSave ?? 0;
      totalRequests += clientData.transferBetweenStocksConfirmAdjust ?? 0;
      totalRequests += clientData.transferBetweenPackageConfirmAdjust ?? 0;
      totalRequests += clientData.transferRequestSave ?? 0;
      totalRequests += clientData.customerRegister ?? 0;
      totalRequests += clientData.buyRequestSave ?? 0;
      totalRequests += clientData.researchPricesInsertPrice ?? 0;
      totalRequests += clientData.reports ?? 0;
    }

    return totalRequests;
  }

  Future<void> deleteEnterprise({
    required BuildContext context,
    required String enterpriseId,
  }) async {
    _isLoading = true;
    _errorMessageClients = "";
    notifyListeners();

    try {
      await FirebaseHelper.deleteEnterprise(enterpriseId);

      _enterprises.removeWhere((element) => element.id == enterpriseId);

      Navigator.of(context).pop();
      ShowSnackbarMessage.show(
        message: "Empresa excluída com sucesso",
        context: context,
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    } catch (e) {
      ShowSnackbarMessage.show(
        message: DefaultErrorMessage.ERROR,
        context: context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEnterpriseCcs({
    required BuildContext context,
    required String enterpriseId,
    required String newUrlCcs,
  }) async {
    _isLoading = true;
    _errorMessageClients = "";
    notifyListeners();

    try {
      int indexOfOldClient =
          _enterprises.indexWhere((element) => element.id == enterpriseId);

      if (indexOfOldClient == -1) {
        throw Exception();
      }

      final oldClient = _enterprises[indexOfOldClient];

      await FirebaseHelper.updateUrlCcs(newUrl: newUrlCcs, client: oldClient);

      _enterprises[indexOfOldClient] = FirebaseEnterpriseModel(
        id: enterpriseId,
        urlCCS: newUrlCcs,
        usersInformations: oldClient.usersInformations,
        enterpriseName: oldClient.enterpriseName,
        subEnterprises: oldClient.subEnterprises,
      );

      Navigator.of(context).pop();
      ShowSnackbarMessage.show(
        message: "URL alterada com sucesso",
        context: context,
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
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

  Future<void> addUpdateEnterprise({
    required BuildContext context,
    required TextEditingController enterpriseNameController,
    required TextEditingController urlCcsController,
    required SubEnterpriseModel? subEnterpriseToAdd,
    required bool isAddinSubEnterprise,
  }) async {
    _isLoading = true;
    _errorMessageClients = "";
    notifyListeners();

    try {
      bool hasSelectedEnterprise = _indexOfSelectedEnterprise != -1;
      FirebaseEnterpriseModel? newEnterprise;

      if (_enterprises.indexWhere((e) =>
              e.enterpriseName ==
              enterpriseNameController.text
                  .toLowerCase()
                  .removeWhiteSpaces()) !=
          -1) {
        ShowSnackbarMessage.show(
          message: "Já existe uma empresa com esse nome cadastrado",
          context: context,
        );
        return;
      }

      if (hasSelectedEnterprise) {
        final enterprise = _enterprises[_indexOfSelectedEnterprise];

        if (isAddinSubEnterprise &&
            enterprise.subEnterprises!
                    .indexWhere((e) => e.cnpj == subEnterpriseToAdd?.cnpj) !=
                -1) {
          ShowSnackbarMessage.show(
            message: "Já existe uma empresa com esse CNPJ cadastrado",
            context: context,
          );
          return;
        }

        int? indexOfSubgEnterprise = enterprise.subEnterprises
            ?.indexWhere((e) => e.cnpj == subEnterpriseToAdd?.cnpj);
        if (indexOfSubgEnterprise != -1) {
          enterprise.subEnterprises![indexOfSubgEnterprise!] =
              subEnterpriseToAdd!;
        }

        newEnterprise = FirebaseEnterpriseModel(
          enterpriseName: enterprise.enterpriseName,
          id: enterprise.id,
          urlCCS: enterprise.urlCCS,
          usersInformations: enterprise.usersInformations,
          subEnterprises: enterprise.subEnterprises,
        );

        if (subEnterpriseToAdd != null && indexOfSubgEnterprise == -1) {
          newEnterprise.subEnterprises!.add(subEnterpriseToAdd);
        }
      } else {
        newEnterprise = FirebaseEnterpriseModel(
          id: null,
          enterpriseName: enterpriseNameController.text,
          urlCCS: urlCcsController.text,
          usersInformations: null,
          subEnterprises:
              subEnterpriseToAdd != null ? [subEnterpriseToAdd] : null,
        );
      }

      final updatedEnterprise = await FirebaseHelper.addUpdateEnterprise(
        enterpriseToAdd: newEnterprise,
      );

      if (updatedEnterprise == null) {
        throw Exception();
      }

      if (_indexOfSelectedEnterprise == -1) {
        _enterprises.add(updatedEnterprise);
      } else {
        _enterprises[_indexOfSelectedEnterprise] = updatedEnterprise;
      }
      _orderEnterprisesByName();

      Navigator.of(context).pop();

      ShowSnackbarMessage.show(
        message: "Empresa adicionada/alterada com sucesso!",
        context: context,
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    } catch (e) {
      ShowSnackbarMessage.show(
        message: "Ocorreu um erro não esperado para adicionar a empresa!",
        context: context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateModulesInAllSubEnterprises(
    List<ModuleModel> modules,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final selectedEnterprise = _enterprises[_indexOfSelectedEnterprise];
      final enterpriseToAdd = FirebaseEnterpriseModel(
        enterpriseName: selectedEnterprise.enterpriseName,
        id: selectedEnterprise.id,
        urlCCS: selectedEnterprise.urlCCS,
        usersInformations: selectedEnterprise.usersInformations,
        subEnterprises: selectedEnterprise.subEnterprises
            ?.map(
              (e) => SubEnterpriseModel(
                modules: modules,
                cnpj: e.cnpj,
                surname: e.surname,
              ),
            )
            .toList(),
      );

      final updatedEnterprise = await FirebaseHelper.addUpdateEnterprise(
        enterpriseToAdd: enterpriseToAdd,
      );

      if (updatedEnterprise == null) {
        throw Exception();
      } else {
        final context = NavigatorKey.key.currentState!.context;
        _enterprises[_indexOfSelectedEnterprise] = updatedEnterprise;
        Navigator.of(context).pop();
        ShowSnackbarMessage.show(
          message: "Módulos atualizados com sucesso",
          context: context,
          backgroundColor: Theme.of(context).colorScheme.primary,
        );
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeSubEnterprise(index) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_indexOfSelectedEnterprise == -1 ||
          _enterprises[_indexOfSelectedEnterprise].subEnterprises == null) {
        throw Exception();
      }

      var selectedEnterprise = _enterprises[_indexOfSelectedEnterprise];
      selectedEnterprise.subEnterprises!.removeAt(index);

      final updatedEnterprise = await FirebaseHelper.addUpdateEnterprise(
        enterpriseToAdd: selectedEnterprise,
      );

      if (updatedEnterprise != null) {
        _enterprises[_indexOfSelectedEnterprise] = updatedEnterprise;
      }
    } catch (e) {
      ShowSnackbarMessage.show(
        message: DefaultErrorMessage.ERROR,
        context: NavigatorKey.key.currentState!.context,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeLoggedUserIsAdmin(String? email) {
    _loggedUserIsAdmin = email == "admin@celtaware.com.br";
  }
}
