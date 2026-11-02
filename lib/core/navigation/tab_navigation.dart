import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension TabNavigation on BuildContext {
  /// Whether this page sits on the root navigator (full screen, above the
  /// tabs) rather than inside a tab's stack.
  bool get isOnRootNavigator =>
      Navigator.of(this) == Navigator.of(this, rootNavigator: true);

  /// Pushes a page that lives inside a tab (e.g. `AppRoutes.company(id)`)
  /// from anywhere. From a tab it pushes [tabPath] and the page opens in the
  /// current tab. From a full-screen page, which go_router can't push tab
  /// routes from, it pushes the top-level mirror: [tabPath] without its tab
  /// segment (`/messages/scout/companies/x` → `/scout/companies/x`). The
  /// router registers mirrors only for the routes documented in `AppRoutes`.
  Future<T?> pushInTab<T extends Object?>(String tabPath) {
    if (!isOnRootNavigator) return push<T>(tabPath);
    final uri = Uri.parse(tabPath);
    final mirror = uri.replace(pathSegments: uri.pathSegments.skip(1));
    return push<T>(mirror.toString().startsWith('/') ? '$mirror' : '/$mirror');
  }
}
