import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/session/data/models/current_user.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/features/settings/data/provider/settings_providers.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_row.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_toggle.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_user_card.dart';
import 'package:starapp/shared/widgets/log_out_sheet.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _logoutTint = Color(0xFFFFC8C9); // surface/tint/ffc8c9

typedef _SettingsData = (CurrentUser, AppPreferences, PrivacySettings);

/// Settings inside the Profile tab (Figma "Settings" `1331:1487`): the user
/// card, Account / Preferences / Your Experience lists, and Log out.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  void _comingSoon(BuildContext context) =>
      showStarToast(context, 'Coming soon');

  Future<void> _logOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showLogOutSheet(context);
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(currentUserProvider.notifier).signOut();
    } catch (_) {
      // The local session is gone either way; the server's expires on its
      // own.
    }
    if (context.mounted) context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = _combine(
      ref.watch(currentUserProvider),
      ref.watch(preferencesProvider),
      ref.watch(privacySettingsProvider),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Settings',
        leading: StarIconButton.back(onPressed: () => _back(context)),
        trailing: _MoreButton(onPressed: () => _comingSoon(context)),
      ),
      body: StarAsyncView(
        value: data,
        onRetry: () {
          ref.invalidate(currentUserProvider);
          ref.invalidate(preferencesProvider);
          ref.invalidate(privacySettingsProvider);
        },
        builder: (data) {
          final (user, preferences, privacy) = data;
          return _SettingsList(
            user: user,
            preferences: preferences,
            privacy: privacy,
            onComingSoon: () => _comingSoon(context),
            onLogOut: () => _logOut(context, ref),
          );
        },
      ),
    );
  }
}

AsyncValue<_SettingsData> _combine(
  AsyncValue<CurrentUser> user,
  AsyncValue<AppPreferences> preferences,
  AsyncValue<PrivacySettings> privacy,
) {
  if (user.hasValue && preferences.hasValue && privacy.hasValue) {
    return AsyncData((
      user.requireValue,
      preferences.requireValue,
      privacy.requireValue,
    ));
  }
  for (final value in [user, preferences, privacy]) {
    if (value.hasError) {
      return AsyncError(value.error!, value.stackTrace ?? StackTrace.empty);
    }
  }
  return const AsyncLoading();
}

class _SettingsList extends ConsumerWidget {
  const _SettingsList({
    required this.user,
    required this.preferences,
    required this.privacy,
    required this.onComingSoon,
    required this.onLogOut,
  });

  final CurrentUser user;
  final AppPreferences preferences;
  final PrivacySettings privacy;
  final VoidCallback onComingSoon;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    final preferencesNotifier = ref.read(preferencesProvider.notifier);
    final privacyNotifier = ref.read(privacySettingsProvider.notifier);

    // A rejected change has already rolled back; say why.
    Future<void> save(Future<void> request) async {
      try {
        await request;
      } catch (error) {
        if (context.mounted) showStarToast(context, describeError(error));
      }
    }

    void toggleAutoplay() => save(
      preferencesNotifier.setAutoplayVideos(!preferences.autoplayVideos),
    );
    void togglePrivate() =>
        save(privacyNotifier.setPrivateAccount(!privacy.privateAccount));

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          SettingsUserCard(
            user: user,
            onTap: () => context.go(AppRoutes.profile),
          ),
          _Section(
            title: 'Account',
            rows: [
              SettingsRow(
                icon: SettingsIcons.user,
                title: 'Edit profile',
                subtitle: 'Your story, our way',
                onTap: () => context.push(AppRoutes.editProfile),
              ),
              SettingsRow(
                icon: SettingsIcons.lock,
                title: 'Privacy & Security',
                subtitle: 'Control who see your talent',
                onTap: () => context.push(AppRoutes.settingsPrivacy),
              ),
              SettingsRow(
                icon: SettingsIcons.circleCheck,
                title: 'Verification',
                subtitle: 'Build trust in your profile',
                onTap: () => context.push(AppRoutes.verification),
              ),
              SettingsRow(
                icon: SettingsIcons.idCard,
                title: 'Account details',
                subtitle: 'Name, email and password',
                onTap: onComingSoon,
              ),
              SettingsRow(
                icon: SettingsIcons.wallet,
                title: 'Payments & payouts',
                subtitle: 'Payout methods and currency',
                onTap: () => context.push(AppRoutes.payouts),
              ),
            ],
          ),
          _Section(
            title: 'Preferences',
            rows: [
              SettingsRow(
                icon: SettingsIcons.bell,
                title: 'Notifications',
                subtitle: 'Stay in the loop',
                onTap: onComingSoon,
              ),
              // Dark mode isn't built yet: it stays off.
              SettingsRow(
                icon: SettingsIcons.light,
                title: 'Dark mode',
                subtitle: 'Switch up your view',
                onTap: onComingSoon,
                trailing: SettingsToggle(
                  value: preferences.darkMode,
                  semanticLabel: 'Dark mode',
                  onChanged: (_) => onComingSoon(),
                ),
              ),
              SettingsRow(
                icon: SettingsIcons.autoplay,
                title: 'Autoplay videos',
                subtitle: 'Play videos as you scroll',
                onTap: toggleAutoplay,
                trailing: SettingsToggle(
                  value: preferences.autoplayVideos,
                  offKnobColor: AppColors.iconButtonBg,
                  semanticLabel: 'Autoplay videos',
                  onChanged: (_) => toggleAutoplay(),
                ),
              ),
              SettingsRow(
                icon: SettingsIcons.globe,
                title: 'Language',
                subtitle: _languageName(preferences.language),
                onTap: () => context.push(AppRoutes.language),
              ),
            ],
          ),
          _Section(
            title: 'Your Experience',
            rows: [
              SettingsRow(
                icon: SettingsIcons.eye,
                title: 'Private profile',
                subtitle: 'Choose who follows you',
                onTap: togglePrivate,
                trailing: SettingsToggle(
                  value: privacy.privateAccount,
                  offKnobColor: AppColors.iconButtonBg,
                  semanticLabel: 'Private profile',
                  onChanged: (_) => togglePrivate(),
                ),
              ),
              SettingsRow(
                icon: SettingsIcons.preferences,
                title: 'Content preferences',
                subtitle: 'See more of what you love',
                onTap: onComingSoon,
              ),
              SettingsRow(
                icon: SettingsIcons.info,
                title: 'Help & support',
                subtitle: 'FAQs, contact and policies',
                onTap: onComingSoon,
              ),
            ],
          ),
          _LogOutButton(onPressed: onLogOut),
          const _Footer(),
        ],
      ),
    );
  }
}

/// Display name of a BCP 47 language tag; unknown tags show as they are.
String _languageName(String tag) => switch (tag) {
  'en-GB' => 'English (UK)',
  'en-US' => 'English (USA)',
  'es' || 'es-ES' => 'Español',
  _ => tag,
};

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [SettingsSectionTitle(title), ...rows],
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Material(
        color: _logoutTint,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: const Center(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                height: 1.21,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: AppColors.authError, // red/b10003
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Made for every kind of star." sign-off under the list.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 7,
        children: [
          SvgPicture.asset(SettingsIcons.logo, width: 15, height: 13),
          const Flexible(
            child: Text(
              'Made for every kind of star.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.21,
                letterSpacing: 0,
                color: AppColors.voidBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header "…" button. Like `StarIconButton`, but draws the wide meatball icon
/// at its own size (a square icon box would stretch it).
class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'More',
      child: Material(
        color: AppColors.iconButtonBg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: StarIconButton.size,
            child: Center(child: SvgPicture.asset(SettingsIcons.more)),
          ),
        ),
      ),
    );
  }
}
