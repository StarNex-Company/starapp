import 'package:flutter/material.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_scaffold.dart';

/// Legacy `Scaffold.appBar` wrapper around [AuthHeaderBar] (logo + language
/// chip, styled to the Figma header). New screens should use `AuthScaffold`,
/// which already includes the header.
///
/// ```dart
/// appBar: const AuthAppBar(),
/// ```
class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({super.key, this.language});

  /// Ignored — the chip always shows the active app locale. Kept so existing
  /// call sites compile.
  final String? language;

  @override
  Size get preferredSize => const Size.fromHeight(AuthHeaderBar.height + 8);

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: Align(alignment: Alignment.topCenter, child: AuthHeaderBar()),
    );
  }
}
