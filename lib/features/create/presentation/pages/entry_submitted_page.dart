import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';
import 'package:starapp/features/create/data/models/entry_submission.dart';
import 'package:starapp/features/create/data/provider/create_providers.dart';
import 'package:starapp/features/create/presentation/widgets/submitted_entry_card.dart';
import 'package:starapp/features/create/presentation/widgets/submitted_next_steps.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_success_hero.dart';

const _bonusTint = Color(0xFFFFF3CC); // surface/tint/fff3cc

const _checkIcon = 'assets/vectors/create/submitted_check.svg';
const _starIcon = 'assets/vectors/create/submitted_star.svg';

class EntrySubmittedPage extends ConsumerWidget {
  const EntrySubmittedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(entryDraftProvider);
    final submission = ref.watch(
      entryUploadProvider.select((status) => status.submission),
    );

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
                child: StarAsyncView(
                  value: draft,
                  onRetry: () => ref.invalidate(entryDraftProvider),
                  builder: (draft) =>
                      _Content(draft: draft, submission: submission),
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
                label: 'View Challenge',
                onPressed: () => context.push(
                  '${AppRoutes.challengeDetail}'
                  '?id=${draft.value?.challenge.id ?? ''}',
                ),
              ),
              StarTextButton(
                label: 'Back to Home',
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.draft, required this.submission});

  final EntryDraft draft;

  /// The upload's answer; null when the page opens without one.
  final EntrySubmission? submission;

  @override
  Widget build(BuildContext context) {
    final submission = this.submission;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        spacing: 16,
        children: [
          StarSuccessHero(
            icon: _checkIcon,
            glowColor: AppColors.gold,
            title: "You're in the arena!",
            message:
                'Your entry for ${draft.challenge.title} is under '
                "review. We'll let you know the moment it's live.",
            chip: submission == null || submission.bonusStars == 0
                ? null
                : StarSuccessChip(
                    icon: _starIcon,
                    label: '+${submission.bonusStars} Stars · entry bonus',
                    background: _bonusTint,
                    foreground: AppColors.goldText,
                  ),
          ),
          SubmittedEntryCard(
            thumbnail: draft.clip.frameUrl,
            title: draft.title,
            submittedLabel: 'Submitted just now',
          ),
          if (submission != null && submission.nextSteps.isNotEmpty)
            SubmittedNextSteps(steps: submission.nextSteps),
        ],
      ),
    );
  }
}
