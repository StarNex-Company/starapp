import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// "LIVE · Updates in real time" strip with a tappable freshness label on
/// the right ("Just now", "12s ago").
class BoardLiveStatus extends StatelessWidget {
  const BoardLiveStatus({
    super.key,
    required this.updatedLabel,
    required this.onRefresh,
  });

  final String updatedLabel;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        const _LivePill(),
        const Expanded(
          child: Text(
            'Updates in real time',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              height: 1.21,
              letterSpacing: 0,
              fontSize: 12,
              color: AppColors.textSubtle,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Refresh, updated $updatedLabel',
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRefresh,
            child: Padding(
              // Taller hit area without moving the label.
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.centerRight,
                  children: [...previous, ?current],
                ),
                child: Text(
                  updatedLabel,
                  key: ValueKey(updatedLabel),
                  style: const TextStyle(
                    height: 1.21,
                    letterSpacing: 0,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LivePill extends StatefulWidget {
  const _LivePill();

  @override
  State<_LivePill> createState() => _LivePillState();
}

class _LivePillState extends State<_LivePill>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.35,
    value: 1,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.all(Radius.circular(11)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          // Breathes between full and 35% opacity while the board is live.
          FadeTransition(
            opacity: _pulse,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: 6),
            ),
          ),
          const Text(
            'LIVE',
            style: TextStyle(
              height: 1.21,
              letterSpacing: 0.44,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
