import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../services/places.dart';
import '../theme.dart';

Future<void> showCityPicker(BuildContext context) async {
  final settings = context.read<SettingsCubit>();
  final current = settings.state.cityId;
  final ar = context.isAr;

  final picked = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .7,
      maxChildSize: .92,
      builder: (_, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(sheet.l.chooseCity, style: Fonts.display(22)),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: cities.length,
              itemBuilder: (_, i) {
                final c = cities[i];
                final selected = c.id == current;
                return ListTile(
                  onTap: () => Navigator.pop(sheet, c.id),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: Icon(
                    selected
                        ? Icons.location_on_rounded
                        : Icons.location_on_outlined,
                    color: selected ? Palette.green : Palette.inkSoft,
                  ),
                  title: Text(
                    c.name(ar),
                    style: Fonts.body(
                      16,
                      weight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_rounded, color: Palette.green)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
  if (picked != null && picked != current) settings.setCity(picked);
}

/// Tappable city name with a pin, for app bars and headers.
class CityChip extends StatelessWidget {
  const CityChip({super.key, this.color = Palette.ink});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final city = context.select((SettingsCubit c) => c.state.city);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => showCityPicker(context),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: .3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              city.name(context.isAr),
              style: Fonts.body(14, color: color, weight: FontWeight.w500),
            ),
            Icon(Icons.expand_more_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
