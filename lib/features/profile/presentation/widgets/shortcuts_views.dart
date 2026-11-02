import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';

enum ProfileShortcutKind { insights, passport, wallet, saved, verification }

/// A link on the Shortcuts page.
class ProfileShortcut {
  const ProfileShortcut({
    required this.kind,
    required this.title,
    required this.subtitle,
  });

  /// The page's links, in the design's order, with [summary]'s live figures
  /// ("₦1,240,500 available").
  static List<ProfileShortcut> all(ShortcutsSummary summary) {
    final saved = summary.savedCount;
    return [
      const ProfileShortcut(
        kind: ProfileShortcutKind.insights,
        title: 'Star Insights',
        subtitle: 'Where your Stars come from',
      ),
      const ProfileShortcut(
        kind: ProfileShortcutKind.passport,
        title: 'Talent Passport',
        subtitle: 'Your shareable portfolio',
      ),
      ProfileShortcut(
        kind: ProfileShortcutKind.wallet,
        title: 'Wallet',
        subtitle: '${summary.walletBalance.format()} available',
      ),
      ProfileShortcut(
        kind: ProfileShortcutKind.saved,
        title: 'Saved',
        subtitle: '${formatGrouped(saved)} saved video${saved == 1 ? '' : 's'}',
      ),
      ProfileShortcut(
        kind: ProfileShortcutKind.verification,
        title: 'Get verified',
        subtitle:
            '${summary.verificationStepsDone} of ${summary.verificationSteps} '
            'steps complete',
      ),
    ];
  }

  final ProfileShortcutKind kind;
  final String title;
  final String subtitle;
}

abstract final class ShortcutsIcons {
  static const _dir = 'assets/vectors/profile';

  static const list = '$_dir/shortcuts_ic_list.svg';
  static const grid = '$_dir/shortcuts_ic_grid.svg';

  static String of(ProfileShortcutKind kind) => switch (kind) {
    ProfileShortcutKind.insights => '$_dir/shortcuts_ic_star.svg',
    ProfileShortcutKind.passport => '$_dir/shortcuts_ic_idcard.svg',
    ProfileShortcutKind.wallet => '$_dir/shortcuts_ic_wallet.svg',
    ProfileShortcutKind.saved => '$_dir/shortcuts_ic_bookmark.svg',
    ProfileShortcutKind.verification => '$_dir/shortcuts_ic_shield_check.svg',
  };
}

const _titleStyle = TextStyle(
  fontSize: 14,
  height: myProfileLeading,
  letterSpacing: 0,
  fontWeight: FontWeight.w600,
  color: AppColors.ink,
);

const _subtitleStyle = TextStyle(
  fontSize: 12,
  height: myProfileLeading,
  letterSpacing: 0,
  color: AppColors.textSubtle,
);

/// "Shortcut Grid": two columns of tiles, 13px apart; tiles in a row share
/// the taller one's height.
class ShortcutsGrid extends StatelessWidget {
  const ShortcutsGrid({
    super.key,
    required this.shortcuts,
    required this.onOpen,
  });

  final List<ProfileShortcut> shortcuts;
  final ValueChanged<ProfileShortcut> onOpen;

  static const _gap = 13.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: _gap,
      children: [
        for (var i = 0; i < shortcuts.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: _gap,
              children: [
                for (final s in shortcuts.skip(i).take(2))
                  Expanded(
                    child: _ShortcutTile(
                      key: ValueKey(s.kind),
                      shortcut: s,
                      onTap: () => onOpen(s),
                    ),
                  ),
                if (i + 1 >= shortcuts.length) const Spacer(),
              ],
            ),
          ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({super.key, required this.shortcut, required this.onTap});

  final ProfileShortcut shortcut;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(20));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: _radius,
          boxShadow: [
            BoxShadow(
              color: Color(0x0F0A1A4A), // 0a1a4a @ 6%
              offset: Offset(0, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: _radius,
            side: BorderSide(color: MyProfileColors.borderTile),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              // 16px padding inside the 1px border; the design's 134px text
              // column runs 2px into the right padding.
              padding: const EdgeInsets.fromLTRB(17, 17, 15, 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  _IconTile(kind: shortcut.kind, size: 44),
                  Text(shortcut.title, style: _titleStyle),
                  Text(shortcut.subtitle, style: _subtitleStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// List mode: icon tile, title, subtitle and a chevron per row.
class ShortcutsList extends StatelessWidget {
  const ShortcutsList({
    super.key,
    required this.shortcuts,
    required this.onOpen,
  });

  final List<ProfileShortcut> shortcuts;
  final ValueChanged<ProfileShortcut> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        for (final s in shortcuts)
          _ShortcutRow(
            key: ValueKey(s.kind),
            shortcut: s,
            onTap: () => onOpen(s),
          ),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({super.key, required this.shortcut, required this.onTap});

  final ProfileShortcut shortcut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            spacing: 12,
            children: [
              _IconTile(kind: shortcut.kind, size: 36),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      shortcut.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _titleStyle,
                    ),
                    Text(
                      shortcut.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _subtitleStyle,
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                MyProfileIcons.chevronMuted,
                width: 18,
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.kind, required this.size});

  final ProfileShortcutKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(ShortcutsIcons.of(kind), width: 18, height: 18),
    );
  }
}
