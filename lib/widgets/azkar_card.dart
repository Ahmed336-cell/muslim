import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/azkar_cubit.dart';
import '../bloc/clock_cubit.dart';
import '../bloc/hisn_cubit.dart';
import '../l10n/l10n.dart';
import '../screens/azkar_screen.dart';
import '../services/hisn.dart';
import '../theme.dart';
import 'azkar_reminder_settings.dart';
import 'common.dart';

/// Home card for whichever session fits the time of day.
class AzkarNowCard extends StatelessWidget {
  const AzkarNowCard({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = context.select((ClockCubit c) => c.state.hour);
    return AzkarSessionCard(session: AzkarSession.forHour(hour), wide: true);
  }
}

class AzkarSessionCard extends StatelessWidget {
  const AzkarSessionCard({super.key, required this.session, this.wide = false});

  final AzkarSession session;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final items = context.select(
      (HisnCubit c) => c.state.book?.session(session),
    );
    final azkar = context.watch<AzkarCubit>();
    final done = items == null ? 0 : azkar.doneIn(session, items);
    final total = items?.length ?? 0;
    final finished = total > 0 && done == total;
    final evening = session == AzkarSession.evening;
    final fg = evening ? Palette.cream : Palette.green;

    return AppCard(
      margin: wide
          ? const EdgeInsets.symmetric(horizontal: 16)
          : EdgeInsets.zero,
      color: evening ? Palette.green : Palette.greenSoft,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: () => Navigator.push(context, AzkarScreen.route(session)),
      child: Row(
        children: [
          Icon(
            azkarIcon(session),
            color: evening ? Palette.brass : fg,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wide
                      ? azkarTitle(l, session)
                      : evening
                      ? l.evening
                      : l.morning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Fonts.body(16, color: fg, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  finished
                      ? l.azkarAllDone
                      : total == 0
                      ? ''
                      : l.azkarProgress(context.n(done), context.n(total)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Fonts.body(12.5, color: fg.withValues(alpha: .75)),
                ),
                if (total > 0) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: done / total,
                      minHeight: 3,
                      color: evening ? Palette.brass : Palette.green,
                      backgroundColor: fg.withValues(alpha: .15),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (wide) ...[
            const SizedBox(width: 12),
            Icon(
              finished
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_rounded,
              color: evening ? Palette.brass : fg,
            ),
          ],
        ],
      ),
    );
  }
}
