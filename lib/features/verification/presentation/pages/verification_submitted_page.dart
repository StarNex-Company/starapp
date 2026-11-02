import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/verification/data/provider/verification_providers.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_success_hero.dart';

/// "Verification submitted" (Figma "Verification — Submitted"). The ID is in
/// review, so closing (or the system back) returns to the profile rather
/// than the form. No bottom navigation.
class VerificationSubmittedPage extends ConsumerWidget {
  const VerificationSubmittedPage({super.key});

  void _toProfile(BuildContext context) => context.go(AppRoutes.profile);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(verificationOverviewProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _toProfile(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: StarIconButton.close(
                  onPressed: () => _toProfile(context),
                ),
              ),
              Expanded(
                child: StarAsyncView(
                  value: overview,
                  onRetry: () => ref.invalidate(verificationOverviewProvider),
                  builder: (overview) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 29, 24, 24),
                    child: StarSuccessHero(
                      icon: VerificationIcons.submittedShield,
                      glowColor: AppColors.brandBlue,
                      title: 'Verification submitted',
                      message:
                          "We're checking your ID now. Most creators get "
                          "verified within a day, and we'll let you know as "
                          "soon as you're in.",
                      chip: StarSuccessChip(
                        icon: VerificationIcons.checkSmall,
                        label:
                            'Step ${overview.currentStepNumber} of '
                            '${overview.total} complete',
                        background: AppColors.successTint,
                        foreground: VerificationColors.successText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: StarBottomBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              StarPrimaryButton(
                label: 'Back to profile',
                onPressed: () => _toProfile(context),
              ),
              StarTextButton(
                label: 'Explore challenges',
                onPressed: () => context.go(AppRoutes.challenges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
