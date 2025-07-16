import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../components/components.dart';
import 'enterprises/enterprises_page.dart';
import 'soap_actions/soap_actions_page.dart';
import '../../providers/providers.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({super.key});

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  List _pages = [
    const EnterprisesPage(),
    const SoapActionsPage(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await Provider.of<WebProvider>(context, listen: false).getAllClients();
        await Provider.of<WebProvider>(context, listen: false)
            .getLastThreeMonthsSoapActions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WebProvider webProvider = Provider.of(context);

    return Stack(
      children: [
        Scaffold(
          body: _pages.elementAt(webProvider.selectedBottomNavigationBarIndex),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: webProvider.selectedBottomNavigationBarIndex,
            onTap: (index) {
              setState(() {
                webProvider.selectedBottomNavigationBarIndex = index;
              });
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: "Empresas",
              ),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart), label: "Requisições"),
            ],
          ),
        ),
        loadingWidget(webProvider.isLoading),
      ],
    );
  }
}
