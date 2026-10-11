import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/duas/dua_of_day_cubit.dart';
import '../l10n/l10n.dart';
import '../screens/dua_screen.dart';
import '../screens/duas_screen.dart';
import '../theme.dart';
import 'common.dart';
import 'star_pattern.dart';

class DuaOfTheDay extends StatelessWidget {
  const DuaOfTheDay({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final dua = context.select((DuaOfDayCubit c) => c.state.dua);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (dua != null) ...[
              InkWell(
                onTap: () => Navigator.push(context, DuaScreen.route(dua)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const StarMark(size: 9, color: Palette.clay),
                          const SizedBox(width: 8),
                          Caption(l.duaOfDay),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        dua.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Fonts.display(19).copyWith(height: 1.3),
                      ),
                      if (dua.arabic.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          dua.arabic,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: Fonts.arabic(20, color: Palette.green),
                        ),
                      ],
                      if (dua.reference.isNotEmpty)
                        Text(
                          dua.reference,
                          style: Fonts.body(12, color: Palette.inkSoft),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(),
            ],
            CardLink(
              label: l.allDuas,
              onTap: () => Navigator.push(context, DuasScreen.route()),
            ),
          ],
        ),
      ),
    );
  }
}
