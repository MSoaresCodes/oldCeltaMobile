import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../components/components.dart';
import '../../../providers/providers.dart';

class ExcelButton extends StatelessWidget {
  final ReportScheduleModel reportSchedule;
  final bool alreadyDownloadedXlsx;
  const ExcelButton({
    super.key,
    required this.reportSchedule,
    required this.alreadyDownloadedXlsx,
  });

  Future<void> download(ReportsProvider reportsProvider) async {
    await reportsProvider.executeOrDownload(
      reportScheduleCode: reportSchedule.Code!,
      execute: false,
      sendEmailOnExecution: false,
      downloadPdf: false,
      downloadXlsx: true,
    );
  }

  Future<void> _saveFileToDevice(
    BuildContext context,
    ReportsProvider reportsProvider,
    ExecutionsModel xlsx,
  ) async {
    try {
      // 1. Find the specific XLSX attachment data within the provider's state.
      final fileName =
          "${reportSchedule.Name}-${DateFormat('yyyy-MM-dd').format(reportSchedule.LastExecutionDate!)}";

      // 3. Use file_saver to open the native "Save As" dialog.
      // This allows the user to choose the save location and file name.
      String? path = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: xlsx.Attachments.first.AttachmentBase64,
        fileExtension: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );

      // Optional: Show a success message to the user.
      if (context.mounted) {
        ShowSnackbarMessage.show(
          context: context,
          message:
              path == null ? "Operação cancelada" : "Arquivo salvo com sucesso",
          backgroundColor: path == null ? Colors.red : Colors.green,
        );
      }
    } catch (e) {
      // Handle any errors, such as the file not being found or the user cancelling the save.
      debugPrint("Error saving file: $e");
      if (context.mounted) {
        ShowSnackbarMessage.show(
          context: context,
          message: "Erro para salvar o arquivo: $e",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ReportsProvider reportsProvider = Provider.of(context, listen: false);

    ExecutionsModel? xlsx = alreadyDownloadedXlsx
        ? reportsProvider.downloadedExecutions
            .firstWhere(
              (e) => e.ReportScheduleCode == reportSchedule.Code,
            )
            .Executions
            .firstWhere(
                (e) => e.Attachments.any((a) => a.FileExtension == "xlsx"))
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: TextButton(
            onPressed: () async {
              if (alreadyDownloadedXlsx) {
                await _saveFileToDevice(context, reportsProvider, xlsx!);
              } else {
                await download(reportsProvider);
              }
            },
            child: FittedBox(
              child: Text(
                alreadyDownloadedXlsx
                    ? "Salvar XLSX no dispositivo"
                    : "Carregar XLSX",
              ),
            ),
          ),
        ),
        if (xlsx != null)
          Flexible(
            child: TextButton.icon(
              onPressed: () async {
                await download(reportsProvider);
              },
              label: FittedBox(
                  child: Text(DateFormat("dd/MM/yyyy HH:mm")
                      .format(xlsx.ExecutionDate!))),
              iconAlignment: IconAlignment.end,
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
