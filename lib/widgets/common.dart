import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../theme.dart';
import 'star_pattern.dart';

/// Asks for a money amount; pops with the number, [clearValue] or null.
Future<double?> showAmountDialog(
  BuildContext context, {
  required String title,
  required String initial,
  required String currency,
  required String clearLabel,
  double? clearValue,
}) => showDialog<double>(
  context: context,
  builder: (_) => _AmountDialog(
    title: title,
    initial: initial,
    currency: currency,
    clearLabel: clearLabel,
    clearValue: clearValue,
  ),
);

class _AmountDialog extends StatefulWidget {
  const _AmountDialog({
    required this.title,
    required this.initial,
    required this.currency,
    required this.clearLabel,
    required this.clearValue,
  });

  final String title;
  final String initial;
  final String currency;
  final String clearLabel;
  final double? clearValue;

  @override
  State<_AmountDialog> createState() => _AmountDialogState();
}

class _AmountDialogState extends State<_AmountDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: InputDecoration(suffixText: widget.currency),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, widget.clearValue),
          child: Text(widget.clearLabel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, double.tryParse(_controller.text) ?? 0),
          child: Text(context.l.save),
        ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: color ?? Palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: color == Palette.card
              ? BorderSide(color: Palette.rule, width: .7)
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
            StarMark(size: 9, color: Palette.clay),
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
  const Caption(this.text, {super.key, this.color});

  final String text;
  final Color? color;

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
    child: CircularProgressIndicator(strokeWidth: 1.8, color: Palette.green),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  /// Error code or server message, see [L10nX.error].
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Fits full-page and tight cards (e.g. fasting error in 120px).
    return LayoutBuilder(
      builder: (context, c) {
        final tight = c.maxHeight.isFinite && c.maxHeight < 140;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tight ? 8 : 32,
            vertical: tight ? 0 : 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!tight) ...[
                Icon(Icons.cloud_off_rounded, size: 32, color: Palette.inkSoft),
                const SizedBox(height: 10),
              ],
              Text(
                context.error(error),
                textAlign: TextAlign.center,
                maxLines: tight ? 2 : null,
                overflow: tight ? TextOverflow.ellipsis : TextOverflow.visible,
                style: Fonts.body(tight ? 12.5 : 14, color: Palette.inkSoft),
              ),
              SizedBox(height: tight ? 6 : 12),
              FilledButton.tonal(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: Palette.greenSoft,
                  foregroundColor: Palette.green,
                  minimumSize: Size(tight ? 120 : 140, tight ? 36 : 44),
                  tapTargetSize: tight
                      ? MaterialTapTargetSize.shrinkWrap
                      : MaterialTapTargetSize.padded,
                  visualDensity: tight
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                ),
                child: Text(
                  context.l.retry,
                  style: Fonts.body(
                    tight ? 13 : 14,
                    color: Palette.green,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          StarMark(size: 40, color: Palette.rule, filled: false),
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
            Icon(Icons.arrow_forward_rounded, size: 18, color: Palette.green),
          ],
        ),
      ),
    );
  }
}
