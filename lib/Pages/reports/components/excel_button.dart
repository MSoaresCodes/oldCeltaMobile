import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> _sharePdf(
    BuildContext context,
    ReportsProvider reportsProvider,
    ExecutionsModel attachments,
  ) async {
    try {
      // Create an XFile object directly from the byte data in memory.
      // This is more efficient than saving to a temporary file first.
      final xlsxFile = XFile.fromData(
        attachments.Attachments.firstWhere((e) => e.FileExtension == "xlsx")
            .AttachmentBase64,
        name: reportSchedule.Name,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

      // Use Share.shareXFiles to open the native share dialog.
      await SharePlus.instance.share(
        ShareParams(
          files: [xlsxFile],
          text: "Compartilhar planilha: ${reportSchedule.Name}",
          fileNameOverrides: ["${reportSchedule.Name}.xlsx"],
        ),
      );
    } catch (e) {
      debugPrint("❌ An error occurred while sharing the PDF: $e");
      if (context.mounted) {
        ShowSnackbarMessage.show(
          message: 'Could not share file: $e',
          context: context,
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
                await _sharePdf(context, reportsProvider, xlsx!);
              } else {
                await download(reportsProvider);
              }
            },
            child: FittedBox(
              child: Text(
                alreadyDownloadedXlsx
                    ? "Compartilhar planilha"
                    : "Baixar planilha",
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
