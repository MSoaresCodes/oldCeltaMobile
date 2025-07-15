import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/components.dart';
import '../../providers/providers.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late final PdfControllerPinch _pdfPinchController;
  late final PdfController _pdfController;

  @override
  void initState() {
    super.initState();

    final pdfViewerProvider =
        Provider.of<PdfViewerProvider>(context, listen: false);

    _pdfPinchController = PdfControllerPinch(
      document: PdfDocument.openData(pdfViewerProvider.pdfBytes!),
      viewportFraction: 1,
    );
    _pdfController = PdfController(
      document: PdfDocument.openData(pdfViewerProvider.pdfBytes!),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // IMPORTANT! When dispose the page, is enabled landscape mode
    _pdfPinchController.dispose();
    _pdfController.dispose();

    super.dispose();
  }

  /// Saves the PDF to the device using file_saver
  Future<void> _sharePdf(PdfViewerProvider pdfViewerProvider) async {
    try {
      // Create an XFile object directly from the byte data in memory.
      // This is more efficient than saving to a temporary file first.

      final pdfFile = XFile.fromData(
        pdfViewerProvider.pdfBytes!,
        name: pdfViewerProvider.fileName!,
        mimeType: 'application/pdf',
      );

      // Use Share.shareXFiles to open the native share dialog.
      await SharePlus.instance.share(
        ShareParams(
          files: [pdfFile],
          text: "Compartilhar PDF",
          downloadFallbackEnabled: true,
          title: pdfViewerProvider.fileName,
          previewThumbnail: pdfFile,
          mailToFallbackEnabled: true,
          fileNameOverrides: ['${pdfViewerProvider.fileName!}.pdf'],
        ),
      );
    } catch (e) {
      debugPrint("❌ An error occurred while sharing the PDF: $e");
      if (context.mounted) {
        ShowSnackbarMessage.show(
          message: 'Could not share file: $e',
          context: context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfViewerProvider =
        Provider.of<PdfViewerProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        title: FittedBox(child: Text(pdfViewerProvider.fileName!)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(pdfViewerProvider),
            tooltip: 'Compartilhar PDF',
          ),
        ],
      ),
      body: Stack(
        children: [
          Platform.isWindows
              ? PdfView(controller: _pdfController)
              : PdfViewPinch(
                  controller: _pdfPinchController,
                  maxScale: 1.5,
                  minScale: 1,
                ),
        ],
      ),
    );
  }
}
