import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Use PdfControllerPinch to enable zoom controls.
  late final PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    final pdfViewerProvider =
        Provider.of<PdfViewerProvider>(context, listen: false);

    // Initialize the correct controller for zooming.
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openData(pdfViewerProvider.pdfBytes!),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _pdfController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  /// Saves the PDF to the device using file_saver
  Future<void> _savePdf(PdfViewerProvider pdfViewerProvider) async {
    try {
      String? path = await FileSaver.instance.saveAs(
        name: pdfViewerProvider.fileName!,
        bytes: pdfViewerProvider.pdfBytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );

      // Show a confirmation message
      if (context.mounted) {
        ShowSnackbarMessage.show(
          context: context,
          message:
              path == null ? "Operação cancelada" : "Arquivo salvo com sucesso",
          backgroundColor: path == null ? Colors.red : Colors.green,
        );
      }
    } catch (e) {
      debugPrint("❌ An error occurred while saving the PDF: $e");
      if (context.mounted) {
        ShowSnackbarMessage.show(
          message: 'Erro para salvar o arquivo: $e',
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
        title: FittedBox(child: Text(pdfViewerProvider.fileName!)),
        actions: [
          // Add a save button to the AppBar
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => _savePdf(pdfViewerProvider),
            tooltip: 'Salvar PDF',
          ),
        ],
      ),
      // Use a LayoutBuilder to get the viewport dimensions,
      // which is necessary for calculating the center point for our zoom transformation.
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate the center of the available space for centered zooming.
          final Offset center =
              Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

          // Define the zoom limits.
          const double minZoom = 1;
          const double maxZoom = 1.75;

          return Stack(
            children: [
              // Add padding to the bottom of the viewer. This creates a safe area
              // so the floating buttons don't cover the last page's content.
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: PdfViewPinch(
                  controller: _pdfController,
                  // backgroundColor: Colors.grey[200],
                ),
              ),
              // Positioned widget to place the zoom controls.
              Positioned(
                bottom: 3,
                right: 3,
                // Use a ValueListenableBuilder to rebuild the buttons whenever the zoom
                // level changes, allowing us to disable them at the limits.
                child: ValueListenableBuilder<Matrix4>(
                  valueListenable: _pdfController,
                  builder: (context, matrix, child) {
                    // Get the current zoom level from the transformation matrix.
                    final currentZoom = matrix.row0[0];

                    return Row(
                      children: [
                        // FloatingActionButton for zooming in.
                        FloatingActionButton(
                          heroTag: 'zoomIn', // Unique hero tag
                          mini: true,
                          // The button is disabled if the current zoom is at or above the max.
                          onPressed: currentZoom >= maxZoom
                              ? null
                              : () {
                                  final Matrix4 zoomMatrix = Matrix4.identity()
                                    ..translate(center.dx, center.dy)
                                    ..scale(1.25) // Zoom in by 25%
                                    ..translate(-center.dx, -center.dy);
                                  _pdfController.value = _pdfController.value
                                      .multiplied(zoomMatrix);
                                  setState(() {});
                                },
                          child: Icon(
                            Icons.zoom_in,
                            color: currentZoom >= maxZoom ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // FloatingActionButton for zooming out.
                        FloatingActionButton(
                          heroTag: 'zoomOut', // Unique hero tag
                          mini: true,
                          // The button is disabled if the current zoom is at or below the min.
                          onPressed: currentZoom <= minZoom
                              ? null
                              : () {
                                  final Matrix4 zoomMatrix = Matrix4.identity()
                                    ..translate(center.dx, center.dy)
                                    ..scale(0.8) // Zoom out
                                    ..translate(-center.dx, -center.dy);
                                  _pdfController.value = _pdfController.value
                                      .multiplied(zoomMatrix);
                                },
                          child: Icon(
                            Icons.zoom_out,
                            color: currentZoom <= minZoom ? Colors.grey : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
