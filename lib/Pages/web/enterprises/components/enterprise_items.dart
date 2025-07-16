import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Models/firebase/firebase.dart';
import '../../../../components/components.dart';
import '../../../../providers/providers.dart';
import '../../../../utils/utils.dart';

class WebEnterpriseItems extends StatefulWidget {
  const WebEnterpriseItems({
    super.key,
  });

  @override
  State<WebEnterpriseItems> createState() => _WebEnterpriseItemsState();
}

class _WebEnterpriseItemsState extends State<WebEnterpriseItems> {
  final filterEnterpriseController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    filterEnterpriseController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WebProvider webProvider = Provider.of(context, listen: false);

    final enterprises = webProvider.enterprises
        .where((e) => e.enterpriseName.toLowerCase().contains(
              filterEnterpriseController.text.toLowerCase(),
            ))
        .toList();

    return Column(
      children: [
        if (webProvider.enterprises.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: filterEnterpriseController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: FormFieldDecoration.decoration(
                context: context,
                suffixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: enterprises.length,
          itemBuilder: (context, index) {
            FirebaseEnterpriseModel client = enterprises[index];

            return Card(
              child: ListTile(
                onTap: () {
                  webProvider.indexOfSelectedEnterprise = index;
                  Navigator.of(context).pushNamed(
                    APPROUTES.WEB_ENTERPRISE_DETAILS,
                  );
                },
                trailing: Icon(
                  Icons.remove_red_eye_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(client.enterpriseName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(client.urlCCS),
                    // if (client.usersInformations != null)
                    //   Text(
                    //       "Quantidade de usuários: ${client.usersInformations!.length}"),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
