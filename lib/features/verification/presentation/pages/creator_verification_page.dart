import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/verification/data/models/verification.dart';
import 'package:starapp/features/verification/data/provider/verification_providers.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_hero.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_id_chips.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_notice.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_progress.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_steps.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_style.dart';
import 'package:starapp/features/verification/presentation/widgets/verification_upload_box.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// "Get Verified" (Figma "Verification — Creator Verification", also reached
/// from Shortcuts and Settings with the same layout): the creator checklist
/// with the identity step open. "Upload ID & continue" submits the chosen
/// document and opens [AppRoutes.verificationDone]. No bottom navigation.
class CreatorVerificationPage extends ConsumerStatefulWidget {
  const CreatorVerificationPage({super.key});

  @override
  ConsumerState<CreatorVerificationPage> createState() =>
      _CreatorVerificationPageState();
}

class _CreatorVerificationPageState
    extends ConsumerState<CreatorVerificationPage> {
  /// A photo is being uploaded from the upload box.
  bool _uploading = false;

  /// Stands in for the photo the camera or file picker would return; there's
  /// no picker plugin yet, so mock mode uploads this name.
  static String _samplePhoto(VerificationIdType type) =>
      '${type.id.replaceAll('-', '_')}_sample.jpg';

  void _fail(Object error) => showStarToast(
    context,
    describeError(error),
    badge: const StarToastBadge(glyph: '!', color: AppColors.danger),
  );

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.profile);

  // The "Getting verified" help article isn't built yet.
  void _help() => showStarToast(context, 'Coming soon');

  VerificationIdType _selectedType(
    VerificationOverview overview,
    VerificationForm form,
  ) => overview.idTypes.firstWhere(
    (t) => t.id == form.idTypeId,
    orElse: () => overview.idTypes.first,
  );

  Future<void> _upload(VerificationIdType type) async {
    setState(() => _uploading = true);
    try {
      final document = await ref
          .read(verificationFormProvider.notifier)
          .upload(type, _samplePhoto(type));
      if (!mounted) return;
      if (document != null) {
        // No camera or file picker yet.
        showStarToast(context, 'Sample photo added · uploads coming soon');
      }
    } catch (error) {
      if (mounted) _fail(error);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _continue(VerificationOverview overview) async {
    final form = ref.read(verificationFormProvider);
    final usedSample = form.document == null;
    final type = _selectedType(overview, form);
    final bool submitted;
    try {
      submitted = await ref
          .read(verificationFormProvider.notifier)
          .submit(type, filePath: _samplePhoto(type));
    } catch (error) {
      if (mounted) _fail(error);
      return;
    }
    if (!mounted || !submitted) return;
    if (usedSample) {
      showStarToast(context, 'Sample ID sent · uploads coming soon');
    }
    context.push(AppRoutes.verificationDone);
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(verificationOverviewProvider);
    final form = ref.watch(verificationFormProvider);
    final loaded = overview.value;
    final canContinue =
        loaded != null && loaded.idTypes.isNotEmpty && !form.submitting;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Get Verified',
        leading: StarIconButton.back(onPressed: _back),
        trailing: StarIconButton.info(onPressed: _help),
      ),
      body: StarAsyncView(
        value: overview,
        onRetry: () => ref.invalidate(verificationOverviewProvider),
        builder: (overview) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 25, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              const VerificationHero(),
              VerificationProgress(
                completed: overview.completed,
                total: overview.total,
              ),
              VerificationSteps(
                steps: overview.steps,
                currentStepBody: overview.idTypes.isEmpty
                    ? null
                    : _identityStep(overview, form),
              ),
              const VerificationNotice(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StarBottomBar(
        child: StarPrimaryButton(
          label: 'Upload ID & continue',
          leadingIcon: VerificationIcons.upload,
          onPressed: canContinue ? () => _continue(loaded) : null,
        ),
      ),
    );
  }

  Widget _identityStep(VerificationOverview overview, VerificationForm form) {
    final type = _selectedType(overview, form);
    final notifier = ref.read(verificationFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        VerificationIdChips(
          types: overview.idTypes,
          selectedId: type.id,
          onSelected: form.submitting
              ? (_) {}
              : (t) => notifier.selectIdType(t.id),
        ),
        VerificationUploadBox(
          prompt: type.uploadPrompt,
          document: form.document,
          uploading: _uploading || form.submitting,
          onTap: () => _upload(type),
        ),
      ],
    );
  }
}
