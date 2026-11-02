import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/challenges/data/models/challenge.dart';

// Inter's "normal" line height, so text boxes match the design.
const _leading = 1.21;

abstract final class ChallengeListIcons {
  static const _dir = 'assets/vectors/challenges';

  static const music = '$_dir/rules_ic_music.svg';
  static const clock = 'assets/vectors/moderation/appeal_ic_clock.svg';
  static const calendar = '$_dir/rules_ic_calendar.svg';
  static const shieldCheck = '$_dir/rules_ic_shield_check.svg';
  static const trophy = '$_dir/rules_ic_trophy.svg';
  static const zap = '$_dir/upcoming_ic_zap.svg';
  static const smile = '$_dir/upcoming_ic_smile.svg';
  static const image = '$_dir/upcoming_ic_image.svg';
  static const star = '$_dir/entries_ic_star.svg';
  static const chevron = '$_dir/rules_ic_chevron.svg';

  static String of(ChallengeIcon icon) => switch (icon) {
    ChallengeIcon.music => music,
    ChallengeIcon.clock => clock,
    ChallengeIcon.calendar => calendar,
    ChallengeIcon.shieldCheck => shieldCheck,
    ChallengeIcon.trophy => trophy,
    ChallengeIcon.zap => zap,
    ChallengeIcon.smile => smile,
    ChallengeIcon.image => image,
    ChallengeIcon.star => star,
  };

  /// The glyph for a challenge's arena.
  static String ofArena(ChallengeArena arena) => switch (arena) {
    ChallengeArena.music => music,
    ChallengeArena.dance => zap,
    ChallengeArena.comedy => smile,
    ChallengeArena.visualArts || ChallengeArena.photography => image,
    ChallengeArena.acting || ChallengeArena.other => star,
  };
}

/// Tappable row with a tinted icon tile, title, subtitle, an optional grey
/// [value] and a chevron (rules sheet, upcoming challenges, my entries).
class ChallengeListTile extends StatelessWidget {
  const ChallengeListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.value,
  });

  /// SVG asset path, drawn at 20px.
  final String icon;
  final String title;
  final String subtitle;

  /// Short status before the chevron, e.g. "Remind me", "Live".
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(icon, width: 20, height: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: _leading,
                        letterSpacing: 0,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: _leading,
                        letterSpacing: 0,
                        fontSize: 12,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  if (value != null)
                    Text(
                      value!,
                      style: const TextStyle(
                        height: _leading,
                        letterSpacing: 0,
                        fontSize: 13,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  SvgPicture.asset(
                    ChallengeListIcons.chevron,
                    width: 18,
                    height: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navy list heading above a group of [ChallengeListTile]s ("Live", "Past").
class ChallengeListSectionTitle extends StatelessWidget {
  const ChallengeListSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        height: _leading,
        letterSpacing: 0,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.brandBlue,
      ),
    );
  }
}
