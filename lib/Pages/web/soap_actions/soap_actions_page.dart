import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import '../web.dart';
import '../../../providers/providers.dart';

class SoapActionsPage extends StatefulWidget {
  const SoapActionsPage({super.key});

  @override
  State<SoapActionsPage> createState() => _SoapActionsPageState();
}

class _SoapActionsPageState extends State<SoapActionsPage> {
  @override
  Widget build(BuildContext context) {
    WebProvider webProvider = Provider.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("TOTAL DE REQUISIÇÕES")),
      body: webProvider.enterprisesNames.isEmpty
          ? Center(
              child: TextButton(
                onPressed: () async {
                  await webProvider.getLastThreeMonthsSoapActions();
                },
                child: const Text("Carregar requisições"),
              ),
            )
          : SoapActionsItems(pageContext: context),
    );
  }
}
