import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform_plus/platform_plus.dart';
import 'package:provider/provider.dart';

import '../../../../api/api.dart';
import '../../../../providers/providers.dart';
import '../../../../utils/utils.dart';
import '../../../../components/components.dart';
import 'components.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  PermissionStatus? permissionStatus;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        updatePermissionStatus();
      }
    });
  }

  Future<void> updatePermissionStatus() async {
    if (PlatformPlus.platform.isMacOSNative) {
      return;
    }
    permissionStatus = await Permission.notification.status;
    setState(() {});
    debugPrint(permissionStatus.toString());
  }

  @override
  Widget build(BuildContext context) {
    LoginProvider loginProvider = Provider.of(context);
    return LifecycleManager(
      onAppResumed: updatePermissionStatus,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              GestureDetector(
                onLongPress: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(APPROUTES.WEB_LOGIN);
                },
                child: DrawerHeader(
                  child: Image.asset(
                    "lib/assets/Images/LogoCeltaTransparente.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              EnableNotifications(permissionStatus: permissionStatus),
              DrawerItem(
                onTap: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    APPROUTES.CONFIGURATIONS,
                  );
                },
                text: "Configurações",
                leading: Icon(
                  Icons.settings,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              DrawerItem(
                onTap: () async {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    APPROUTES.TECHNICAL_SUPPORT,
                  );
                },
                text: "Suporte técnico",
                leading: Icon(
                  Icons.add_call,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              DrawerItem(
                onTap: () async {
                  await UrlLauncher.searchAndLaunchUrl(
                    context: context,
                    url: 'https://www.celtaware.com.br',
                  );

                  Navigator.of(context).pop();
                  FirebaseHelper.addClickedInLink(
                    FirebaseCallEnum.aboutUs,
                  );
                },
                text: "Sobre nós",
                leading: Image.asset(
                  "lib/assets/Images/iconeCeltaware.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              DrawerItem(
                onTap: () async {
                  await UrlLauncher.searchAndLaunchUrl(
                    context: context,
                    url: 'https://www.instagram.com/celtaware_erp',
                  );
                  Navigator.of(context).pop();

                  FirebaseHelper.addClickedInLink(
                    FirebaseCallEnum.instagram,
                  );
                },
                text: "Instagram",
                leading: Image.asset(
                  "lib/assets/Images/instagram.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              DrawerItem(
                onTap: () async {
                  await UrlLauncher.searchAndLaunchUrl(
                    context: context,
                    url: 'https://www.linkedin.com/company/celtaware',
                  );
                  Navigator.of(context).pop();

                  FirebaseHelper.addClickedInLink(
                    FirebaseCallEnum.linkedin,
                  );
                },
                text: "Linkedin",
                leading: Image.asset(
                  "lib/assets/Images/linkedin.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              DrawerItem(
                onTap: () async {
                  await UrlLauncher.searchAndLaunchUrl(
                    context: context,
                    url: 'https://m.facebook.com/Celtaware',
                  );
                  Navigator.of(context).pop();

                  FirebaseHelper.addClickedInLink(
                    FirebaseCallEnum.facebook,
                  );
                },
                text: "Facebook",
                leading: Image.asset(
                  "lib/assets/Images/facebook.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              DrawerItem(
                onTap: () async {
                  ShowAlertDialog.show(
                    context: context,
                    title: 'Deseja fazer o logout?',
                    function: () async {
                      await loginProvider.logout();
                    },
                  );
                },
                text: "Sair",
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
