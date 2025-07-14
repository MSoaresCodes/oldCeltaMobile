import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    ReportsProvider reportsProvider = Provider.of(context, listen: false);

    return TextButton(
      onPressed: () async {
        if (alreadyDownloadedPdf) {
        } else {
          await reportsProvider.executeOrDownload(
            reportScheduleCode: reportSchedule.Code!,
            execute: false,
            sendEmailOnExecution: false,
            downloadPdf: true,
            downloadXlsx: true,
          );
        }
      },
      child: Text(alreadyDownloadedPdf ? "Visualizar PDF" : "Baixar PDF"),
    );
  }
}
