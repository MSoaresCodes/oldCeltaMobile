import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../components/components.dart';
import '../../../../../Models/firebase/firebase.dart';
import '../../../../providers/providers.dart';

class EditUrlCcs extends StatefulWidget {
  final FirebaseEnterpriseModel client;
  const EditUrlCcs({
    required this.client,
    super.key,
  });

  @override
  State<EditUrlCcs> createState() => _EditUrlCcsState();
}

class _EditUrlCcsState extends State<EditUrlCcs> {
  bool showFormField = false;
  final urlCcsController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    urlCcsController.dispose();
  }

  void _updateUrlCcs(WebProvider webProvider) {
    ShowAlertDialog.show(
      context: context,
      title: "Deseja realmente alterar a URL?",
      content: SingleChildScrollView(
        child: Text(
          "Nova URL: \n${urlCcsController.text}",
          textAlign: TextAlign.center,
        ),
      ),
      function: () async {
        if (!urlCcsController.text.toLowerCase().contains("http") ||
            !urlCcsController.text.contains(":") ||
            !urlCcsController.text.contains("//") ||
            !urlCcsController.text.contains("\.")) {
          ShowSnackbarMessage.show(
              message:
                  "Viiixi, acho que essa URL tá errada hein... confirma aew",
              context: context);
          return;
        }
        await webProvider.updateEnterpriseCcs(
          context: context,
          enterpriseId: widget.client.id!,
          newUrlCcs: urlCcsController.text,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WebProvider webProvider = Provider.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 8,
              child: Text("URL CCS\n${widget.client.urlCCS}"),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  urlCcsController.text = widget.client.urlCCS;
                  setState(() {
                    showFormField = !showFormField;
                  });
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          ],
        ),
        Visibility(
          visible: showFormField,
          child: Column(
            children: [
              TextFormField(
                controller: urlCcsController,
                decoration: FormFieldDecoration.decoration(
                  context: context,
                ),
                onFieldSubmitted: (_) {
                  _updateUrlCcs(webProvider);
                },
              ),
              TextButton(
                onPressed: () async {
                  _updateUrlCcs(webProvider);
                },
                child: const Text("Alterar"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
