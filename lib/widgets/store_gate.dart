import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/play_update.dart';
import '../services/store_review.dart';
import '../theme.dart';

/// Blocks the app when Play has a required update.
class StoreGate extends StatefulWidget {
  const StoreGate({super.key, required this.child});

  final Widget child;

  @override
  State<StoreGate> createState() => _StoreGateState();
}

class _StoreGateState extends State<StoreGate> {
  var _blocked = false;
  var _updating = false;

  @override
  void initState() {
    super.initState();
    _enforce();
  }

  Future<void> _enforce() async {
    if (!await isUpdateRequired()) return;
    final started = await startImmediateUpdate();
    if (!mounted || started) return;
    setState(() => _blocked = true);
  }

  Future<void> _update() async {
    setState(() => _updating = true);
    final started = await startImmediateUpdate();
    if (!mounted) return;
    if (!started) await openPlayListing();
    if (mounted) setState(() => _updating = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_blocked) return widget.child;
    final l = context.l;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.system_update_rounded, size: 48, color: Palette.green),
              const SizedBox(height: 18),
              Text(
                l.forceUpdateTitle,
                style: Fonts.display(28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l.forceUpdateBody,
                style: Fonts.body(15, color: Palette.inkSoft),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _updating ? null : _update,
                child: Text(l.forceUpdateAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks for a Play review after a few sessions. Does not show UI of its own.
class ReviewPrompt extends StatefulWidget {
  const ReviewPrompt({super.key, required this.child});

  final Widget child;

  @override
  State<ReviewPrompt> createState() => _ReviewPromptState();
}

class _ReviewPromptState extends State<ReviewPrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StoreReview.maybeAsk();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
