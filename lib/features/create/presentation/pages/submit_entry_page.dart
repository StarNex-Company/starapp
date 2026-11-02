import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/create/data/models/challenge_summary.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';
import 'package:starapp/features/create/data/provider/create_providers.dart';
import 'package:starapp/features/create/presentation/widgets/create_format.dart';
import 'package:starapp/features/create/presentation/widgets/preview_video_card.dart';
import 'package:starapp/features/create/presentation/widgets/submit_challenge_hero.dart';
import 'package:starapp/features/create/presentation/widgets/submit_collaborator_field.dart';
import 'package:starapp/features/create/presentation/widgets/submit_icons.dart';
import 'package:starapp/features/create/presentation/widgets/submit_review_notice.dart';
import 'package:starapp/features/create/presentation/widgets/submit_rules_card.dart';
import 'package:starapp/shared/widgets/shared_icons.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_form_fields.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_media_summary_card.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

class SubmitEntryPage extends ConsumerWidget {
  const SubmitEntryPage({super.key});

  void _comingSoon(BuildContext context) {
    showStarToast(context, 'Coming soon');
  }

  void _showRules(BuildContext context, ChallengeSummary challenge) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        title: Text(
          challenge.title,
          style: const TextStyle(
            height: 1.2,
            letterSpacing: 0,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.brandNavy,
          ),
        ),
        content: SingleChildScrollView(
          child: SubmitRuleList(rules: challenge.rules),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(entryDraftProvider);
    final featured = ref.watch(featuredChallengeProvider);
    final challenges = ref.watch(eligibleChallengesProvider);
    final rulesAccepted = draft.value?.rulesAccepted ?? false;

    return Scaffold(
      appBar: StarScreenHeader(
        title: 'Submit Entry',
        leading: const StarBackButton(),
        trailing: StarIconButton.info(
          onPressed: () {
            final challenge = draft.value?.challenge;
            if (challenge != null) _showRules(context, challenge);
          },
        ),
      ),
      body: StarAsyncView(
        value: draft,
        onRetry: () => ref.invalidate(entryDraftProvider),
        builder: (draft) => StarAsyncView(
          value: featured,
          onRetry: () => ref.invalidate(featuredChallengeProvider),
          builder: (featured) => StarAsyncView(
            value: challenges,
            onRetry: () => ref.invalidate(eligibleChallengesProvider),
            builder: (challenges) =>
                _buildForm(context, ref, draft, featured, challenges),
          ),
        ),
      ),
      bottomNavigationBar: StarBottomBar(
        child: StarPrimaryButton(
          label: 'Submit Entry',
          leadingIcon: SharedIcons.send,
          onPressed: rulesAccepted
              ? () => context.push(AppRoutes.createUploading)
              : null,
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    WidgetRef ref,
    EntryDraft draft,
    FeaturedChallenge featured,
    List<ChallengeSummary> challenges,
  ) {
    final notifier = ref.read(entryDraftProvider.notifier);
    final clip = draft.clip;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          SubmitChallengeHero(
            image: featured.coverUrl,
            category: featured.challenge.category,
            title: featured.challenge.title,
            prize: '${featured.prize.format()} Grand Prize',
            entries:
                '${formatGrouped(featured.entryCount)} / '
                '${formatGrouped(featured.capacity)} entries',
          ),
          const StarSectionLabel('Select challenge'),
          StarRadioCard<ChallengeSummary>(
            options: [
              for (final challenge in challenges)
                StarRadioOption(
                  value: challenge,
                  title: challenge.title,
                  subtitle:
                      '${challenge.category} · ${challengeStatus(challenge)}',
                  enabled: challenge.isEligible,
                ),
            ],
            selected: draft.challenge,
            onChanged: notifier.selectChallenge,
          ),
          const StarSectionLabel('Your entry'),
          StarMediaSummaryCard(
            thumbnail: clip.frameUrl ?? '',
            title: draft.title,
            subtitle:
                '${formatDuration(clip.trim.length)} · ${draft.category} · '
                '${draft.city}',
            thumbnailOverlay: const PreviewPlayBadge(
              size: 26,
              icon: SubmitIcons.play,
              iconSize: 10.92,
              borderColor: Color(0x80FFFFFF),
            ),
            trailing: _ChangeButton(onTap: () => context.pop()),
          ),
          const StarSectionLabel('Collaborator (optional)'),
          SubmitCollaboratorField(
            collaborator: draft.collaborator,
            onRemove: notifier.removeCollaborator,
            onTag: () => _comingSoon(context),
          ),
          const StarSectionLabel('Challenge rules'),
          SubmitRulesCard(
            rules: draft.challenge.rules,
            confirmed: draft.rulesAccepted,
            onConfirmedChanged: notifier.setRulesAccepted,
          ),
          const SubmitReviewNotice(),
        ],
      ),
    );
  }
}

class _ChangeButton extends StatelessWidget {
  const _ChangeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Change',
            style: TextStyle(
              height: 1.2,
              letterSpacing: 0,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
        ),
      ),
    );
  }
}
