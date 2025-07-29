import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final String text;
  final Widget leading;
  final Function()? onTap;
  const DrawerItem({
    super.key,
    required this.text,
    required this.leading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: leading,
          ),
          title: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
