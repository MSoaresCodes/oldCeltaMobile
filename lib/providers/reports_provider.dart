import 'dart:convert';

import 'package:flutter/material.dart';

import '../Models/models.dart';
import '../api/api.dart';
import '../components/components.dart';
import '../utils/utils.dart';

class ReportsProvider with ChangeNotifier {
  List<ReceiptModel> _receipts = [];
  List<ReceiptModel> get receipts => [..._receipts];
  int get receiptCount => _receipts.length;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getReportSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SoapRequest.soapPost(
        parameters: {
          "json": json.encode(
            {"CrossIdentity": UserData.crossIdentity},
          )
        },
        typeOfResponse: "GetReportSchedulesJsonResponse",
        SOAPAction: "GetReportSchedulesJson",
        serviceASMX: "CeltaReportService.asmx",
        typeOfResult: "GetReportSchedulesJsonResult",
      );

      SoapRequestResponse.responseAsString;
      SoapRequestResponse.responseAsMap;

      if (SoapRequestResponse.errorMessage != "") {
        ShowSnackbarMessage.show(
          message: SoapRequestResponse.errorMessage,
          context: NavigatorKey.key.currentState!.context,
        );
      }
      debugPrint("stop");
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
}
