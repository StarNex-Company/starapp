import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/scout/data/models/company.dart';
import 'package:starapp/features/scout/data/provider/scout_providers.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_widgets.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Company Profile (Figma "Scout — Company Profile"): cover and logo, the
/// verification notice, facts, open roles, testimonials, and Message /
/// Follow. Sections without data are left out. Lives in the Messages tab,
/// with a full-screen mirror.
class CompanyPage extends ConsumerWidget {
  const CompanyPage({super.key, required this.companyId});

  final String companyId;

  Future<void> _toggleFollow(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(companyProvider(companyId).notifier);
    final following =
        ref.read(companyProvider(companyId)).value?.isFollowing ?? true;
    if (!following) showStarToast(context, 'Company followed');
    try {
      await notifier.toggleFollow();
    } catch (e) {
      if (context.mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(companyProvider(companyId));
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: company.value?.summary.name ?? '',
        leading: StarIconButton.back(
          onPressed: () => scoutBack(context, AppRoutes.scout),
        ),
      ),
      body: StarAsyncView(
        value: company,
        onRetry: () => ref.invalidate(companyProvider(companyId)),
        builder: (company) => ListView(
          padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
          children: [
            for (final child in _sections(context, ref, company)) ...[
              child,
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, WidgetRef ref, Company c) {
    final summary = c.summary;
    final rating = c.rating;
    final founded = c.foundedYear;

    return [
      _Hero(company: c),
      if (summary.isVerified)
        ScoutNotice(
          icon: ScoutIcons.shield,
          title: 'Verified company',
          body: c.verificationNote,
        ),
      ...withDividers([
        ScoutListRow(
          icon: ScoutIcons.briefcase,
          title: summary.type.isEmpty ? 'Company' : summary.type,
          subtitle: summary.locationLabel,
          value: founded == null ? null : 'Since $founded',
        ),
        ScoutListRow(
          icon: ScoutIcons.users,
          title: 'Creators hired on Star App',
          value: formatGrouped(c.creatorsHiredCount),
        ),
        if (rating != null)
          ScoutListRow(
            icon: ScoutIcons.star,
            title: 'Creator rating',
            subtitle:
                '${formatGrouped(c.reviewsCount)} '
                '${c.reviewsCount == 1 ? 'review' : 'reviews'}',
            value: '${rating.toStringAsFixed(1)} ★',
          ),
      ]),
      if (c.openRoles.isNotEmpty) ...[
        const ScoutSectionTitle('Open roles'),
        ...withDividers([
          for (final role in c.openRoles)
            ScoutListRow(
              key: ValueKey(role.id),
              icon: ScoutIcons.category(role.category),
              title: role.title,
              subtitle:
                  '${formatBudget(role.budget)} · closes in '
                  '${formatDaysLeft(role.closesAt)}',
              onTap: () => context.pushInTab(AppRoutes.scoutCall(role.id)),
            ),
        ]),
      ],
      if (c.testimonials.isNotEmpty) ...[
        const ScoutSectionTitle('What creators say'),
        for (final t in c.testimonials) _TestimonialText(testimonial: t),
      ],
      StarPrimaryButton(
        label: 'Message ${summary.name.split(' ').first}',
        onPressed: () =>
            context.pushInTab('${AppRoutes.newMessage}?to=${summary.id}'),
      ),
      StarOutlinedButton(
        label: c.isFollowing ? 'Following' : 'Follow company',
        onPressed: () => _toggleFollow(context, ref),
      ),
    ];
  }
}

/// Cover photo, the round logo overlapping it, name and reach.
class _Hero extends StatelessWidget {
  const _Hero({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final summary = company.summary;
    final reach = [
      '${formatCompact(company.followersCount)} '
          '${company.followersCount == 1 ? 'follower' : 'followers'}',
      if (company.artistsSignedCount > 0)
        '${formatGrouped(company.artistsSignedCount)} artists signed',
    ].join(' · ');
    final about = [
      summary.type,
      summary.locationLabel,
    ].where((p) => p.isNotEmpty).join(' · ');

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 250),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (company.coverUrl != null)
                        StarImage(company.coverUrl)
                      else
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: ScoutColors.logoGradient(
                              summary.id,
                              degrees: 166.3,
                              size: const Size(345, 150),
                            ),
                          ),
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00031A5E), Color(0x8C031A5E)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 112, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        Flexible(
                          child: Text(
                            summary.name,
                            style: scoutText(20, weight: FontWeight.w700),
                          ),
                        ),
                        if (summary.isVerified) const _VerifiedMark(),
                      ],
                    ),
                    Text(
                      [about, reach].where((p) => p.isNotEmpty).join('\n'),
                      style: scoutText(
                        13,
                        color: AppColors.authTextSecondary,
                        height: 19 / 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            top: 108,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x330A1440),
                    offset: Offset(0, 6),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CompanyLogo(company: summary, size: 84, border: 4),
            ),
          ),
        ],
      ),
    );
  }
}

/// The page's larger verified mark: a "✓" glyph on navy.
class _VerifiedMark extends StatelessWidget {
  const _VerifiedMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verified',
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.brandBlue,
          shape: BoxShape.circle,
        ),
        child: Text(
          '✓',
          style: scoutText(11, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

class _TestimonialText extends StatelessWidget {
  const _TestimonialText({required this.testimonial});

  final Testimonial testimonial;

  @override
  Widget build(BuildContext context) {
    final author = [
      ?testimonial.authorName,
      ?testimonial.authorTier?.label,
    ].join(', ');
    return Text(
      '"${testimonial.quote}"${author.isEmpty ? '' : ' ($author)'}',
      style: scoutText(14, height: 22 / 14),
    );
  }
}
