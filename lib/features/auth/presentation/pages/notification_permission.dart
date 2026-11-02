import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_notification_orbit.dart';

/// Last onboarding step: asks to turn notifications on (Figma "Notif"
/// `546:1331`, route [AppRoutes.registerNotifications]).
///
/// Logo header (no language chip), the animated orbit illustration, title,
/// body copy and two actions. There is no notifications plugin yet, so
/// "Enable Notifications" and "Maybe Later" both continue to Home.
///
/// Gaps match the 393×852 frame and grow evenly on taller screens; on short
/// ones the page scrolls.
class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  static const _title = TextStyle(
    fontFamily: 'Inter',
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.21,
    letterSpacing: 0,
    color: AppColors.brandNavy,
  );

  static const _body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.21,
    letterSpacing: 0,
    color: AppColors.brandNavy,
  );

  void _continue(BuildContext context) => context.go(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    final bottomGap = MediaQuery.viewPaddingOf(context).bottom + 24;
    return Scaffold(
      backgroundColor: AppColors.lunarWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeaderBar(showLanguageChip: false),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Shrink the illustration (down to 60%) on short screens
                  // so the actions stay on screen; 387 is everything else at
                  // the design's size.
                  final orbitScale =
                      ((constraints.maxHeight - bottomGap - 387) / 300).clamp(
                        0.6,
                        1.0,
                      );
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, bottomGap),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - bottomGap,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Design gaps 60 / 62 / 52 at 852 high: a fixed
                            // minimum plus a share of the spare height.
                            const SizedBox(height: 24),
                            const Spacer(flex: 36),
                            // As in the frame, the 302 box sits 3.5px left of
                            // centre (x 42), which puts the rings 2px right.
                            Transform.translate(
                              offset: Offset(-3.5 * orbitScale, 0),
                              child: Center(
                                child: SizedBox(
                                  width:
                                      AuthNotificationOrbit.size.width *
                                      orbitScale,
                                  height:
                                      AuthNotificationOrbit.size.height *
                                      orbitScale,
                                  child: const FittedBox(
                                    child: AuthNotificationOrbit(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Spacer(flex: 30),
                            const Text(
                              'Never Miss an Opportunity',
                              textAlign: TextAlign.center,
                              style: _title,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Stay informed about new followers, challenge '
                              'updates, messages, creator activity, and '
                              'opportunities tailored to your interests.',
                              textAlign: TextAlign.center,
                              style: _body,
                            ),
                            const SizedBox(height: 32),
                            const Spacer(flex: 20),
                            AuthPrimaryButton(
                              label: 'Enable Notifications',
                              onPressed: () => _continue(context),
                            ),
                            const SizedBox(height: 15),
                            AuthSecondaryButton(
                              label: 'Maybe Later',
                              onPressed: () => _continue(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
