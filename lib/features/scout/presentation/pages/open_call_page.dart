import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';
import 'package:starapp/features/scout/data/provider/scout_providers.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_widgets.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Open Call Detail (Figma "Scout — Listing Detail"): the company notice,
/// budget, dates, location, applicants, the role and its requirements, and
/// the apply button with its applied, closed and not-eligible states. Lives
/// in the Messages tab, with a full-screen mirror.
class OpenCallPage extends ConsumerWidget {
  const OpenCallPage({super.key, required this.callId});

  final String callId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = ref.watch(openCallProvider(callId));
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Open call',
        leading: StarIconButton.back(
          onPressed: () => scoutBack(context, AppRoutes.scout),
        ),
      ),
      body: StarAsyncView(
        value: call,
        onRetry: () => ref.invalidate(openCallProvider(callId)),
        builder: (call) => ListView(
          padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
          children: [
            _CompanyNotice(company: call.summary.company),
            const SizedBox(height: 12),
            Text(
              call.summary.title,
              style: scoutText(22, weight: FontWeight.w700, height: 30 / 22),
            ),
            const SizedBox(height: 12),
            ..._facts(call).expand((row) => [row, const SizedBox(height: 12)]),
            if (call.description.isNotEmpty) ...[
              const ScoutSectionTitle('About the role'),
              const SizedBox(height: 12),
              Text(
                call.description,
                style: scoutText(
                  14,
                  color: ScoutColors.bodyAlt,
                  height: 22 / 14,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (call.requirements.isNotEmpty) ...[
              const ScoutSectionTitle('Requirements'),
              const SizedBox(height: 12),
              for (final requirement in call.requirements)
                _Requirement(requirement: requirement),
              const SizedBox(height: 12),
            ],
            _ApplyAction(call: call),
          ],
        ),
      ),
    );
  }

  /// Budget, dates, location and applicants, with rules between them.
  List<Widget> _facts(OpenCall call) {
    final summary = call.summary;
    final start = summary.startDate;
    final location = callLocation(summary);
    return withDividers([
      ScoutListRow(
        icon: ScoutIcons.wallet20,
        title: 'Budget',
        subtitle: budgetUnitLabel(summary.budget.unit),
        value: formatBudget(summary.budget),
      ),
      if (start != null)
        ScoutListRow(
          icon: ScoutIcons.calendar,
          title: 'Dates',
          subtitle: call.scheduleNote,
          value: formatDateRange(start, summary.endDate),
        ),
      if (location.isNotEmpty || call.locationLabel.isNotEmpty)
        ScoutListRow(
          icon: ScoutIcons.pin20,
          title: 'Location',
          subtitle: call.locationLabel,
          value: location,
        ),
      ScoutListRow(
        icon: ScoutIcons.users,
        title: 'Applicants',
        subtitle: summary.isClosedAt(DateTime.now())
            ? 'Closed'
            : 'Closes in ${formatDaysLeft(summary.closesAt)}',
        value: '${formatGrouped(summary.applicantsCount)} applied',
      ),
    ]);
  }
}

/// "Afrowave Records · Verified company" with the company's track record;
/// opens the company page.
class _CompanyNotice extends ConsumerWidget {
  const _CompanyNotice({required this.company});

  final CompanySummary company;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The record (artists signed, creators hired) comes with the company
    // page; until then the notice shows type and city.
    final details = ref.watch(companyProvider(company.id)).value;
    final where = [
      if (company.type.isNotEmpty) company.type,
      if (company.city.isNotEmpty) 'in ${company.city}',
    ].join(' ');
    final body = [
      if (where.isNotEmpty) where,
      if (details != null && details.artistsSignedCount > 0)
        '${formatGrouped(details.artistsSignedCount)} artists signed',
      if (details != null && details.creatorsHiredCount > 0)
        'hired ${formatGrouped(details.creatorsHiredCount)} Star App creators',
    ].join(' · ');

    return ScoutNotice(
      icon: ScoutIcons.shield,
      title: company.isVerified
          ? '${company.name} · Verified company'
          : company.name,
      body: body,
      onTap: () => context.pushInTab(AppRoutes.company(company.id)),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.requirement});

  final OpenCallRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final met = requirement.isMet;
    return Semantics(
      label: met ? 'Met' : 'Not met',
      child: Text(
        '${met ? '✓' : '✕'} ${requirement.label}',
        style: scoutText(
          14,
          weight: FontWeight.w500,
          color: met ? ScoutColors.successText : AppColors.textSubtle,
          height: 22 / 14,
        ),
      ),
    );
  }
}

/// Apply now → Applying → Applied · status; Closed and Not eligible are
/// quiet grey bars, the latter naming the missing requirement.
class _ApplyAction extends ConsumerWidget {
  const _ApplyAction({required this.call});

  final OpenCall call;

  Future<void> _apply(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(scoutApplyProvider.notifier).apply(call.id);
    } catch (e) {
      if (context.mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apply = ref.watch(scoutApplyProvider);
    final status = apply.statusOf(call.summary);
    final applying = apply.isApplying(call.id);

    if (status != null && !applying) {
      return _StatusBar(
        label: appliedLabel(status),
        background: AppColors.successTint,
        color: ScoutColors.successText,
        icon: ScoutIcons.checkApplied,
      );
    }
    if (call.summary.isClosedAt(DateTime.now())) {
      return const _StatusBar(
        label: 'Closed',
        background: AppColors.closeButtonBg,
        color: AppColors.textSubtle,
      );
    }
    if (!call.summary.isEligible) {
      final missing = call.unmetRequirement;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          const _StatusBar(
            label: 'Not eligible',
            background: AppColors.closeButtonBg,
            color: AppColors.textSubtle,
          ),
          if (missing != null)
            Text(
              'Requires: ${missing.label}',
              textAlign: TextAlign.center,
              style: scoutText(12.5, color: AppColors.textSubtle),
            ),
        ],
      );
    }
    return _PrimaryApply(
      busy: applying,
      onPressed: applying ? null : () => _apply(context, ref),
    );
  }
}

class _PrimaryApply extends StatelessWidget {
  const _PrimaryApply({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback? onPressed;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: _radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x2E032886),
            offset: Offset(0, 6),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: _radius,
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              if (busy) const ScoutSpinner(color: Colors.white),
              Text(
                busy ? 'Applying' : 'Apply now',
                style: scoutText(
                  15,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.label,
    required this.background,
    required this.color,
    this.icon,
  });

  final String label;
  final Color background;
  final Color color;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 6,
        children: [
          if (icon != null) SvgPicture.asset(icon!),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: scoutText(15, weight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
