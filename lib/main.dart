import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/app/localization/app_localizations.dart';
import 'package:starapp/app/providers/locale_provider.dart';
import 'package:starapp/app/router/app_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_client.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';

void main() {
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: kDebugMode,
        builder: (_) => const StarApp(),
      ),
    ),
  );
}

class StarApp extends ConsumerWidget {
  const StarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    // A 401 anywhere has already cleared the token: drop the user's state
    // and send them to sign in.
    ref.listen(sessionExpiredProvider, (_, _) {
      ref
        ..invalidate(currentUserProvider)
        ..invalidate(followingProvider);
      appRouter.go(AppRoutes.signIn);
    });

    return MaterialApp.router(
      title: 'Starapp',
      theme: AppTheme.light,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // User-selected locale takes priority; falls back to DevicePreview/system locale
      locale: locale ?? DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
    );
  }
}
