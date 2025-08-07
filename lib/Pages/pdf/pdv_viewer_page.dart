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
  late final PdfViewerController _pdfController;
  final _searchTextController = TextEditingController();
  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  bool _isSearchVisible = false;

  @override
  void initState() {
    //hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);

    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    //enable status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _searchTextController.dispose();
    _pdfController.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _searchResult.removeListener(_searchResultListener);
    super.dispose();
  }

  void _toggleSearchUI() {
    setState(() {
      if (_isSearchVisible) {
        // If closing the search, clear the results and text.
        _searchResult.clear();
        _searchTextController.clear();
      }
      _isSearchVisible = !_isSearchVisible;
    });
  }

  void _searchResultListener() {
    if (_searchResult.hasResult) {
      setState(() {});
    }
  }

  /// Executes the text search.
  Future<void> _performSearch() async {
    final String searchText = _searchTextController.text;

    if (searchText.isEmpty) {
      // Clear previous search if the new search text is empty.
      setState(() {
        _searchResult.clear();
      });
      return;
    }

    // This is the core search function from the controller.
    _searchResult = _pdfController.searchText(
      searchText,
      // searchOption: TextSearchOption.caseSensitive, // Or .none for case-insensitive
    );

    _searchResult.addListener(_searchResultListener);

    // if (_searchResult.totalInstanceCount > 0) {
    //   _searchResult.nextInstance();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final pdfViewerProvider = Provider.of<PdfViewerProvider>(context);
    return Scaffold(
      appBar: _isSearchVisible
          ? SearchTextAppBar(
              toggleSearchUI: _toggleSearchUI,
              performSearch: _performSearch,
              searchTextController: _searchTextController,
              searchResult: _searchResult,
            ) as PreferredSizeWidget
          : AppBarWithTitle(
              fileName: pdfViewerProvider.fileName!,
              toggleSearchUI: _toggleSearchUI,
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
        controller: _pdfController,
        currentSearchTextHighlightColor: Colors.amber[700]!.withAlpha(200),
      ),
    );
  }
}

class AppBarWithTitle extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(35);

  final String fileName;
  final VoidCallback toggleSearchUI;
  const AppBarWithTitle(
      {super.key, required this.fileName, required this.toggleSearchUI});

  @override
  Widget build(BuildContext context) {
    final PdfViewerProvider pdfViewerProvider = Provider.of(context);

    Future<void> _sharePdf() async {
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

    return AppBar(
      title: FittedBox(child: Text(fileName)),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _sharePdf,
          tooltip: 'Compartilhar',
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: toggleSearchUI,
          tooltip: 'Pesquisar',
        ),
      ],
    );
  }
}

class SearchTextAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(35);

  final VoidCallback toggleSearchUI;
  final VoidCallback performSearch;
  final TextEditingController searchTextController;
  final PdfTextSearchResult searchResult;
  const SearchTextAppBar({
    super.key,
    required this.toggleSearchUI,
    required this.performSearch,
    required this.searchTextController,
    required this.searchResult,
  });

  @override
  State<SearchTextAppBar> createState() => _SearchTextAppBarState();
}

class _SearchTextAppBarState extends State<SearchTextAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      // An icon to close the search UI.
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: widget.toggleSearchUI,
      ),
      // The text field for search input.
      title: TextField(
        controller: widget.searchTextController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Pesquisar...',
          hintStyle: TextStyle(color: Colors.white60),
          border: InputBorder.none,
        ),
        // Perform search when the user submits.
        onSubmitted: (_) => widget.performSearch(),
      ),
      actions: [
        // Button to execute the search.
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: widget.performSearch,
          tooltip: 'Pesquisar',
        ),
        // Button to go to the previous match.
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () {
            // Check if there are matches before navigating.
            if (widget.searchResult.totalInstanceCount > 0) {
              widget.searchResult.previousInstance();
            }
          },
          tooltip: 'Anterior',
        ),
        // Button to go to the next match.
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () {
            if (widget.searchResult.totalInstanceCount > 0) {
              widget.searchResult.nextInstance();
            }
          },
          tooltip: 'Próximo',
        ),
      ],
    );
  }
}
