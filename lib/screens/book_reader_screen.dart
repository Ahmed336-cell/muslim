import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../l10n/l10n.dart';
import '../services/books.dart';
import '../services/links.dart';
import '../theme.dart';

/// In-app reader for a free Arabic Islamic book (IslamHouse page / PDF).
class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({super.key, required this.book});

  final IslamicBook book;

  static Route<void> route(IslamicBook book) =>
      MaterialPageRoute(builder: (_) => BookReaderScreen(book: book));

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p);
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _error = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          onWebResourceError: (e) {
            if (mounted) {
              setState(() {
                _loading = false;
                _error = e.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.book.url));
  }

  Future<void> _reload() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    await _controller.loadRequest(Uri.parse(widget.book.url));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    final title = widget.book.title(ar);
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: l.booksOpenExternal,
            icon: const Icon(Icons.open_in_browser_rounded),
            onPressed: () => openExternalUrl(widget.book.url),
          ),
          IconButton(
            tooltip: l.retry,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loading)
            LinearProgressIndicator(
              value: _progress > 0 && _progress < 100 ? _progress / 100 : null,
              minHeight: 2,
              color: Palette.green,
              backgroundColor: Palette.greenSoft,
            ),
          Expanded(
            child: _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 40,
                            color: Palette.inkSoft,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l.booksOpenFail,
                            textAlign: TextAlign.center,
                            style: Fonts.body(14, color: Palette.inkSoft),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _reload,
                            child: Text(l.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                : WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
