import 'dart:convert';

import 'package:flutter/material.dart';

import '../Models/models.dart';
import '../api/api.dart';
import '../components/components.dart';
import '../utils/utils.dart';

class ReportsProvider with ChangeNotifier {
  List<ReportScheduleModel> _reportSchedules = [];
  List<ReportScheduleModel> get reportSchedules => [..._reportSchedules];

  List<ReportScheduleExecutionsModel> _executions = [];
  List<ReportScheduleExecutionsModel> get executions => [..._executions];

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

  Future<void> executeOrDownload({
    required int reportScheduleCode,
    required bool execute,
    required bool sendEmailOnExecution,
    required bool downloadPdf,
    required bool downloadXlsx,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await SoapRequest.soapPost(
        parameters: {
          "json": json.encode({
            "CrossIdentity": UserData.crossIdentity,
            "ReportScheduleCode": [reportScheduleCode],
            "Execute": execute,
            "SendEmailOnExecution": sendEmailOnExecution,
            "Download": {
              "DownloadLastExecution":
                  downloadPdf || downloadPdf == true && execute == false,
              "Pdf": downloadPdf,
              "Xlsx": downloadXlsx
            }
          })
        },
        typeOfResponse: "GetReportScheduleExecutionsResponse",
        SOAPAction: "GetReportScheduleExecutions",
        serviceASMX: "CeltaReportService.asmx",
        typeOfResult: "GetReportScheduleExecutionsResult",
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

      final remote = (json.decode(SoapRequestResponse.responseAsString) as List)
          .map<ReportScheduleExecutionsModel>(
              (e) => ReportScheduleExecutionsModel.fromJson(e))
          .toList();

      final index = _executions.indexWhere(
          (element) => element.ReportScheduleCode == reportScheduleCode);
      if (index == -1) {
        _executions.addAll(remote);
      } else {
        _executions.removeAt(index);
        _executions.addAll(remote);
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
}
