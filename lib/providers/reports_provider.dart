import 'dart:convert';

import 'package:flutter/material.dart';

import '../Models/models.dart';
import '../api/api.dart';
import '../components/components.dart';
import '../utils/utils.dart';

class ReportsProvider with ChangeNotifier {
  List<ReportScheduleModel> _reportSchedules = [];
  List<ReportScheduleModel> get reportSchedules => [..._reportSchedules];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getReportSchedules() async {
    _isLoading = true;
    _reportSchedules.clear();
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
        return;
      }

      _reportSchedules =
          (json.decode(SoapRequestResponse.responseAsString) as List)
              .map<ReportScheduleModel>((e) => ReportScheduleModel.fromJson(e))
              .toList();

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
