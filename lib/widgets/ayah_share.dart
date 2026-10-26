import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data.dart';
import '../l10n/l10n.dart';
import '../services/quran.dart';
import '../theme.dart';
import 'mushaf_frame.dart';
import 'quran_text.dart';

/// Preview of [surah]:[ayah] as a framed image, with a share button.
Future<void> showAyahShare(
  BuildContext context, {
  required int surah,
  required int ayah,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _AyahShareSheet(surah: surah, ayah: ayah),
);

class _AyahShareSheet extends StatefulWidget {
  const _AyahShareSheet({required this.surah, required this.ayah});

  final int surah;
  final int ayah;

  @override
  State<_AyahShareSheet> createState() => _AyahShareSheetState();
}

class _AyahShareSheetState extends State<_AyahShareSheet> {
  final _key = GlobalKey();
  late final Future<(String, String?)> _content = _load();
  bool _translation = true;
  bool _busy = false;

  Future<(String, String?)> _load() async {
    final api = context.read<QuranApi>();
    final lang = context.lang;
    final ayah = await api.fetchAyah(widget.surah, widget.ayah, Mushaf.uthmani);
    String? meaning;
    if (lang != 'ar') {
      try {
        meaning = await api.fetchTafsir(
          TafsirSource.saheeh,
          widget.surah,
          widget.ayah,
        );
      } catch (_) {}
    }
    return (ayah.text, meaning);
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final boundary =
          _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ayah_${widget.surah}_${widget.ayah}.png');
      await file.writeAsBytes(png!.buffer.asUint8List());
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l.errGeneric)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return FutureBuilder(
      future: _content,
      builder: (context, snap) {
        final data = snap.data;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.shareAyah, style: Fonts.display(22)),
              const SizedBox(height: 14),
              if (data == null)
                SizedBox(
                  height: 260,
                  child: Center(
                    child: snap.hasError
                        ? Text(l.errGeneric)
                        : const CircularProgressIndicator(),
                  ),
                )
              else
                RepaintBoundary(
                  key: _key,
                  child: AyahImage(
                    surah: widget.surah,
                    ayah: widget.ayah,
                    text: data.$1,
                    meaning: _translation ? data.$2 : null,
                    footer: l.appName,
                  ),
                ),
              if (data?.$2 != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _translation,
                  activeThumbColor: Palette.cream,
                  activeTrackColor: Palette.green,
                  title: Text(l.includeTranslation, style: Fonts.body(15)),
                  onChanged: (v) => setState(() => _translation = v),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: data == null || _busy ? null : _share,
                icon: const Icon(Icons.ios_share_rounded),
                label: Text(l.shareImage),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The framed ayah that gets shared.
class AyahImage extends StatelessWidget {
  const AyahImage({
    super.key,
    required this.surah,
    required this.ayah,
    required this.text,
    this.meaning,
    required this.footer,
  });

  final int surah;
  final int ayah;
  final String text;
  final String? meaning;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final colors = MushafColors.watch(context);
    final s = surahs[surah - 1];
    return MediaQuery.withNoTextScaling(
      child: MushafFrame(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SurahCartouche(title: 'سورة ${s.arabic}', height: 40),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: text),
                    const TextSpan(text: '\u00A0'),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AyahMarker(
                        ayah,
                        size: 30,
                        color: colors.brass,
                        numberColor: colors.ink,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: Fonts.mushaf(25, color: colors.ink),
              ),
              if (meaning case final m? when m.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  m,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: Fonts.quote(15.5, color: colors.ink),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                context.isAr
                    ? '${s.arabic} · ${arabicDigits('$ayah')}'
                    : '${s.name} $surah:$ayah',
                textAlign: TextAlign.center,
                style: Fonts.body(12.5, color: colors.green),
              ),
              const SizedBox(height: 2),
              Text(
                footer,
                textAlign: TextAlign.center,
                style: Fonts.body(11, color: colors.ink.withValues(alpha: .62)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
