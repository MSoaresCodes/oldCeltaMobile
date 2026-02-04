import 'package:flutter/material.dart';

import '../api/api.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              UrlLauncher.searchAndLaunchUrl(
                url: 'https://celtamobile.web.app',
                context: context,
              );
            },
            child: const Text(
              'Esse aplicativo foi descontinuado. Clique aqui para acessar o novo site',
            ),
          ),
        ),
      ),
    );
  }
}
