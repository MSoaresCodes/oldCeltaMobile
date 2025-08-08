import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/utils.dart';

class PdfViewerProvider with ChangeNotifier {
  Uint8List? _pdfBytes;
  Uint8List? get pdfBytes => _pdfBytes;
  String? _fileName;
  String? get fileName => _fileName;

  Future<void> openPdfViewerPage(Uint8List pdfBytes, String fileName) async {
    _pdfBytes = pdfBytes;
    _fileName = fileName;
    final context = NavigatorKey.key.currentState!.context;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final closed = await Navigator.of(context).pushNamed(APPROUTES.PDF_VIEWER);

    if (closed == true) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }
}
