import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/components.dart';
import '../../../Models/enterprise/enterprise.dart';
import '../../../providers/providers.dart';
import './components/components.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({Key? key}) : super(key: key);

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  final observationsController = TextEditingController();
  final filterDocumentController = TextEditingController();
  bool isLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    EnterpriseModel enterprise =
        ModalRoute.of(context)!.settings.arguments as EnterpriseModel;
    if (!isLoaded) {
      Provider.of<ReceiptProvider>(context, listen: true).getReceipt(
        enterpriseCode: enterprise.Code,
        context: context,
      );
    }
    isLoaded = true;
  }

  @override
  void dispose() {
    super.dispose();

    observationsController.dispose();
    filterDocumentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ReceiptProvider receiptProvider = Provider.of(context);
    EnterpriseModel enterprise =
        ModalRoute.of(context)!.settings.arguments as EnterpriseModel;

    return Stack(
      children: [
        PopScope(
          canPop: !receiptProvider.isLoadingLiberateCheck,
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'RECEBIMENTOS',
              ),
              actions: [
                SearchReceiptButton(enterprise: enterprise),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await receiptProvider.getReceipt(
                  enterpriseCode: enterprise.Code,
                  context: context,
                  isSearchingAgain: true,
                );
              },
              child: Column(
                children: [
                  if (receiptProvider.errorMessage != '' &&
                      receiptProvider.receiptCount == 0 &&
                      !receiptProvider.isLoadingReceipt)
                    Expanded(
                      child: searchAgain(
                          errorMessage: receiptProvider.errorMessage,
                          request: () async {
                            setState(() {});
                            await receiptProvider.getReceipt(
                              enterpriseCode: enterprise.Code,
                              context: context,
                            );
                          }),
                    ),
                  if (!receiptProvider.isLoadingReceipt &&
                      receiptProvider.errorMessage == '')
                    Expanded(
                      child: ReceiptItems(
                        enterprise: enterprise,
                        observationsController: observationsController,
                        filterDocumentController: filterDocumentController,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        loadingWidget(receiptProvider.isLoadingReceipt),
        loadingWidget(receiptProvider.isLoadingLiberateCheck),
      ],
    );
  }
}
