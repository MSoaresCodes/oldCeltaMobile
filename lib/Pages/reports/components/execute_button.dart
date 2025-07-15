import 'package:celta_inventario/components/components.dart'
    show ShowAlertDialog;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/models.dart';
import '../../../providers/providers.dart';

class ExecuteButton extends StatelessWidget {
  final ReportScheduleModel reportSchedule;
  const ExecuteButton({super.key, required this.reportSchedule});

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<ReportsProvider>(context);

    bool sendEmail = false;
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () async {
          await ShowAlertDialog.show(
            context: context,
            title: "Leia com atenção",
            cancelMessage: "Cancelar",
            confirmMessage: "Executar",
            // insetPadding: EdgeInsets.all(0),
            contentPadding: const EdgeInsets.all(5),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            content: StatefulBuilder(builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "IMPORTANTE! Como o relatório pode demorar para ser executado, você precisa atualizar os agendamentos para verificar se a data da última atualização foi atualizada!",
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        setState(() {
                          sendEmail = !sendEmail;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                            border: Border.all(
                              strokeAlign: 0.3,
                              width: 0.3,
                            ),
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 1,
                              ),
                            ]),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text("Enviar por e-mail"),
                            ),
                            Checkbox(
                              value: sendEmail,
                              onChanged: (_) {
                                setState(() {
                                  sendEmail = !sendEmail;
                                });
                                debugPrint(sendEmail.toString());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            function: () async {
              await reportsProvider.executeOrDownload(
                reportScheduleCode: reportSchedule.Code!,
                execute: true,
                sendEmailOnExecution: sendEmail,
                downloadPdf: false,
                downloadXlsx: false,
              );
            },
          );

          sendEmail = false;
        },
        child: const Text("Executar"),
      ),
    );
  }
}
