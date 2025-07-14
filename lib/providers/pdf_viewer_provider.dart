import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/utils.dart';

class PdfViewerProvider with ChangeNotifier {
  Uint8List? _pdfBytes;
  Uint8List? get pdfBytes => _pdfBytes;
  String? _fileName;
  String? get fileName => _fileName;

  void openPdfViewerPage(Uint8List pdfBytes, String fileName) {
    _pdfBytes = pdfBytes;
    _fileName = fileName;
    final context = NavigatorKey.key.currentState!.context;

    Navigator.of(context).pushNamed(APPROUTES.PDF_VIEWER);
  }
}
