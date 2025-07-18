import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../components/components.dart';
import '../../providers/providers.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
    final pdfViewerProvider = Provider.of<PdfViewerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(pdfViewerProvider.fileName ?? 'PDF Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePdf(pdfViewerProvider),
            tooltip: 'Compartilhar PDF',
          ),
        ],
      ),
      body: SfPdfViewer.memory(
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        enableDocumentLinkAnnotation: true,
        enableHyperlinkNavigation: true,
        interactionMode: PdfInteractionMode.selection,
        canShowScrollStatus: true,
        canShowScrollHead: true,
        pdfViewerProvider.pdfBytes!,
        canShowTextSelectionMenu: true,
      ),
    );
  }
}
