import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Models/firebase/firebase.dart';
import '../../../components/components.dart';
import '../../../providers/providers.dart';
import 'enterprise_details.dart';

class WebEnterpriseDetailsPage extends StatefulWidget {
  const WebEnterpriseDetailsPage({super.key});

  @override
  State<WebEnterpriseDetailsPage> createState() =>
      _WebEnterpriseDetailsPageState();
}

class _WebEnterpriseDetailsPageState extends State<WebEnterpriseDetailsPage> {
  FirebaseEnterpriseModel? client;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WebProvider webProvider = Provider.of(context, listen: false);
      setState(() {
        client = webProvider.enterprises[webProvider.indexOfSelectedEnterprise];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    WebProvider webProvider = Provider.of(context);

    return Stack(
      children: [
        PopScope(
          onPopInvokedWithResult: (didPop, result) {
            webProvider.indexOfSelectedEnterprise = -1;
          },
          child: Scaffold(
            appBar: appBarEnterprise(
              context: context,
              client: client,
              webProvider: webProvider,
            ),
            body: Padding(
              padding: const EdgeInsets.all(4),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (client != null) EditUrlCcs(client: client!),
                    const SubEnterprisesItems(),
                  ],
                ),
              ),
            ),
          ),
        ),
        loadingWidget(webProvider.isLoading),
      ],
    );
  }
}
