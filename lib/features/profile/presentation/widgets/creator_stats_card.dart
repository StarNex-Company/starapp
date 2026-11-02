import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_style.dart';

/// "Stats": Stars · Followers · Following · Wins on a tinted card. Followers
/// and Following open the creator's lists.
class CreatorStatsCard extends StatelessWidget {
  const CreatorStatsCard({
    super.key,
    required this.stars,
    required this.followers,
    required this.following,
    required this.wins,
    required this.onFollowers,
    required this.onFollowing,
  });

  final String stars;
  final String followers;
  final String following;
  final String wins;
  final VoidCallback onFollowers;
  final VoidCallback onFollowing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.brandTintSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderField),
        ),
        child: Row(
          children: [
            _Stat(value: stars, label: 'Stars'),
            _Stat(value: followers, label: 'Followers', onTap: onFollowers),
            _Stat(value: following, label: 'Following', onTap: onFollowing),
            _Stat(value: wins, label: 'Wins'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.onTap});

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      spacing: 2,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 18,
              height: creatorLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 12,
              height: creatorLeading,
              letterSpacing: 0,
              color: AppColors.textSubtle,
            ),
          ),
        ),
      ],
    );

    return Expanded(
      child: onTap == null
          ? Semantics(container: true, child: content)
          : Semantics(
              button: true,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: content,
              ),
            ),
    );
  }
}
