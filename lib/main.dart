import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_plus/platform_plus.dart';

import '../api/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformPlus.platform.init();
  await FirebaseHelper.initFirebase();

  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
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
