import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme.dart';
import 'star_pattern.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.color = Palette.card,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: color == Palette.card
              ? const BorderSide(color: Palette.rule, width: .7)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 8, 8),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            const StarMark(size: 9, color: Palette.clay),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: Fonts.display(20))),
            if (action != null)
              TextButton(
                onPressed: onAction,
                child: Text(
                  action!,
                  style: Fonts.body(
                    14,
                    color: Palette.clay,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small uppercase caption used inside cards.
class Caption extends StatelessWidget {
  const Caption(this.text, {super.key, this.color = Palette.inkSoft});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      Fonts.arabicUi ? text : text.toUpperCase(),
      style: Fonts.label(color: color),
    );
  }
}

class Spinner extends StatelessWidget {
  const Spinner({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: const CircularProgressIndicator(
      strokeWidth: 1.8,
      color: Palette.green,
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  /// Error code or server message, see [L10nX.error].
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 32, color: Palette.inkSoft),
          const SizedBox(height: 10),
          Text(
            context.error(error),
            textAlign: TextAlign.center,
            style: Fonts.body(14, color: Palette.inkSoft),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: Palette.greenSoft,
              foregroundColor: Palette.green,
              minimumSize: const Size(140, 44),
            ),
            child: Text(
              context.l.retry,
              style: Fonts.body(
                14,
                color: Palette.green,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Numbered star badge used in lists (surahs, names).
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.number, {super.key});

  final int number;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const StarMark(size: 40, color: Palette.rule, filled: false),
          Text(
            context.n(number),
            style: Fonts.mono(12, color: Palette.inkSoft),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.enabled = true,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      onChanged: onChanged,
      style: Fonts.body(15),
      cursorColor: Palette.clay,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 22),
      ),
    );
  }
}

/// Divider between list rows, inset to line up with the text.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key, this.indent = 20});

  final double indent;

  @override
  Widget build(BuildContext context) =>
      Divider(indent: indent, endIndent: indent);
}

/// Footer link at the bottom of a card.
class CardLink extends StatelessWidget {
  const CardLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Fonts.body(
                  14,
                  color: Palette.green,
                  weight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Palette.green,
            ),
          ],
        ),
      ),
    );
  }
}
