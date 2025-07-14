import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';

class PdfButton extends StatelessWidget {
  final ReportScheduleModel reportSchedule;
  final bool alreadyDownloadedPdf;
  const PdfButton({
    super.key,
    required this.reportSchedule,
    required this.alreadyDownloadedPdf,
  });

  Future<void> download(ReportsProvider reportsProvider) async {
    await reportsProvider.executeOrDownload(
      reportScheduleCode: reportSchedule.Code!,
      execute: false,
      sendEmailOnExecution: false,
      downloadPdf: true,
      downloadXlsx: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ReportsProvider reportsProvider = Provider.of(context, listen: false);
    PdfViewerProvider pdfViewerProvider = Provider.of(context, listen: false);

    ExecutionsModel? pdf = alreadyDownloadedPdf
        ? reportsProvider.downloadedExecutions
            .firstWhere(
              (e) => e.ReportScheduleCode == reportSchedule.Code,
            )
            .Executions
            .firstWhere(
                (e) => e.Attachments.any((a) => a.FileExtension == "pdf"))
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: TextButton(
            onPressed: () async {
              if (alreadyDownloadedPdf) {
                pdfViewerProvider.openPdfViewerPage(
                    pdf!.Attachments.first.AttachmentBase64,
                    reportSchedule.Name!);
              } else {
                await download(reportsProvider);
              }
            },
            child: FittedBox(
              child: Text(
                alreadyDownloadedPdf ? "Visualizar PDF" : "Baixar PDF",
              ),
            ),
          ),
        ),
        if (pdf != null)
          Flexible(
            child: TextButton.icon(
              onPressed: () async {
                await download(reportsProvider);
              },
              label: FittedBox(
                  child: Text(DateFormat("dd/MM/yyyy HH:mm")
                      .format(pdf.ExecutionDate!))),
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
