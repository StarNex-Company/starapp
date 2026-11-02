import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/moderation/data/models/moderation_case.dart';
import 'package:starapp/features/moderation/data/provider/moderation_providers.dart';
import 'package:starapp/features/moderation/presentation/widgets/appeal_proof_files.dart';
import 'package:starapp/features/moderation/presentation/widgets/appeal_reply_notice.dart';
import 'package:starapp/shared/widgets/shared_icons.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_form_fields.dart';
import 'package:starapp/shared/widgets/star_media_summary_card.dart';
import 'package:starapp/shared/widgets/star_radio_card.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// The appeal form for a moderation case: a ground, details and proof.
/// Fields the server rejects show its message under them.
class AppealPage extends ConsumerStatefulWidget {
  const AppealPage({super.key, this.caseId = defaultModerationCaseId});

  /// The case being appealed, e.g. "SA-48213".
  final String caseId;

  @override
  ConsumerState<AppealPage> createState() => _AppealPageState();
}

class _AppealPageState extends ConsumerState<AppealPage> {
  final _details = TextEditingController();
  bool _detailsLoaded = false;
  bool _submitting = false;

  /// The server's message per rejected field (`reason`, `details`).
  Map<String, String> _errors = const {};

  AppealFormNotifier get _form =>
      ref.read(appealFormProvider(widget.caseId).notifier);

  @override
  void initState() {
    super.initState();
    // Fill the details once the form is in, then keep the form in step.
    ref.listenManual(appealFormProvider(widget.caseId), (_, next) {
      final details = next.value?.details;
      if (details == null || _detailsLoaded) return;
      _details.text = details;
      _detailsLoaded = true;
    }, fireImmediately: true);
    _details.addListener(() {
      if (!_detailsLoaded) return;
      _form.setDetails(_details.text);
      _clearError('details');
    });
  }

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  void _comingSoon() {
    showStarToast(context, 'Coming soon');
  }

  void _clearError(String field) {
    if (!_errors.containsKey(field)) return;
    setState(() => _errors = {..._errors}..remove(field));
  }

  void _selectReason(String reasonId) {
    _form.selectReason(reasonId);
    _clearError('reason');
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errors = const {};
    });
    try {
      await _form.submit();
      if (mounted) {
        context.push(
          '${AppRoutes.moderationAppealSubmitted}?id=${widget.caseId}',
        );
      }
    } on ValidationException catch (e) {
      if (!mounted) return;
      setState(() => _errors = e.fieldErrors);
      showStarToast(context, describeError(e));
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseProvider = moderationCaseProvider(widget.caseId);
    final formProvider = appealFormProvider(widget.caseId);
    final appealCase = ref.watch(caseProvider);
    final form = ref.watch(formProvider);

    return Scaffold(
      appBar: const StarScreenHeader(
        title: 'Appeal Decision',
        leading: StarBackButton(),
      ),
      body: StarAsyncView(
        value: appealCase,
        onRetry: () => ref.invalidate(caseProvider),
        builder: (appealCase) => StarAsyncView(
          value: form,
          onRetry: () => ref.invalidate(formProvider),
          builder: (form) => _buildForm(appealCase, form),
        ),
      ),
      bottomNavigationBar: StarBottomBar(
        child: StarPrimaryButton(
          label: 'Submit appeal',
          leadingIcon: SharedIcons.send,
          onPressed: _submitting || !form.hasValue ? null : _submit,
        ),
      ),
    );
  }

  Widget _buildForm(ModerationCase appealCase, AppealForm form) {
    final reasonError = _errors['reason'];
    final detailsError = _errors['details'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          StarMediaSummaryCard(
            thumbnail: appealCase.post.thumbnailUrl ?? '',
            thumbnailSize: 52,
            blurThumbnail: true,
            title: appealCase.post.title,
            titleFontSize: 14,
            subtitle: appealCase.reason,
            trailing: _CaseChip('#${appealCase.id}'),
          ),
          const StarSectionLabel('Why should we review this?'),
          _WithError(
            error: reasonError,
            child: StarRadioCard<String>(
              options: [
                for (final reason in appealCase.appealReasons)
                  StarRadioOption(
                    value: reason.id,
                    title: reason.title,
                    subtitle: reason.subtitle,
                  ),
              ],
              selected: form.reasonId,
              onChanged: _selectReason,
            ),
          ),
          _WithError(
            error: detailsError,
            child: StarTextArea(
              label: 'Tell us more',
              controller: _details,
              maxLength: 500,
              minHeight: 112,
            ),
          ),
          const StarSectionLabel('Proof (optional)'),
          AppealAddFilesButton(label: 'Add files', onTap: _comingSoon),
          const AppealReplyNotice(),
        ],
      ),
    );
  }
}

/// [child] with the server's message for it underneath, when there is one.
class _WithError extends StatelessWidget {
  const _WithError({required this.error, required this.child});

  final String? error;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    if (error == null) return child;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        child,
        Text(
          error,
          style: const TextStyle(
            height: 1.21,
            letterSpacing: 0,
            fontSize: 12,
            color: AppColors.authError,
          ),
        ),
      ],
    );
  }
}

class _CaseChip extends StatelessWidget {
  const _CaseChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: const BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: const TextStyle(
            height: 1.2,
            letterSpacing: 0,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.brandBlue,
          ),
        ),
      ),
    );
  }
}
