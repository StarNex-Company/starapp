import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/create/data/models/entry_draft.dart';
import 'package:starapp/features/create/data/provider/create_providers.dart';
import 'package:starapp/features/create/presentation/widgets/create_format.dart';
import 'package:starapp/features/create/presentation/widgets/preview_category_chips.dart';
import 'package:starapp/features/create/presentation/widgets/preview_challenge_toggle.dart';
import 'package:starapp/features/create/presentation/widgets/preview_cover_picker.dart';
import 'package:starapp/features/create/presentation/widgets/preview_icons.dart';
import 'package:starapp/features/create/presentation/widgets/preview_section_head.dart';
import 'package:starapp/features/create/presentation/widgets/preview_settings_card.dart';
import 'package:starapp/features/create/presentation/widgets/preview_trim_strip.dart';
import 'package:starapp/features/create/presentation/widgets/preview_video_card.dart';
import 'package:starapp/shared/widgets/shared_icons.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_form_fields.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

class PreviewEditPage extends ConsumerStatefulWidget {
  const PreviewEditPage({super.key});

  @override
  ConsumerState<PreviewEditPage> createState() => _PreviewEditPageState();
}

class _PreviewEditPageState extends ConsumerState<PreviewEditPage> {
  final _caption = TextEditingController();
  bool _captionLoaded = false;
  bool _playing = false;

  EntryDraftNotifier get _draft => ref.read(entryDraftProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Fill the caption once the draft is in, then keep the draft in step.
    ref.listenManual(entryDraftProvider, (_, next) {
      final caption = next.value?.caption;
      if (caption == null || _captionLoaded) return;
      _caption.text = caption;
      _captionLoaded = true;
    }, fireImmediately: true);
    _caption.addListener(() {
      if (_captionLoaded) _draft.setCaption(_caption.text);
    });
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    showStarToast(context, message);
  }

  void _comingSoon() => _showMessage('Coming soon');

  Future<void> _saveDraft() async {
    try {
      await _draft.save();
      if (mounted) _showMessage('Draft saved');
    } catch (e) {
      if (mounted) _showMessage(describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(entryDraftProvider);
    final talents = ref.watch(talentCategoriesProvider);

    return Scaffold(
      appBar: StarScreenHeader(
        title: 'New Post',
        leading: const StarBackButton(),
        trailing: StarHeaderTextAction(label: 'Drafts', onTap: _comingSoon),
      ),
      body: StarAsyncView(
        value: draft,
        onRetry: () => ref.invalidate(entryDraftProvider),
        builder: (draft) => StarAsyncView(
          value: talents,
          onRetry: () => ref.invalidate(talentCategoriesProvider),
          builder: (talents) => _buildForm(draft, talents),
        ),
      ),
      bottomNavigationBar: StarBottomBar(
        child: Row(
          spacing: 12,
          children: [
            StarOutlinedButton(
              label: 'Save draft',
              width: 128,
              onPressed: _saveDraft,
            ),
            Expanded(
              child: StarPrimaryButton(
                label: 'Continue',
                trailingIcon: SharedIcons.chevronRight,
                onPressed: () => context.push(AppRoutes.createSubmitEntry),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(EntryDraft draft, List<String> talents) {
    final clip = draft.clip;
    final trim = clip.trim;
    final challenge = draft.challenge;
    double along(Duration at) => clip.duration == Duration.zero
        ? 0
        : at.inMilliseconds / clip.duration.inMilliseconds;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          PreviewVideoCard(
            frame: clip.frameUrl,
            category: draft.category,
            duration: formatDuration(trim.length),
            playing: _playing,
            onTogglePlay: () => setState(() => _playing = !_playing),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              PreviewSectionHead(label: 'Trim', note: formatTrim(trim)),
              PreviewTrimStrip(
                frames: clip.filmstripUrls,
                start: along(trim.start),
                end: along(trim.end),
                playhead: along(trim.playhead),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              const PreviewSectionHead(label: 'Cover', note: 'Auto-generated'),
              PreviewCoverPicker(
                covers: clip.coverFrameUrls,
                selected: draft.coverIndex,
                onSelected: _draft.selectCover,
                onCustom: _comingSoon,
              ),
            ],
          ),
          StarTextArea(label: 'Caption', controller: _caption, maxLength: 300),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              const PreviewSectionHead(
                label: 'Talent category',
                note: 'From your talents',
                noteWeight: FontWeight.w400,
              ),
              PreviewCategoryChips(
                categories: talents,
                selected: draft.category,
                onSelected: _draft.selectCategory,
              ),
            ],
          ),
          StarDividedCard(
            children: [
              PreviewSettingRow(
                icon: PreviewIcons.pin,
                label: 'Location',
                value: draft.location,
                onTap: _comingSoon,
              ),
              PreviewSettingRow(
                icon: PreviewIcons.users,
                label: 'Tag collaborators',
                value: 'None',
                onTap: _comingSoon,
              ),
              PreviewSettingRow(
                icon: PreviewIcons.eye,
                label: 'Who can view',
                value: 'Everyone',
                onTap: _comingSoon,
              ),
              PreviewSwitchRow(
                icon: PreviewIcons.message,
                label: 'Allow comments',
                value: draft.allowComments,
                onChanged: _draft.setAllowComments,
              ),
            ],
          ),
          PreviewChallengeToggle(
            challenge: '${challenge.title} · ${challengeStatus(challenge)}',
            value: draft.submitToChallenge,
            onChanged: _draft.setSubmitToChallenge,
          ),
        ],
      ),
    );
  }
}
