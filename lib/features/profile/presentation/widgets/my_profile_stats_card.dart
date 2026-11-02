import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';

class MyProfileStat {
  const MyProfileStat({required this.label, required this.value, this.onTap});

  final String label;
  final int value;

  /// Null for a stat that isn't a link (Posts).
  final VoidCallback? onTap;
}

/// "Stats": Stars / Followers / Following / Posts on a white card with
/// hairline dividers.
class MyProfileStatsCard extends StatelessWidget {
  const MyProfileStatsCard({super.key, required this.stats});

  final List<MyProfileStat> stats;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _radius,
        border: Border.all(color: MyProfileColors.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140A1A4A), // 0a1a4a @ 8%
            offset: Offset(0, 8),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: _radius,
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0)
                  const Center(
                    child: SizedBox(
                      width: 1,
                      height: 34,
                      child: ColoredBox(color: MyProfileColors.borderSoft),
                    ),
                  ),
                Expanded(child: _StatCell(stat: stats[i])),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat});

  final MyProfileStat stat;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 2,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatGrouped(stat.value),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 19,
                height: myProfileLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: myProfileLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              color: MyProfileColors.textMuted,
            ),
          ),
        ],
      ),
    );

    final onTap = stat.onTap;
    return Semantics(
      button: onTap != null,
      label: '${formatGrouped(stat.value)} ${stat.label}',
      excludeSemantics: true,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
