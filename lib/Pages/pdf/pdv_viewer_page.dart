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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);

    super.initState();

    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _searchTextController.dispose();
    _pdfController.dispose();

    _searchResult.removeListener(_searchResultListener);
    super.dispose();
  }

  void _toggleSearchUI() {
    setState(() {
      if (_isSearchVisible) {
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

  Future<void> _performSearch() async {
    final String searchText = _searchTextController.text;

    if (searchText.isEmpty) {
      setState(() {
        _searchResult.clear();
      });
      return;
    }

    _searchResult = _pdfController.searchText(
      searchText,
    );

    _searchResult.addListener(_searchResultListener);
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
    final theme = Theme.of(context);

    Future<void> _sharePdf() async {
      try {
        final pdfFile = XFile.fromData(
          pdfViewerProvider.pdfBytes!,
          name: pdfViewerProvider.fileName!,
          mimeType: 'application/pdf',
        );

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
      leading: IconButton(
        icon: Icon(theme.platform == TargetPlatform.iOS
            ? Icons.arrow_back_ios
            : Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(true),
      ),
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
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: widget.toggleSearchUI,
      ),
      title: TextField(
        controller: widget.searchTextController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Pesquisar...',
          hintStyle: TextStyle(color: Colors.white60),
          border: InputBorder.none,
        ),
        onSubmitted: (_) => widget.performSearch(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: widget.performSearch,
          tooltip: 'Pesquisar',
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () {
            if (widget.searchResult.totalInstanceCount > 0) {
              widget.searchResult.previousInstance();
            }
          },
          tooltip: 'Anterior',
        ),
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
