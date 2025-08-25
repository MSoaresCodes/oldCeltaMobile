import 'package:flutter/material.dart';

class DefaultModalPage {
  DefaultModalPage._();

  static Future<void> open(BuildContext context, Widget body) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to be full-screen
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
                child: GestureDetector(
              onTap: Navigator.of(context).pop,
            )),
            DraggableScrollableSheet(
              initialChildSize: 0.95,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          //dragglable indicator
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              height: 5,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          body,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
