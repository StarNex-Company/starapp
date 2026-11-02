import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/localization/app_localizations.dart';
import 'package:starapp/app/providers/locale_provider.dart';
import 'package:starapp/app/router/app_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/pages/forgot_password.dart';
import 'package:starapp/features/auth/presentation/pages/interests.dart';
import 'package:starapp/features/auth/presentation/pages/language_selection.dart';
import 'package:starapp/features/auth/presentation/pages/new_password.dart';
import 'package:starapp/features/auth/presentation/pages/notification_permission.dart';
import 'package:starapp/features/auth/presentation/pages/otp_screen.dart';
import 'package:starapp/features/auth/presentation/pages/profile_picture.dart';
import 'package:starapp/features/auth/presentation/pages/secure_profile.dart';
import 'package:starapp/features/auth/presentation/pages/sign_in.dart';
import 'package:starapp/features/auth/presentation/pages/sign_up.dart';
import 'package:starapp/features/auth/presentation/pages/welcome.dart';
import 'package:starapp/features/auth/presentation/pages/welcome_challenge.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_check.dart';
import 'package:starapp/features/home/presentation/pages/home_page.dart';
import 'package:starapp/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:starapp/features/splash/presentation/pages/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GoRouter> _pumpApp(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 62, bottom: 34);
  addTearDown(tester.view.reset);

  final router = createAppRouter(initialLocation: location);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await _settle(tester);
  return router;
}

// Splash, the welcome challenge and the notification orbit animate forever.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpWidget(const SizedBox());
}

void main() {
  // The locale provider reads saved preferences.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final pages = <String, Type>{
    AppRoutes.splash: SplashScreen,
    AppRoutes.onboarding: OnboardingScreen,
    AppRoutes.welcome: WelcomeScreen,
    AppRoutes.signIn: SignInScreen,
    AppRoutes.signUp: SignUpScreen,
    AppRoutes.otp: OtpScreen,
    '${AppRoutes.otp}?mode=reset': OtpScreen,
    AppRoutes.forgotPassword: ForgotPasswordScreen,
    AppRoutes.newPassword: NewPasswordScreen,
    AppRoutes.language: LanguageSelectionScreen,
    AppRoutes.registerPassword: SecureProfileScreen,
    AppRoutes.registerPhoto: ProfilePictureScreen,
    AppRoutes.registerInterests: InterestsScreen,
    AppRoutes.welcomeChallenge: WelcomeChallengeScreen,
    AppRoutes.registerNotifications: NotificationPermissionScreen,
  };
  for (final MapEntry(key: location, value: page) in pages.entries) {
    testWidgets('$location renders without layout errors', (tester) async {
      await _pumpApp(tester, location);

      expect(find.byType(page), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _unmount(tester);
    });
  }

  testWidgets('the OTP route reads its mode from the query', (tester) async {
    await _pumpApp(tester, '${AppRoutes.otp}?mode=reset');

    final otp = tester.widget<OtpScreen>(find.byType(OtpScreen));
    expect(otp.mode, OtpMode.reset);
    await _unmount(tester);
  });

  testWidgets('signing in lands on Home', (tester) async {
    await _pumpApp(tester, AppRoutes.signIn);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'ada@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(find.text('Log In'));
    await _settle(tester);

    expect(find.byType(HomePage), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('the notifications step finishes on Home', (tester) async {
    await _pumpApp(tester, AppRoutes.registerNotifications);

    await tester.tap(find.text('Maybe Later'));
    await _settle(tester);

    expect(find.byType(HomePage), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('sign up records the name and email', (tester) async {
    await _pumpApp(tester, AppRoutes.signUp);

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'Ada Lovelace');
    await tester.enterText(fields.at(1), 'ada@example.com');
    // The terms box, left of its label.
    await tester.tapAt(
      tester.getRect(find.byType(AuthCheck)).centerLeft + const Offset(7, 0),
    );
    await tester.pump();
    await tester.tap(find.text('Continue with Email'));
    await _settle(tester);

    expect(find.byType(OtpScreen), findsOneWidget);
    final registration = _container(tester).read(registrationProvider);
    expect(registration.fullName, 'Ada Lovelace');
    expect(registration.email, 'ada@example.com');
    await _unmount(tester);
  });

  testWidgets('the username check flags taken names and ticks free ones', (
    tester,
  ) async {
    await _pumpApp(tester, AppRoutes.registerPassword);

    final username = find.byType(EditableText).first;
    await tester.enterText(username, 'admin');
    await tester.pump();
    expect(find.text('This username is already taken'), findsOneWidget);
    expect(_semantics('Username available'), findsNothing);

    await tester.enterText(username, 'ada_l');
    await tester.pump();
    expect(find.text('This username is already taken'), findsNothing);
    expect(_semantics('Username available'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('the photo and interests steps record their choices', (
    tester,
  ) async {
    await _pumpApp(tester, AppRoutes.registerPhoto);

    await tester.tap(_semantics('Avatar 2'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Continue'));
    await _settle(tester);

    expect(find.byType(InterestsScreen), findsOneWidget);
    expect(
      _container(tester).read(registrationProvider).avatar,
      'assets/images/auth_avatar_3.png',
    );

    await tester.tap(find.text('Singing'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await _settle(tester);

    expect(find.byType(WelcomeChallengeScreen), findsOneWidget);
    expect(_container(tester).read(registrationProvider).interests, {
      'Singing',
    });
    await _unmount(tester);
  });

  testWidgets('Done saves the picked language', (tester) async {
    await _pumpApp(tester, AppRoutes.language);

    await tester.tap(find.text('Español'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await _settle(tester);

    expect(_container(tester).read(localeProvider), const Locale('es'));
    await _unmount(tester);
  });
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

Finder _semantics(String label) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == label,
);
