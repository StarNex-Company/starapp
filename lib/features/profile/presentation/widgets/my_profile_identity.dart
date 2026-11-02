import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';

/// "Identity": name with badges, handle · location, bio and talent chips.
class MyProfileIdentity extends StatelessWidget {
  const MyProfileIdentity({
    super.key,
    required this.name,
    required this.handle,
    required this.location,
    required this.bio,
    required this.talents,
    this.isFounder = false,
    this.isVerified = false,
  });

  final String name;

  /// Without the leading `@`.
  final String handle;
  final String location;
  final String bio;
  final List<String> talents;
  final bool isFounder;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 10, 32, 0),
      child: Column(
        spacing: 6,
        children: [
          _NameRow(name: name, isFounder: isFounder, isVerified: isVerified),
          Text(
            location.isEmpty ? '@$handle' : '@$handle  ·  $location',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: myProfileLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              color: MyProfileColors.textMuted,
            ),
          ),
          if (bio.isNotEmpty)
            Text(
              bio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 21 / 14,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
                color: MyProfileColors.textBody,
              ),
            ),
          if (talents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [for (final t in talents) _TalentChip(talent: t)],
              ),
            ),
        ],
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.name,
    required this.isFounder,
    required this.isVerified,
  });

  final String name;
  final bool isFounder;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: [
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              height: myProfileLeading,
              letterSpacing: -0.22,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        if (isFounder)
          Semantics(
            label: 'Co-founder',
            child: SvgPicture.asset(
              MyProfileIcons.founderBadge,
              width: 16.667,
              height: 15,
            ),
          ),
        if (isVerified)
          Semantics(
            label: 'Verified',
            child: SvgPicture.asset(
              MyProfileIcons.verifiedBadge,
              width: 20,
              height: 20,
            ),
          ),
      ],
    );
  }
}

/// Emoji shown before a talent on its chip.
const _talentEmoji = {
  'singing': '🎤',
  'production': '🎧',
  'songwriting': '✍️',
  'dance': '💃',
  'dancing': '💃',
  'acting': '🎭',
  'comedy': '😂',
  'rap': '🎙️',
  'music': '🎵',
  'instruments': '🎸',
  'modelling': '📸',
  'modeling': '📸',
  'photography': '📷',
  'art': '🎨',
  'fashion': '👗',
  'sports': '⚽',
  'poetry': '📝',
};

class _TalentChip extends StatelessWidget {
  const _TalentChip({required this.talent});

  final String talent;

  @override
  Widget build(BuildContext context) {
    final emoji = _talentEmoji[talent.toLowerCase()];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: const BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.all(Radius.circular(99)),
      ),
      child: Text(
        emoji == null ? talent : '$emoji $talent',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          height: myProfileLeading,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
          color: AppColors.brandBlue,
        ),
      ),
    );
  }
}
