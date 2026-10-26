import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../theme.dart';
import 'mushaf_frame.dart';

/// Preview a framed card and share it as a PNG (same flow as ayah share).
Future<void> showShareCard(
  BuildContext context, {
  required String sheetTitle,
  required String eyebrow,
  required String arabic,
  String? subtitle,
  String? meaning,
  String? description,
  String? citation,
  bool allowHideMeaning = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ShareCardSheet(
      sheetTitle: sheetTitle,
      eyebrow: eyebrow,
      arabic: arabic,
      subtitle: subtitle,
      meaning: meaning,
      description: description,
      citation: citation,
      allowHideMeaning: allowHideMeaning,
    ),
  );
}

class _ShareCardSheet extends StatefulWidget {
  const _ShareCardSheet({
    required this.sheetTitle,
    required this.eyebrow,
    required this.arabic,
    this.subtitle,
    this.meaning,
    this.description,
    this.citation,
    this.allowHideMeaning = false,
  });

  final String sheetTitle;
  final String eyebrow;
  final String arabic;
  final String? subtitle;
  final String? meaning;
  final String? description;
  final String? citation;
  final bool allowHideMeaning;

  @override
  State<_ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<_ShareCardSheet> {
  final _key = GlobalKey();
  var _includeMeaning = true;
  var _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final boundary =
          _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
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
    final meaning = _includeMeaning ? widget.meaning : null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.sheetTitle, style: Fonts.display(22)),
          const SizedBox(height: 14),
          RepaintBoundary(
            key: _key,
            child: ShareCardImage(
              eyebrow: widget.eyebrow,
              arabic: widget.arabic,
              subtitle: widget.subtitle,
              meaning: meaning,
              description: widget.description,
              citation: widget.citation,
              footer: l.appName,
            ),
          ),
          if (widget.allowHideMeaning &&
              widget.meaning != null &&
              widget.meaning!.isNotEmpty)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _includeMeaning,
              activeThumbColor: Palette.cream,
              activeTrackColor: Palette.green,
              title: Text(l.includeTranslation, style: Fonts.body(15)),
              onChanged: (v) => setState(() => _includeMeaning = v),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _share,
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(l.shareImage),
          ),
        ],
      ),
    );
  }
}

/// Framed card rendered into the shared PNG.
class ShareCardImage extends StatelessWidget {
  const ShareCardImage({
    super.key,
    required this.eyebrow,
    required this.arabic,
    this.subtitle,
    this.meaning,
    this.description,
    this.citation,
    required this.footer,
  });

  final String eyebrow;
  final String arabic;
  final String? subtitle;
  final String? meaning;
  final String? description;
  final String? citation;
  final String footer;

  @override
  Widget build(BuildContext context) {
    final colors = MushafColors.watch(context);
    return MediaQuery.withNoTextScaling(
      child: MushafFrame(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                eyebrow,
                textAlign: TextAlign.center,
                style: Fonts.body(
                  12.5,
                  color: colors.green,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              if (arabic.isNotEmpty)
                Text(
                  arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: Fonts.arabic(28, color: colors.ink).copyWith(
                    height: 1.7,
                  ),
                ),
              if (subtitle case final s? when s.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  s,
                  textAlign: TextAlign.center,
                  style: Fonts.display(18, color: colors.green),
                ),
              ],
              if (meaning case final m? when m.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  m,
                  textAlign: TextAlign.center,
                  style: Fonts.quote(15.5, color: colors.ink),
                ),
              ],
              if (description case final d? when d.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  d,
                  textAlign: TextAlign.center,
                  style: Fonts.body(14, color: colors.ink).copyWith(
                    height: 1.55,
                  ),
                ),
              ],
              if (citation case final c? when c.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  c,
                  textAlign: TextAlign.center,
                  style: Fonts.body(12.5, color: colors.green),
                ),
              ],
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
