import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class EnableNotifications extends StatefulWidget {
  final PermissionStatus? permissionStatus;
  const EnableNotifications({super.key, this.permissionStatus});

  @override
  State<EnableNotifications> createState() => _EnableNotificationsState();
}

class _EnableNotificationsState extends State<EnableNotifications>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> openPermissionsIfIsDisabled() async {
    //TODO test this because wasnt installing in the phone
    if (widget.permissionStatus?.isGranted == true) {
      print("Notification permission is granted.");

      return;
    }

    if (widget.permissionStatus?.isDenied == true) {
      final result = await Permission.notification.request();
      if (result.isGranted) {
        print("Notification permission granted after request.");
      } else {
        print("User denied the notification permission.");
      }
      return;
    }

    if (widget.permissionStatus?.isPermanentlyDenied == true) {
      print("Permission is permanently denied. Opening app settings.");

      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.permissionStatus?.isGranted == true
        ? Container()
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
              child: ElevatedButton(
                onPressed: openPermissionsIfIsDisabled,
                child: const Text("Habilitar notificações"),
              ),
            ),
          );
  }
}
