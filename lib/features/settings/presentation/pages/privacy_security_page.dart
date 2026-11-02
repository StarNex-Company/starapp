import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/settings/data/models/settings.dart';
import 'package:starapp/features/settings/data/provider/settings_providers.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_tile_row.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_toggle.dart';
import 'package:starapp/features/settings/presentation/widgets/who_can_message_sheet.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Settings ▸ Privacy & Security (Figma `1535:2279`), inside the Profile tab.
/// Toggles and "Who can message me" save through `privacySettingsProvider`;
/// the rows that open their own screens come next and say "Coming soon" for
/// now.
class PrivacySecurityPage extends ConsumerWidget {
  const PrivacySecurityPage({super.key});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacy = ref.watch(privacySettingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Privacy & Security',
        leading: StarIconButton.back(onPressed: () => _back(context)),
      ),
      body: StarAsyncView(
        value: privacy,
        onRetry: () => ref.invalidate(privacySettingsProvider),
        builder: (settings) => _PrivacyList(settings: settings),
      ),
    );
  }
}

class _PrivacyList extends ConsumerWidget {
  const _PrivacyList({required this.settings});

  final PrivacySettings settings;

  /// Runs a save; if the server rejects it the setting has already rolled
  /// back, so only the reason needs showing.
  Future<void> _save(BuildContext context, Future<void> request) async {
    try {
      await request;
    } catch (error) {
      if (context.mounted) showStarToast(context, describeError(error));
    }
  }

  Future<void> _pickWhoCanMessage(BuildContext context, WidgetRef ref) async {
    final picked = await showWhoCanMessageSheet(
      context,
      current: settings.whoCanMessage,
    );
    if (picked == null || !context.mounted) return;
    await _save(
      context,
      ref.read(privacySettingsProvider.notifier).setWhoCanMessage(picked),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(privacySettingsProvider.notifier);
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    void comingSoon() => showStarToast(context, 'Coming soon');
    void save(Future<void> request) => _save(context, request);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const _SectionTitle('Privacy'),
          SettingsTileRow(
            icon: SettingsIcons.privacyLock,
            title: 'Private account',
            subtitle: 'Only approved followers see your posts',
            onTap: () =>
                save(notifier.setPrivateAccount(!settings.privateAccount)),
            trailing: SettingsToggle(
              value: settings.privateAccount,
              semanticLabel: 'Private account',
              onChanged: (value) => save(notifier.setPrivateAccount(value)),
            ),
          ),
          const SettingsTileDivider(),
          SettingsTileRow(
            icon: SettingsIcons.briefcase,
            title: 'Show me in Scout search',
            subtitle: 'Let verified companies discover you',
            onTap: () => save(
              notifier.setShowInScoutSearch(!settings.showInScoutSearch),
            ),
            trailing: SettingsToggle(
              value: settings.showInScoutSearch,
              semanticLabel: 'Show me in Scout search',
              onChanged: (value) => save(notifier.setShowInScoutSearch(value)),
            ),
          ),
          const SettingsTileDivider(),
          SettingsTileRow(
            icon: SettingsIcons.message,
            title: 'Who can message me',
            subtitle: 'Followers and verified companies',
            value: settings.whoCanMessage.shortLabel,
            onTap: () => _pickWhoCanMessage(context, ref),
          ),
          const SettingsTileDivider(),
          SettingsTileRow(
            icon: SettingsIcons.slash,
            title: 'Blocked accounts',
            subtitle: "Manage people you've blocked",
            value: '${settings.blockedAccounts}',
            onTap: comingSoon,
          ),
          const _SectionTitle('Security'),
          // The text opens 2FA setup (next phase); the switch flips it.
          SettingsTileRow(
            icon: SettingsIcons.shieldCheck,
            title: 'Two-factor authentication',
            subtitle: 'Extra protection at login',
            onTap: comingSoon,
            trailing: SettingsToggle(
              value: settings.twoFactorAuth,
              semanticLabel: 'Two-factor authentication',
              onChanged: (value) => save(notifier.setTwoFactorAuth(value)),
            ),
          ),
          const SettingsTileDivider(),
          SettingsTileRow(
            icon: SettingsIcons.privacyLock,
            title: 'Change password',
            subtitle: _passwordChanged(settings.passwordChangedAt),
            onTap: comingSoon,
          ),
          const SettingsTileDivider(),
          SettingsTileRow(
            icon: SettingsIcons.privacyGlobe,
            title: 'Active sessions',
            subtitle: "Where you're logged in",
            value: settings.activeSessions == 1
                ? '1 device'
                : '${settings.activeSessions} devices',
            onTap: comingSoon,
          ),
          const _SectionTitle('Data'),
          SettingsTileRow(
            icon: SettingsIcons.wifiOff,
            title: 'Lite Mode',
            subtitle: 'Save data on mobile networks',
            onTap: () => save(notifier.setLiteMode(!settings.liteMode)),
            trailing: SettingsToggle(
              value: settings.liteMode,
              semanticLabel: 'Lite Mode',
              onChanged: (value) => save(notifier.setLiteMode(value)),
            ),
          ),
          const SettingsTileDivider(),
          SettingsTileRow(
            icon: SettingsIcons.file,
            title: 'Download my data',
            subtitle: 'Get a copy of your Star App data',
            onTap: comingSoon,
          ),
          const SizedBox(height: 4),
          SettingsTileRow(
            icon: SettingsIcons.trash,
            title: 'Delete account',
            subtitle: 'Permanently remove your profile and content',
            danger: true,
            onTap: comingSoon,
          ),
        ],
      ),
    );
  }
}

/// "Last changed 2 months ago".
String _passwordChanged(DateTime? changedAt) {
  if (changedAt == null) return 'Never changed';
  final days = DateTime.now().difference(changedAt).inDays;
  String count(int n, String unit) => n == 1 ? '1 $unit' : '$n ${unit}s';
  final ago = switch (days) {
    < 1 => 'today',
    < 30 => '${count(days, 'day')} ago',
    < 365 => '${count(days ~/ 30, 'month')} ago',
    _ => '${count(days ~/ 365, 'year')} ago',
  };
  return 'Last changed $ago';
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          height: 1.21,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
          color: AppColors.brandBlue,
        ),
      ),
    );
  }
}
