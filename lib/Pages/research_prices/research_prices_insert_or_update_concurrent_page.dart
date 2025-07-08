import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/models.dart';
import '../../components/components.dart';
import '../../providers/providers.dart';
import 'components/components.dart';

class ResearchPricesInsertOrUpdateConcurrentPage extends StatefulWidget {
  const ResearchPricesInsertOrUpdateConcurrentPage({super.key});

  @override
  State<ResearchPricesInsertOrUpdateConcurrentPage> createState() =>
      _ResearchPricesInsertOrUpdateConcurrentPageState();
}

class _ResearchPricesInsertOrUpdateConcurrentPageState
    extends State<ResearchPricesInsertOrUpdateConcurrentPage> {
  FocusNode _nameFocusNode = FocusNode();
  TextEditingController nameController = TextEditingController();

  FocusNode observationFocusNode = FocusNode();
  TextEditingController observationController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AddressModel? newAddress;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        ResearchPricesProvider researchPricesProvider =
            Provider.of(context, listen: false);

        final concurrent = researchPricesProvider.selectedConcurrent;

        if (concurrent != null) {
          setState(() {
            observationController.text = concurrent.Observation ?? "";
            nameController.text = concurrent.Name ?? "";
            newAddress = concurrent.Address;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameFocusNode.dispose();
    nameController.dispose();
    observationFocusNode.dispose();
    observationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResearchPricesProvider researchPricesProvider = Provider.of(context);
    AddressProvider addressProvider = Provider.of(context);

    return Stack(
      children: [
        PopScope(
          onPopInvokedWithResult: (_, __) {
            researchPricesProvider.updateSelectedConcurrent(null);
          },
          child: Scaffold(
            appBar: AppBar(
              title: FittedBox(
                child: Text(
                  researchPricesProvider.selectedConcurrent == null
                      ? "Cadastrar concorrente"
                      : "Alterar concorrente (${researchPricesProvider.selectedConcurrent!.ConcurrentCode})",
                ),
              ),
            ),
            body: SingleChildScrollView(
              primary: false,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      NameField(
                        nameFocusNode: _nameFocusNode,
                        observationFocusNode: observationFocusNode,
                        nameController: nameController,
                      ),
                      const SizedBox(height: 8),
                      ObservationField(
                        observationFocusNode: observationFocusNode,
                        observationController: observationController,
                      ),
                      const SizedBox(height: 15),
                      const ChangeAddress(),
                      const SizedBox(height: 8),
                      ConfirmOrUpdateButton(
                        formKey: _formKey,
                        nameController: nameController,
                        observationController: observationController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        loadingWidget(researchPricesProvider.isLoadingAddOrUpdateConcurrents),
        loadingWidget(addressProvider.isLoading),
      ],
    );
  }
}
