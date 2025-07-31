import 'package:flutter/material.dart';

import '../../../Models/models.dart';
import '../../components.dart';

class OpenDialogProductInformations extends StatefulWidget {
  final GetProductJsonModel product;
  final List<MoreInformationWidget> pages;
  final String title;
  const OpenDialogProductInformations({
    required this.product,
    required this.pages,
    this.title = "Mais informações",
    Key? key,
  }) : super(key: key);

  @override
  State<OpenDialogProductInformations> createState() =>
      _OpenDialogProductInformationsState();
}

class _OpenDialogProductInformationsState
    extends State<OpenDialogProductInformations> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              widget.title,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 3),
          if (size.width > 310)
            Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(8),
                insetPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                actionsPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 8,
                ),
                content: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: PageView(
                    controller: _pageController,
                    children: widget.pages,
                  ),
                ),
                actions: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (var i = 0; i < widget.pages.length; i++)
                            ActionButton(
                              pageIndex: i,
                              pageController: _pageController,
                              textButton: widget.pages[i].moreInformationName,
                            ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Fechar",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            });
      },
    );
  }
}
