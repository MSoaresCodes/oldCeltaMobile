import 'dart:convert';

import 'package:flutter/material.dart';

import '../Models/models.dart';
import '../api/api.dart';
import '../components/components.dart';
import '../utils/utils.dart';

class ReportsProvider with ChangeNotifier {
  List<ReportScheduleModel> _reportSchedules = [];
  List<ReportScheduleModel> get reportSchedules => [..._reportSchedules];

  List<ReportScheduleExecutionsModel> _downloadedExecutions = [];
  List<ReportScheduleExecutionsModel> get downloadedExecutions =>
      [..._downloadedExecutions];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getReportSchedules() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SoapRequest.soapPost(
        parameters: {
          "json": json.encode({"CrossIdentity": UserData.crossIdentity})
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
    try {
      _isLoading = true;
      notifyListeners();

      await getReportSchedules();

      final bool alreadyDownloadedLastExecution =
          _alreadyDownloadedLastExecution(
        reportScheduleCode: reportScheduleCode,
        downloadPdf: downloadPdf,
      );

      if (alreadyDownloadedLastExecution) {
        ShowSnackbarMessage.show(
          message: "Você já carregou a última execução deste relatório",
          context: NavigatorKey.key.currentState!.context,
          backgroundColor: Colors.red,
        );

        return;
      }

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

      final index = _downloadedExecutions.indexWhere(
          (element) => element.ReportScheduleCode == reportScheduleCode);
      if (index == -1) {
        _downloadedExecutions.addAll(remote);
      } else {
        _downloadedExecutions.removeAt(index);
        _downloadedExecutions.addAll(remote);
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

  bool _alreadyDownloadedLastExecution({
    required int reportScheduleCode,
    required bool downloadPdf,
  }) {
    try {
      final executionsBySameScheduleCode = _downloadedExecutions
          .where((e) => e.ReportScheduleCode == reportScheduleCode)
          .expand((e) => e.Executions.where((e) => e.Attachments.any(
              (e) => e.FileExtension == (downloadPdf ? "pdf" : "xlsx"))))
          .toList();

      if (executionsBySameScheduleCode.isNotEmpty) {
        final lastDownloadedExecutionDate =
            executionsBySameScheduleCode.first.ExecutionDate!;
        final lastReportExecutionDate = _reportSchedules
            .where((e) => e.Code == reportScheduleCode)
            .first
            .LastExecutionDate!;

        if (lastDownloadedExecutionDate == lastReportExecutionDate ||
            lastDownloadedExecutionDate.isAfter(lastReportExecutionDate)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
