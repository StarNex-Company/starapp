import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/stories/data/models/new_story.dart';
import 'package:starapp/features/stories/data/provider/stories_providers.dart';
import 'package:starapp/features/stories/presentation/widgets/story_caption_step.dart';
import 'package:starapp/features/stories/presentation/widgets/story_choose_step.dart';
import 'package:starapp/features/stories/presentation/widgets/story_settings_sheet.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Story creation (`/story/create`), full screen over the shell:
/// 1. "Add to story" — pick a photo or video from the sample camera roll;
/// 2. caption — add a caption, choose audience and duration in the Story
///    settings sheet, then "Your story" uploads it and closes (or says why
///    it failed and stays).
///
/// Back on step 2 returns to step 1; close on step 1 leaves.
class StoryCreatePage extends ConsumerStatefulWidget {
  const StoryCreatePage({super.key});

  @override
  ConsumerState<StoryCreatePage> createState() => _StoryCreatePageState();
}

class _StoryCreatePageState extends ConsumerState<StoryCreatePage> {
  StoryMedia? _selected;
  bool _captioning = false;
  bool _posting = false;
  final _caption = TextEditingController();

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _toCaption() {
    if (_selected == null) return;
    setState(() => _captioning = true);
  }

  void _toChoose() {
    FocusScope.of(context).unfocus();
    setState(() => _captioning = false);
  }

  Future<void> _openSettings() async {
    FocusScope.of(context).unfocus();
    final result = await showStorySettingsSheet(
      context,
      initial: ref.read(storySettingsProvider),
    );
    if (result != null && mounted) {
      ref.read(storySettingsProvider.notifier).apply(result);
    }
  }

  Future<void> _post(StoryMedia media) async {
    if (_posting) return;
    FocusScope.of(context).unfocus();
    final settings = ref.read(storySettingsProvider);
    _posting = true;
    try {
      await ref
          .read(storySettingsProvider.notifier)
          .post(media, caption: _caption.text.trim());
      if (!mounted) return;
      showStarToast(
        context,
        'Added to your story · visible for ${settings.duration.label}',
      );
      _leave();
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    } finally {
      _posting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gallery = ref.watch(storyGalleryProvider);
    final settings = ref.watch(storySettingsProvider);
    final me = ref.watch(currentUserProvider).value;
    final selected = _selected;
    final captioning = _captioning && selected != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: !captioning,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _toChoose();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: captioning
                ? StoryCaptionStep(
                    key: const ValueKey('caption'),
                    media: selected,
                    userAvatarUrl: me?.avatarUrl,
                    caption: _caption,
                    settings: settings,
                    onBack: _toChoose,
                    onTool: (_) => showStarToast(context, 'Coming soon'),
                    onSettings: _openSettings,
                    onPost: () => _post(selected),
                  )
                : StarAsyncView(
                    key: const ValueKey('choose'),
                    value: gallery,
                    onRetry: () => ref.invalidate(storyGalleryProvider),
                    builder: (media) => StoryChooseStep(
                      media: media,
                      selected: selected,
                      onSelect: (media) => setState(() => _selected = media),
                      onClose: _leave,
                      onNext: _toCaption,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
