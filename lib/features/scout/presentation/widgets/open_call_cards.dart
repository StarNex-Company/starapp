import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_widgets.dart';
import 'package:starapp/shared/widgets/star_image.dart';

/// "Record label · Lagos": whichever parts are known.
String companyLine(CompanySummary company) =>
    [company.type, company.city].where((p) => p.isNotEmpty).join(' · ');

/// The marketplace's navy "Featured Call" card. The whole card opens the
/// call; the gold button applies in one tap.
class FeaturedCallCard extends StatelessWidget {
  const FeaturedCallCard({
    super.key,
    required this.call,
    required this.status,
    required this.applying,
    required this.onTap,
    required this.onApply,
  });

  final OpenCallSummary call;

  /// The user's application, counting one made this session.
  final ApplicationStatus? status;
  final bool applying;
  final VoidCallback onTap;
  final VoidCallback onApply;

  static const _radius = BorderRadius.all(Radius.circular(22));

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: ScoutColors.featuredGradient,
        borderRadius: _radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x47032886),
            offset: Offset(0, 12),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _radius,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  top: -90,
                  right: -90,
                  child: SvgPicture.asset(ScoutIcons.glow),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      _Company(company: call.company),
                      Text(
                        call.title,
                        style: scoutText(
                          18,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          height: 24 / 18,
                        ),
                      ),
                      _Tags(call: call),
                      _Meta(call: call),
                      _FeaturedApplyButton(
                        status: status,
                        applying: applying,
                        onApply: onApply,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Company extends StatelessWidget {
  const _Company({required this.company});

  final CompanySummary company;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        CompanyLogo(company: company, size: 44, radius: 12.32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              CompanyNameRow(
                company: company,
                badgeSize: 14,
                style: scoutText(
                  14,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                companyLine(company),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: scoutText(12, color: ScoutColors.featuredMuted),
              ),
            ],
          ),
        ),
        Container(
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: ScoutColors.gold(166.55, const Size(92, 22)),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              SvgPicture.asset(ScoutIcons.starSmall),
              Text(
                'FEATURED',
                style: scoutText(
                  11,
                  weight: FontWeight.w600,
                  color: AppColors.inkDeep,
                ).copyWith(letterSpacing: 0.44),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({required this.call});

  final OpenCallSummary call;

  @override
  Widget build(BuildContext context) {
    final location = callLocation(call);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _GlassPill(label: call.category.label),
        if (location.isNotEmpty)
          _GlassPill(label: location, icon: ScoutIcons.pinWhite),
        for (final tag in call.tags) _GlassPill(label: tag),
      ],
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.label, this.icon});

  final String label;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: ScoutColors.onDarkPill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (icon != null) ScoutSvg(icon!, box: 11),
          Text(
            label,
            style: scoutText(11, weight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.call});

  final OpenCallSummary call;

  @override
  Widget build(BuildContext context) {
    final avatars = call.applicantAvatarUrls.take(3).toList();
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 1,
          children: [
            Text(
              'Budget',
              style: scoutText(11, color: ScoutColors.featuredMuted),
            ),
            Text(
              formatBudget(call.budget),
              style: scoutText(
                17,
                weight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        // The design lets this group run right up to the budget.
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              if (avatars.isNotEmpty) _FacePile(urls: avatars),
              Flexible(
                child: Text(
                  '${call.applicantsCount} applied · '
                  '${formatDaysLeft(call.closesAt)} left',
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  style: scoutText(11, color: AppColors.onBrandSubtle),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Up to three applicant photos, each in a navy ring, overlapping by 8px.
class _FacePile extends StatelessWidget {
  const _FacePile({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26 + 18.0 * (urls.length - 1),
      height: 26,
      child: Stack(
        children: [
          for (final (i, url) in urls.indexed)
            Positioned(
              left: 18.0 * i,
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.brandGradStart,
                  shape: BoxShape.circle,
                ),
                child: StarAvatar(url, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedApplyButton extends StatelessWidget {
  const _FeaturedApplyButton({
    required this.status,
    required this.applying,
    required this.onApply,
  });

  final ApplicationStatus? status;
  final bool applying;
  final VoidCallback onApply;

  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final applied = status;
    if (applied != null && !applying) {
      return Container(
        height: 46,
        decoration: BoxDecoration(
          color: ScoutColors.onDarkPill,
          borderRadius: _radius,
          border: Border.all(color: ScoutColors.onDarkBorder),
        ),
        child: _ButtonLabel(
          icon: ScoutIcons.check,
          label: appliedLabel(applied),
          color: Colors.white,
        ),
      );
    }
    return Container(
      height: 46,
      decoration: BoxDecoration(
        gradient: ScoutColors.gold(171.53, const Size(309, 46)),
        borderRadius: _radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x47E7A91A),
            offset: Offset(0, 6),
            blurRadius: 9,
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: _radius,
          onTap: applying ? null : onApply,
          child: applying
              ? const _ButtonLabel(
                  label: 'Applying',
                  color: AppColors.inkDeep,
                  busy: true,
                )
              : const _ButtonLabel(
                  icon: ScoutIcons.send,
                  label: 'Apply now',
                  color: AppColors.inkDeep,
                ),
        ),
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.label,
    required this.color,
    this.icon,
    this.busy = false,
  });

  final String label;
  final Color color;
  final String? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        if (busy)
          ScoutSpinner(color: color)
        else if (icon != null)
          SvgPicture.asset(icon!),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: scoutText(15, weight: FontWeight.w600, color: color),
          ),
        ),
      ],
    );
  }
}

/// A marketplace row: company, Apply (or Applied), title and meta.
class OpenCallRow extends StatelessWidget {
  const OpenCallRow({
    super.key,
    required this.call,
    required this.status,
    required this.applying,
    required this.onTap,
    required this.onApply,
  });

  final OpenCallSummary call;
  final ApplicationStatus? status;
  final bool applying;
  final VoidCallback onTap;
  final VoidCallback onApply;

  static const _radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    final location = callLocation(call);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: _radius,
        border: Border.fromBorderSide(BorderSide(color: AppColors.borderField)),
        boxShadow: [ScoutColors.cardShadow],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: _radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    CompanyLogo(company: call.company, size: 40, radius: 11.2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          CompanyNameRow(
                            company: call.company,
                            badgeSize: 13,
                            style: scoutText(13, weight: FontWeight.w600),
                          ),
                          Text(
                            companyLine(call.company),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: scoutText(11, color: AppColors.textSubtle),
                          ),
                        ],
                      ),
                    ),
                    _RowApply(
                      applied: status != null && !applying,
                      applying: applying,
                      onApply: onApply,
                    ),
                  ],
                ),
                Text(
                  call.title,
                  style: scoutText(
                    15,
                    weight: FontWeight.w600,
                    height: 21 / 15,
                  ),
                ),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    if (location.isNotEmpty)
                      _MetaItem(icon: ScoutIcons.pin13, label: location),
                    _MetaItem(
                      icon: ScoutIcons.calendar13,
                      label: formatCloses(call.closesAt),
                    ),
                    _MetaItem(
                      icon: ScoutIcons.wallet13,
                      label: formatBudget(call.budget, withUnit: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RowApply extends StatelessWidget {
  const _RowApply({
    required this.applied,
    required this.applying,
    required this.onApply,
  });

  final bool applied;
  final bool applying;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    if (applied) {
      return Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.successTint,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            SvgPicture.asset(ScoutIcons.checkApplied),
            Text(
              'Applied',
              style: scoutText(
                12,
                weight: FontWeight.w600,
                color: ScoutColors.successText,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: 82,
      height: 32,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: applying ? null : onApply,
          child: Center(
            child: applying
                ? const ScoutSpinner(color: AppColors.brandBlue, size: 14)
                : Text(
                    'Apply',
                    maxLines: 1,
                    style: scoutText(
                      13,
                      weight: FontWeight.w600,
                      color: AppColors.brandBlue,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        ScoutSvg(icon, box: 13),
        Flexible(
          child: Text(label, style: scoutText(12, color: AppColors.textBody)),
        ),
      ],
    );
  }
}
