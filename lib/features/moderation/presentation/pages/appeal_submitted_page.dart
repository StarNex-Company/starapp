import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/moderation/data/provider/moderation_providers.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_success_hero.dart';

const _shieldCheckIcon =
    'assets/vectors/moderation/appeal_submitted_shield_check.svg';
const _fileIcon = 'assets/vectors/moderation/appeal_submitted_file.svg';

/// Confirms the appeal against a case went in.
class AppealSubmittedPage extends StatelessWidget {
  const AppealSubmittedPage({super.key, this.caseId = defaultModerationCaseId});

  /// The appealed case, e.g. "SA-48213".
  final String caseId;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 9),
                child: StarIconButton.close(
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: StarSuccessHero(
                    icon: _shieldCheckIcon,
                    glowColor: AppColors.brandBlue,
                    title: 'Appeal submitted',
                    message:
                        'Thanks for helping keep Star App fair. A reviewer will '
                        'look at your case and reply within 48 hours.',
                    chip: StarSuccessChip(
                      icon: _fileIcon,
                      label: 'Case #$caseId',
                      background: AppColors.brandTint,
                      foreground: AppColors.brandBlue,
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
                label: 'Back to Home',
                onPressed: () => context.go(AppRoutes.home),
              ),
              StarTextButton(
                label: 'View notifications',
                onPressed: () => context.go(AppRoutes.notifications),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
