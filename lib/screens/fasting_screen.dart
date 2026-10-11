import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/fasting/fasting_bloc.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/city_picker.dart';
import '../widgets/fasting_section.dart';

class FastingScreen extends StatelessWidget {
  const FastingScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const FastingScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.fastingTitle),
        actions: const [CityChip(), SizedBox(width: 12)],
      ),
      body: RefreshIndicator(
        color: Palette.green,
        backgroundColor: Palette.card,
        onRefresh: () {
          final bloc = context.read<FastingBloc>()
            ..add(const FastingRequested());
          return bloc.stream.firstWhere((s) => !s.isBusy);
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 28),
          children: const [FastingSection()],
        ),
      ),
    );
  }
}
