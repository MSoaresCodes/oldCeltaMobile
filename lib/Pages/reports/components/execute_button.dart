import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';

class ExecuteButton extends StatelessWidget {
  final ReportScheduleModel reportSchedule;
  const ExecuteButton({super.key, required this.reportSchedule});

  @override
  Widget build(BuildContext context) {
    ReportsProvider reportsProvider = Provider.of(context, listen: false);

    return TextButton(
      onPressed: () async {
        await reportsProvider.executeOrDownload(
          reportScheduleCode: reportSchedule.Code!,
          execute: true,
          sendEmailOnExecution: true,
          downloadPdf: false,
          downloadXlsx: false,
        );
      },
      child: const Text("Executar"),
    );
  }
}
