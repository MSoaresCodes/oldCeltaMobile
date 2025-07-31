import 'package:flutter/material.dart';

class LifecycleManager extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAppResumed;
  const LifecycleManager({super.key, required this.child, this.onAppResumed});

  @override
  State<LifecycleManager> createState() => _LifecycleManagerState();
}

// Use the WidgetsBindingObserver mixin to listen for lifecycle changes.
class _LifecycleManagerState extends State<LifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register the observer.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister the observer to prevent memory leaks.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This method is called whenever the app lifecycle state changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // A switch statement to handle each lifecycle state.
    switch (state) {
      case AppLifecycleState.resumed:
        print("✅ App Resumed");
        if (widget.onAppResumed != null) {
          widget.onAppResumed!();
        }
        break;
      case AppLifecycleState.paused:
        print("⏸️ App Paused (Minimized)");
        break;
      case AppLifecycleState.inactive:
        print("➖ App Inactive");
        break;
      case AppLifecycleState.detached:
        print("❌ App Detached");
        break;
      case AppLifecycleState.hidden:
        print("🙈 App Hidden");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This just returns the child widget that was passed in.
    return widget.child;
  }
}
