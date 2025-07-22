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
      if (downloadPdf || downloadXlsx) {
        await getReportSchedules();

        _isLoading = true;
        notifyListeners();

        final bool alreadyDownloadedLastExecution =
            _alreadyDownloadedLastExecution(
          reportScheduleCode: reportScheduleCode,
          downloadPdf: downloadPdf,
        );

        if (alreadyDownloadedLastExecution) {
          ShowSnackbarMessage.show(
            message: "Você já carregou a última execução",
            context: NavigatorKey.key.currentState!.context,
            backgroundColor: Colors.red,
          );

          return;
        }
      }

      _isLoading = true;
      notifyListeners();

      await SoapRequest.soapPost(
        parameters: {
          "json": json.encode({
            "CrossIdentity": UserData.crossIdentity,
            "ReportScheduleCode": [reportScheduleCode],
            "Execute": execute,
            "SendEmailOnExecution": sendEmailOnExecution,
            "Download": {
              "DownloadLastExecution":
                  downloadPdf || downloadXlsx == true && execute == false,
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

      if (SoapRequestResponse.errorMessage != "") {
        ShowSnackbarMessage.show(
          message: SoapRequestResponse.errorMessage,
          context: NavigatorKey.key.currentState!.context,
        );
        return;
      }

      if (execute) {
        ShowSnackbarMessage.show(
          message:
              "O agendamento está sendo executado com sucesso. Assim que finalizar, você receberá uma notificação.",
          context: NavigatorKey.key.currentState!.context,
          backgroundColor: Colors.green,
        );
        return;
      }

      final remoteData =
          (json.decode(SoapRequestResponse.responseAsString) as List)
              .map<ReportScheduleExecutionsModel>(
                  (e) => ReportScheduleExecutionsModel.fromJson(e))
              .toList();

      if (remoteData.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final index = _downloadedExecutions.indexWhere(
          (element) => element.ReportScheduleCode == reportScheduleCode);
      if (index == -1) {
        _downloadedExecutions.addAll(remoteData);
      } else {
        final existingReport = _downloadedExecutions[index];
        final newReportData = remoteData.first;

        // Ensure both the existing and new reports have at least one execution.
        if (existingReport.Executions.isNotEmpty &&
            newReportData.Executions.isNotEmpty) {
          // Get the new attachments from the server response.
          final newAttachments = newReportData.Executions.first.Attachments;

          // Add the new attachments to the existing report's latest execution.
          // This merges the PDF/XLSX without deleting what was already there.
          existingReport.Executions.first.Attachments.addAll(newAttachments);
        }
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
