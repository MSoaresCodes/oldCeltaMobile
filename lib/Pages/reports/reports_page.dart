import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../providers/providers.dart';
import 'components/components.dart';

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

        ShowSnackbarMessage.show(
          message:
              "Somente relatórios agendados ou salvos serão exibidos. Caso precise de ajuda para configurar, entre em contato com o suporte",
          context: context,
          backgroundColor: Colors.green,
          secondsDuration: 7,
        );
        await reportsProvider.getReportSchedules();
      }
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    ReportsProvider reportsProvider = Provider.of(context, listen: true);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Agendamentos"),
            actions: [
              IconButton(
                  onPressed: reportsProvider.getReportSchedules,
                  icon: const Icon(Icons.refresh)),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              if (reportsProvider.reportSchedules.isEmpty &&
                  !reportsProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: Text("Nenhum agendamento encontrado"),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reportSchedule =
                          reportsProvider.reportSchedules[index];

                      final alreadyDownloadedPdf =
                          reportsProvider.downloadedExecutions.any(
                        (e) =>
                            e.ReportScheduleCode == reportSchedule.Code &&
                            e.Executions.any((x) => x.Attachments.any(
                                (y) => y.FileExtension == "pdf")),
                      );

                      final alreadyDownloadedXlsx =
                          reportsProvider.downloadedExecutions.any(
                        (e) =>
                            e.ReportScheduleCode == reportSchedule.Code &&
                            e.Executions.any((x) => x.Attachments.any(
                                (y) => y.FileExtension == "xlsx")),
                      );

                      return Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  TitleAndSubtitle.titleAndSubtitle(
                                      title: "Nome",
                                      subtitle: reportSchedule.Name!),
                                  TitleAndSubtitle.titleAndSubtitle(
                                      title: "Categoria",
                                      subtitle: reportSchedule.CategoryName!),
                                  TitleAndSubtitle.titleAndSubtitle(
                                      title: "Sub categoria",
                                      subtitle:
                                          reportSchedule.SubCategoryName!),
                                  TitleAndSubtitle.titleAndSubtitle(
                                      title: "Relatório",
                                      subtitle:
                                          reportSchedule.ReportModelName!),
                                  if (reportSchedule.LastExecutionDate != null)
                                    TitleAndSubtitle.titleAndSubtitle(
                                        title: "Últ. execução",
                                        subtitle: DateFormat('dd/MM/yyyy HH:mm')
                                            .format(reportSchedule
                                                .LastExecutionDate!)),
                                  if (reportSchedule
                                          .LastExecutionStartDateTime !=
                                      null)
                                    TitleAndSubtitle.titleAndSubtitle(
                                      title:
                                          "Último horário de início da execução",
                                      subtitle: reportSchedule
                                          .LastExecutionStartDateTime!
                                          .toString(),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (reportSchedule.LastExecutionDate !=
                                    null) ...[
                                  PdfButton(
                                    reportSchedule: reportSchedule,
                                    alreadyDownloadedPdf: alreadyDownloadedPdf,
                                  ),
                                  ExcelButton(
                                    reportSchedule: reportSchedule,
                                    alreadyDownloadedXlsx:
                                        alreadyDownloadedXlsx,
                                  ),
                                ],
                                ExecuteButton(reportSchedule: reportSchedule),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: reportsProvider.reportSchedules.length,
                  ),
                ),
            ],
          ),
        ),
        loadingWidget(reportsProvider.isLoading),
      ],
    );
  }
}
