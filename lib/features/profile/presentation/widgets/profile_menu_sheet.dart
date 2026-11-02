import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';
import 'package:starapp/shared/widgets/log_out_sheet.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_share_sheet.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

enum _MenuAction { shortcuts, settings, share, logOut }

/// Opens Figma "Sheet — Profile Menu" ("Your profile") from the My Profile
/// header and carries out the chosen row once the sheet has closed:
/// Shortcuts and Settings open their pages, Share profile opens the share
/// sheet (for [shareLink], e.g. `starapp.io/@emmanuel`) and Log out asks
/// for confirmation, signs out and returns to the welcome screen.
Future<void> showProfileMenuSheet(
  BuildContext context,
  WidgetRef ref, {
  String? shareLink,
}) async {
  final action = await showStarSheet<_MenuAction>(
    context: context,
    builder: (_) => const ProfileMenuSheet(),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _MenuAction.shortcuts:
      context.push(AppRoutes.profileShortcuts);
    case _MenuAction.settings:
      context.push(AppRoutes.settings);
    case _MenuAction.share:
      if (shareLink == null) {
        showStarShareSheet(context);
      } else {
        showStarShareSheet(context, link: shareLink);
      }
    case _MenuAction.logOut:
      if (!await showLogOutSheet(context) || !context.mounted) return;
      try {
        await ref.read(currentUserProvider.notifier).signOut();
        if (context.mounted) context.go(AppRoutes.welcome);
      } catch (e) {
        if (context.mounted) showStarToast(context, describeError(e));
      }
  }
}

class ProfileMenuSheet extends StatelessWidget {
  const ProfileMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    void choose(_MenuAction action) => Navigator.of(context).pop(action);

    return StarSheet(
      title: 'Your profile',
      children: [
        _MenuRow(
          icon: MyProfileIcons.menuShortcuts,
          title: 'Shortcuts',
          subtitle: 'Insights, passport, wallet, saved, verification',
          onTap: () => choose(_MenuAction.shortcuts),
        ),
        _MenuRow(
          icon: MyProfileIcons.menuSettings,
          iconWidth: 20.5556,
          title: 'Settings',
          subtitle: 'Account, privacy and preferences',
          onTap: () => choose(_MenuAction.settings),
        ),
        _MenuRow(
          icon: MyProfileIcons.menuShare,
          title: 'Share profile',
          onTap: () => choose(_MenuAction.share),
        ),
        _MenuRow(
          icon: MyProfileIcons.menuLogOut,
          title: 'Log out',
          danger: true,
          onTap: () => choose(_MenuAction.logOut),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconWidth = 20,
    this.danger = false,
  });

  final String icon;
  final double iconWidth;
  final String title;
  final String? subtitle;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
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
                  color: danger ? AppColors.dangerTint : AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(icon, width: iconWidth, height: 20),
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
                      style: TextStyle(
                        fontSize: 15,
                        height: myProfileLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: danger ? AppColors.danger : AppColors.ink,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: myProfileLeading,
                          letterSpacing: 0,
                          color: AppColors.textSubtle,
                        ),
                      ),
                  ],
                ),
              ),
              SvgPicture.asset(
                danger
                    ? MyProfileIcons.menuChevronDanger
                    : MyProfileIcons.chevron,
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
