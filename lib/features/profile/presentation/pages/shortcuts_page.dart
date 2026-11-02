import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/profile/data/provider/my_profile_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';
import 'package:starapp/features/profile/presentation/widgets/shortcuts_views.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// Profile tab page with quick links (Figma "Profile — Shortcuts" and
/// "Profile — Shortcuts (List)"). The header action switches between the
/// tile grid and the list.
class ShortcutsPage extends ConsumerStatefulWidget {
  const ShortcutsPage({super.key});

  @override
  ConsumerState<ShortcutsPage> createState() => _ShortcutsPageState();
}

class _ShortcutsPageState extends ConsumerState<ShortcutsPage> {
  bool _list = false;

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  void _open(ProfileShortcut shortcut) => context.push(switch (shortcut.kind) {
    ProfileShortcutKind.insights => AppRoutes.profileInsights,
    ProfileShortcutKind.passport => AppRoutes.profilePassport,
    ProfileShortcutKind.wallet => AppRoutes.wallet,
    ProfileShortcutKind.saved => AppRoutes.profileSaved,
    ProfileShortcutKind.verification => AppRoutes.verification,
  });

  @override
  Widget build(BuildContext context) {
    final shortcuts = ref
        .watch(shortcutsSummaryProvider)
        .whenData(ProfileShortcut.all);
    final bottom = MediaQuery.paddingOf(context).bottom + 32;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Shortcuts',
        leading: StarIconButton.back(onPressed: _back),
        trailing: StarIconButton(
          icon: _list ? ShortcutsIcons.grid : ShortcutsIcons.list,
          iconSize: 20,
          tooltip: _list ? 'Grid view' : 'List view',
          onPressed: () => setState(() => _list = !_list),
        ),
      ),
      body: StarAsyncView(
        value: shortcuts,
        onRetry: () => ref.invalidate(shortcutsSummaryProvider),
        builder: (items) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              const Text(
                'Quick links to everything about your growth on Star App.',
                style: TextStyle(
                  fontSize: 14,
                  height: myProfileLeading,
                  letterSpacing: 0,
                  color: MyProfileColors.textIntro,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                child: _list
                    ? ShortcutsList(
                        key: const ValueKey('list'),
                        shortcuts: items,
                        onOpen: _open,
                      )
                    : ShortcutsGrid(
                        key: const ValueKey('grid'),
                        shortcuts: items,
                        onOpen: _open,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
