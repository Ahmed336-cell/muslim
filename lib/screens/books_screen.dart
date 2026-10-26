import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/books.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'book_reader_screen.dart';

/// Free Arabic Islamic books — opens in-app reader.
class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
    settings: const RouteSettings(name: 'books'),
    builder: (_) => const BooksScreen(),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final ar = context.isAr;
    return Scaffold(
      appBar: AppBar(title: Text(l.featBooks)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              l.booksIntro,
              style: Fonts.body(13.5, color: Palette.inkSoft),
            ),
          ),
          for (final cat in BookCategory.values)
            if (booksIn(cat).isNotEmpty) ...[
              SectionHeader(_categoryLabel(l, cat)),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (final (i, book) in booksIn(cat).indexed) ...[
                      if (i > 0) const RowDivider(indent: 72),
                      ListTile(
                        onTap: () => Navigator.of(
                          context,
                        ).push(BookReaderScreen.route(book)),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EBE3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: Palette.green,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          book.title(ar),
                          style: Fonts.body(15.5, weight: FontWeight.w600),
                          textDirection: ar ? TextDirection.rtl : null,
                        ),
                        subtitle: Text(
                          book.author(ar),
                          style: Fonts.body(12.5, color: Palette.inkSoft),
                          textDirection: ar ? TextDirection.rtl : null,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Palette.greenSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l.booksFree,
                                style: Fonts.body(
                                  11,
                                  color: Palette.green,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              l.booksSource,
              style: Fonts.body(12, color: Palette.inkSoft),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(L10n l, BookCategory c) => switch (c) {
    BookCategory.aqidah => l.booksCatAqidah,
    BookCategory.tafsir => l.booksCatTafsir,
    BookCategory.hadith => l.booksCatHadith,
    BookCategory.seerah => l.booksCatSeerah,
    BookCategory.adhkar => l.booksCatAdhkar,
    BookCategory.fiqh => l.booksCatFiqh,
  };
}
