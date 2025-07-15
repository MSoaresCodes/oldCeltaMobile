import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import '../../../providers/providers.dart';
import '../components/components.dart';
import './components/components.dart';

class EnterprisesPage extends StatelessWidget {
  const EnterprisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    WebProvider webProvider = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        // leading: const Text(""),
        title: webProvider.enterprises.isEmpty
            ? null
            : FittedBox(
                child: Text(
                  "${webProvider.enterprises.length} empresas",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
        actions: [
          const AddEnterpriseButton(),
          IconButton(
              onPressed: () async {
                await webProvider.getAllClients();
              },
              icon: const Icon(
                Icons.refresh,
              )),
        ],
      ),
      body: Column(
        children: [
          if (webProvider.enterprises.isNotEmpty) const WebEnterpriseItems(),
          if (webProvider.enterprises.isEmpty)
            LoadEnterprises(webProvider: webProvider),
        ],
      ),
    );
  }
}
