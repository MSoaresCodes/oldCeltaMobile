import 'package:flutter/material.dart';
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
    ReportsProvider reportsProvider = Provider.of(context, listen: false);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Relatórios"),
          ),
          body: const Center(
            child: Text("Relatórios"),
          ),
        ),
        loadingWidget(reportsProvider.isLoading),
      ],
    );
  }
}
