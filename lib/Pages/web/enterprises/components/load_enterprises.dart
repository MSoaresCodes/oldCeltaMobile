import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../providers/providers.dart';
import '../../../../utils/utils.dart';

class LoadEnterprises extends StatelessWidget {
  final WebProvider webProvider;
  const LoadEnterprises({
    super.key,
    required this.webProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () async {
          await webProvider.getAllClients();

          if (webProvider.errorMessageClients != "") {
            ShowSnackbarMessage.show(
              message: DefaultErrorMessage.ERROR,
              context: context,
            );
          }
        },
        child: const Text(
          "Consultar empresas",
        ),
      ),
    );
  }
}
