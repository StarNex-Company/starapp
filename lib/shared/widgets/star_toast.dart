import 'dart:async';

import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

OverlayEntry? _current;

/// Shows the design's dark pill toast ("Link copied to clipboard") above the
/// bottom navigation, replacing any toast already on screen. It fades out
/// after [duration].
///
/// [badge] defaults to the green check; pass any 22px-high widget (an icon in
/// a coloured circle) for other toasts.
void showStarToast(
  BuildContext context,
  String message, {
  Widget? badge,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _current?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ToastHost(
      message: message,
      badge: badge ?? const StarToastBadge(),
      duration: duration,
      onDone: () {
        if (_current != entry) return;
        entry.remove();
        _current = null;
      },
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

/// Round badge at the start of a toast: a glyph on a coloured circle.
class StarToastBadge extends StatelessWidget {
  const StarToastBadge({
    super.key,
    this.glyph = '✓',
    this.color = AppColors.success,
    this.child,
  });

  final String glyph;
  final Color color;

  /// Replaces [glyph], e.g. a 14px icon.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      constraints: const BoxConstraints(minWidth: 22),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
      child: child ??
          Text(
            glyph,
            style: const TextStyle(
              fontSize: 13,
              height: 14 / 13,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
    );
  }
}

class _ToastHost extends StatefulWidget {
  const _ToastHost({
    required this.message,
    required this.badge,
    required this.duration,
    required this.onDone,
  });

  final String message;
  final Widget badge;
  final Duration duration;
  final VoidCallback onDone;

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost> with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))
      ..forward();
    _timer = Timer(widget.duration, () async {
      if (!mounted) return;
      await _fade.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The design sits the toast 120px above the bottom of a 34px-inset phone.
    final bottom = MediaQuery.viewPaddingOf(context).bottom + 86;
    final curve = CurvedAnimation(parent: _fade, curve: Curves.easeOut);

    return Positioned(
      left: 24,
      right: 24,
      bottom: bottom,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(curve),
            child: Center(
              child: Semantics(
                liveRegion: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: const [
                        BoxShadow(color: Color(0x40000000), offset: Offset(0, 8), blurRadius: 24),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        widget.badge,
                        Flexible(
                          child: Text(
                            widget.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 20 / 14,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
