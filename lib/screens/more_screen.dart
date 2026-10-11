import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/city_picker.dart';
import '../widgets/common.dart';
import '../widgets/features.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final settings = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(l.moreTitle)),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 32),
        children: [
          SectionHeader(l.allFeatures),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                for (final (i, f) in Feature.values.indexed) ...[
                  if (i > 0) const RowDivider(indent: 76),
                  FeatureRow(feature: f),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(l.settings),
          AppCard(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Label(icon: Icons.translate_rounded, text: l.language),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    for (final e in supportedLanguages.entries)
                      ButtonSegment(value: e.key, label: Text(e.value)),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (s) => cubit.setLanguage(s.first),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => showCityPicker(context),
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: Palette.green,
                  ),
                  title: Text(l.city, style: Fonts.body(15)),
                  subtitle: Text(
                    settings.city.name(context.isAr),
                    style: Fonts.body(13, color: Palette.inkSoft),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Palette.inkSoft,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 16),
                _Label(icon: Icons.wb_sunny_outlined, text: l.asrMethod),
                const SizedBox(height: 10),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: false, label: Text(l.asrStandard)),
                    ButtonSegment(value: true, label: Text(l.asrHanafi)),
                  ],
                  selected: {settings.hanafiAsr},
                  onSelectionChanged: (s) => cubit.setHanafiAsr(s.first),
                ),
                const SizedBox(height: 8),
                Text(l.asrHint, style: Fonts.body(12, color: Palette.inkSoft)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(l.about),
          AppCard(
            child: Text(
              l.aboutBody,
              style: Fonts.body(14, color: Palette.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Palette.green),
        const SizedBox(width: 14),
        Text(text, style: Fonts.body(15)),
      ],
    );
  }
}
