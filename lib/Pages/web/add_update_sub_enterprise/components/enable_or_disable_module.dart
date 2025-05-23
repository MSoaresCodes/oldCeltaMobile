import 'package:flutter/material.dart';

import '../../../../Models/models.dart';

class EnableOrDisableModule extends StatefulWidget {
  final List<ModuleModel> modules;
  final void Function(int index)? updateEnabled;
  const EnableOrDisableModule({
    required this.modules,
    required this.updateEnabled,
    super.key,
  });

  @override
  State<EnableOrDisableModule> createState() => _EnableOrDisableModuleState();
}

class _EnableOrDisableModuleState extends State<EnableOrDisableModule> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.modules.length,
      itemBuilder: (context, index) {
        final module = widget.modules[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Container(
            decoration: BoxDecoration(
              color: module.enabled == true
                  ? Theme.of(context).colorScheme.primary.withAlpha(100)
                  : Colors.red.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                onTap: widget.updateEnabled == null
                    ? null
                    : () {
                        widget.updateEnabled!(index);
                      },
                child: Row(
                  children: [
                    Expanded(child: Text(module.name)),
                    Switch(
                      value: module.enabled == true,
                      onChanged: widget.updateEnabled == null
                          ? null
                          : (_) {
                              widget.updateEnabled!(index);
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
