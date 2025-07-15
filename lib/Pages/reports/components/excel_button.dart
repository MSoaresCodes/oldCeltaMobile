import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
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
                //TODO download in device. Create an option to select the path to download
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
