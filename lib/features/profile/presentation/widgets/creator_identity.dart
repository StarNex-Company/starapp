import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_style.dart';

/// "Info": name with badges, handle · location, bio and talent chips.
class CreatorIdentity extends StatelessWidget {
  const CreatorIdentity({super.key, required this.profile});

  final CreatorProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            spacing: 6,
            children: [
              Flexible(
                child: Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    height: creatorLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (profile.isCoFounder)
                Tooltip(
                  message: 'Star App co-founder',
                  child: SvgPicture.asset(
                    CreatorIcons.coFounder,
                    width: 15,
                    height: 13.5,
                  ),
                ),
              if (profile.isVerified)
                SvgPicture.asset(
                  CreatorIcons.verified,
                  width: 18,
                  height: 18,
                  semanticsLabel: 'Verified',
                ),
            ],
          ),
          Text(
            [
              '@${profile.handle}',
              if (profile.location.isNotEmpty) profile.location,
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: creatorLeading,
              letterSpacing: 0,
              color: AppColors.textSubtle,
            ),
          ),
          if (profile.bio.isNotEmpty)
            Text(
              profile.bio,
              style: const TextStyle(
                fontSize: 14,
                height: 21 / 14,
                letterSpacing: 0,
                color: AppColors.textBody,
              ),
            ),
          if (profile.talents.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final talent in profile.talents)
                  _TalentChip(label: talent),
              ],
            ),
        ],
      ),
    );
  }
}

class _TalentChip extends StatelessWidget {
  const _TalentChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.borderField),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          height: creatorLeading,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
          color: AppColors.textBody,
        ),
      ),
    );
  }
}
