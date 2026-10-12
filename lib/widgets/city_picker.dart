import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/location_cubit.dart';
import '../bloc/settings_cubit.dart';
import '../l10n/l10n.dart';
import '../services/location.dart';
import '../services/places.dart';
import '../theme.dart';

/// "My location" or the chosen city's name.
String placeName(BuildContext context, Settings s) =>
    s.usesLocation ? context.l.myLocation : s.city.name(context.isAr);

Future<void> showCityPicker(BuildContext context) async {
  final settings = context.read<SettingsCubit>();
  final current = settings.state;
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
              itemCount: cities.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) return const _MyLocationTile();
                final c = cities[i - 1];
                final selected =
                    !current.usesLocation && c.id == current.cityId;
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
                      ? Icon(Icons.check_rounded, color: Palette.green)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
  if (picked != null && (current.usesLocation || picked != current.cityId)) {
    settings.setCity(picked);
  }
}

class _MyLocationTile extends StatelessWidget {
  const _MyLocationTile();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final settings = context.watch<SettingsCubit>().state;
    final locate = context.watch<LocationCubit>().state;
    final active = settings.usesLocation;

    final String subtitle;
    var subtitleColor = Palette.inkSoft;
    if (locate.locating) {
      subtitle = l.locating;
    } else if (locate.error != null) {
      subtitle = switch (locate.error) {
        LocationException.disabled => l.locDisabled,
        LocationException.denied => l.locDenied,
        LocationException.blocked => l.locBlocked,
        _ => l.locFailed,
      };
      subtitleColor = Palette.clay;
    } else if (active) {
      subtitle = l.nearCity(settings.city.name(context.isAr));
    } else {
      subtitle = l.useMyLocationSub;
    }

    return Column(
      children: [
        ListTile(
          onTap: locate.locating
              ? null
              : () async {
                  final cubit = context.read<LocationCubit>();
                  await cubit.locate();
                  if (context.mounted && cubit.state.error == null) {
                    Navigator.pop(context);
                  }
                },
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: locate.locating
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  active ? Icons.my_location_rounded : Icons.near_me_outlined,
                  color: Palette.green,
                ),
          title: Text(
            l.useMyLocation,
            style: Fonts.body(
              16,
              color: Palette.green,
              weight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: Fonts.body(12.5, color: subtitleColor),
          ),
          trailing: active && !locate.locating && locate.error == null
              ? Icon(Icons.check_rounded, color: Palette.green)
              : null,
        ),
        if (locate.error == LocationException.blocked ||
            locate.error == LocationException.disabled)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 64),
              child: TextButton(
                onPressed: context.read<LocationCubit>().openSettings,
                child: Text(l.openSettings),
              ),
            ),
          ),
        const Divider(indent: 20, endIndent: 20),
      ],
    );
  }
}

/// Tappable city name with a pin, for app bars and headers.
class CityChip extends StatelessWidget {
  const CityChip({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? Palette.ink;
    final settings = context.watch<SettingsCubit>().state;
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
            Icon(
              settings.usesLocation
                  ? Icons.my_location_rounded
                  : Icons.location_on_outlined,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              placeName(context, settings),
              style: Fonts.body(14, color: color, weight: FontWeight.w500),
            ),
            Icon(Icons.expand_more_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
