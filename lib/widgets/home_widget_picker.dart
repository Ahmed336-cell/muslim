import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../l10n/l10n.dart';
import '../theme.dart';

/// Lists the home and lock screen widgets; on Android each can be pinned
/// straight from here.
class HomeWidgetPicker extends StatelessWidget {
  const HomeWidgetPicker({super.key});

  static bool get _canPin =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> _pin(BuildContext context, String kind) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l.widgetAddFailed;
    try {
      if (await HomeWidget.isRequestPinWidgetSupported() == true) {
        await HomeWidget.requestPinWidget(
          qualifiedAndroidName: 'com.example.muslim.widgets.$kind',
        );
        return;
      }
    } catch (_) {}
    messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final kinds = [
      ('PrayerWidget', Icons.schedule_rounded, l.nextPrayer, l.widgetPrayerSub),
      ('AyahWidget', Icons.menu_book_rounded, l.widgetVerse, l.widgetAyahSub),
      ('DuaWidget', Icons.front_hand_outlined, l.widgetDua, l.widgetDuaSub),
      (
        'NameWidget',
        Icons.auto_awesome_outlined,
        l.namesTitle,
        l.widgetNameSub,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (kind, icon, title, sub) in kinds)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: Palette.green),
            title: Text(title, style: Fonts.body(15)),
            subtitle: Text(sub, style: Fonts.body(13, color: Palette.inkSoft)),
            trailing: _canPin
                ? TextButton(
                    onPressed: () => _pin(context, kind),
                    child: Text(l.widgetAdd),
                  )
                : null,
          ),
        if (!_canPin)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              l.widgetIosHint,
              style: Fonts.body(13, color: Palette.inkSoft),
            ),
          ),
      ],
    );
  }
}
