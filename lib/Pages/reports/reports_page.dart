import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../providers/providers.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        ReportsProvider reportsProvider = Provider.of(context, listen: false);
        await reportsProvider.getReportSchedules();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ReportsProvider reportsProvider = Provider.of(context, listen: true);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Relatórios"),
            actions: [
              IconButton(
                  onPressed: reportsProvider.getReportSchedules,
                  icon: const Icon(Icons.refresh)),
            ],
          ),
          body: ListView.builder(
            itemCount: reportsProvider.reportSchedules.length,
            itemBuilder: (context, index) {
              final reportSchedule = reportsProvider.reportSchedules[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TitleAndSubtitle.titleAndSubtitle(
                          title: "Nome", subtitle: reportSchedule.Name!),
                      TitleAndSubtitle.titleAndSubtitle(
                          title: "Categoria",
                          subtitle: reportSchedule.CategoryName!),
                      TitleAndSubtitle.titleAndSubtitle(
                          title: "Sub categoria",
                          subtitle: reportSchedule.SubCategoryName!),
                      TitleAndSubtitle.titleAndSubtitle(
                          title: "Nome do relatório",
                          subtitle: reportSchedule.ReportModelName!),
                      if (reportSchedule.LastExecutionDate != null)
                        TitleAndSubtitle.titleAndSubtitle(
                            title: "Última execução",
                            subtitle: DateFormat('dd/MM/yyyy HH:mm:ss')
                                .format(reportSchedule.LastExecutionDate!)),
                      if (reportSchedule.LastExecutionStartDateTime != null)
                        TitleAndSubtitle.titleAndSubtitle(
                          title: "Último horário de início da execução",
                          subtitle: reportSchedule.LastExecutionStartDateTime!
                              .toString(),
                        ),
                      Row(children: [
                        Expanded(
                          child: TextButton(
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
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              await reportsProvider.executeOrDownload(
                                reportScheduleCode: reportSchedule.Code!,
                                execute: false,
                                sendEmailOnExecution: false,
                                downloadPdf: true,
                                downloadXlsx: true,
                              );
                            },
                            child: const Text("Baixar"),
                          ),
                        ),
                      ])
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        loadingWidget(reportsProvider.isLoading),
      ],
    );
  }
}
