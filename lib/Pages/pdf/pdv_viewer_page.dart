import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:file_saver/file_saver.dart';
import 'package:provider/provider.dart';

import '../../components/components.dart';
import '../../providers/providers.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late final PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    final pdfViewerProvider =
        Provider.of<PdfViewerProvider>(context, listen: false);

    _pdfController = PdfController(
      document: PdfDocument.openData(pdfViewerProvider.pdfBytes!),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  /// Saves the PDF to the device using file_saver
  Future<void> _savePdf(PdfViewerProvider pdfViewerProvider) async {
    try {
      await FileSaver.instance.saveFile(
        name: pdfViewerProvider.fileName!,
        bytes: pdfViewerProvider.pdfBytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
      // Show a confirmation message
      if (mounted) {
        ShowSnackbarMessage.show(
          message: '${pdfViewerProvider.fileName} salvo com sucesso!',
          context: context,
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      debugPrint("❌ An error occurred while saving the PDF: $e");
      ShowSnackbarMessage.show(
        message: 'Erro para salvar o arquivo: $e',
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfViewerProvider =
        Provider.of<PdfViewerProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(pdfViewerProvider.fileName!),
        actions: [
          // Add a save button to the AppBar
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => _savePdf(pdfViewerProvider),
            tooltip: 'Salvar PDF',
          ),
        ],
      ),
      body: PdfView(
        controller: _pdfController,
      ),
    );
  }
}
