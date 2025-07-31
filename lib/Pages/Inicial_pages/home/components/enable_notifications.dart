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
    if (widget.permissionStatus?.isGranted == true) {
      print("Notification permission is granted.");
      return;
    }

    await openAppSettings();
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
