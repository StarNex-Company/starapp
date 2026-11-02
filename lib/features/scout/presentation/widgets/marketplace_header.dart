import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/scout/data/models/application.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// "Search roles, companies, cities" box.
class ScoutSearchField extends StatelessWidget {
  const ScoutSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: AppColors.borderField),
  );

  @override
  Widget build(BuildContext context) {
    final style = scoutText(15, height: 22 / 15);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: style,
      cursorColor: AppColors.brandBlue,
      decoration: InputDecoration(
        hintText: 'Search roles, companies, cities',
        hintStyle: style.copyWith(color: AppColors.textFaint),
        filled: true,
        fillColor: AppColors.closeButtonBg,
        isDense: true,
        constraints: const BoxConstraints(minHeight: 46),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 10),
          child: SvgPicture.asset(ScoutIcons.search),
        ),
        prefixIconConstraints: const BoxConstraints(minHeight: 18),
        enabledBorder: _border,
        border: _border,
        focusedBorder: _border.copyWith(
          borderSide: const BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
      ),
    );
  }
}

/// Open Calls / My Applications. Open Calls is this page; My Applications
/// opens its own page, so the bar always shows Open Calls selected here.
class ScoutSegments extends StatelessWidget {
  const ScoutSegments({
    super.key,
    required this.applicationsCount,
    required this.onApplications,
  });

  /// Hidden when null or zero.
  final int? applicationsCount;
  final VoidCallback onApplications;

  @override
  Widget build(BuildContext context) {
    final count = applicationsCount ?? 0;
    return StarTabBar(
      tabs: [
        const StarTab(label: 'Open Calls', icon: ScoutIcons.briefcaseSmall),
        StarTab(label: 'My Applications', count: count > 0 ? count : null),
      ],
      selected: 0,
      onSelected: (i) {
        if (i == 1) onApplications();
      },
    );
  }
}

/// "Your applications": sent, in review and shortlisted counts.
class ApplicationsSummaryCard extends StatelessWidget {
  const ApplicationsSummaryCard({
    super.key,
    required this.summary,
    required this.onViewAll,
  });

  final ApplicationsSummary summary;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderField),
        boxShadow: const [ScoutColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your applications',
                  style: scoutText(
                    15,
                    weight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
              Semantics(
                button: true,
                child: InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(6),
                  child: Text(
                    'View all',
                    style: scoutText(
                      13,
                      weight: FontWeight.w500,
                      color: AppColors.brandBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              _StatusTile(
                count: summary.sent,
                label: 'Sent',
                background: AppColors.closeButtonBg,
                color: AppColors.textSubtle,
              ),
              _StatusTile(
                count: summary.inReview,
                label: 'In review',
                background: ScoutColors.amberTint,
                color: ScoutColors.amberText,
              ),
              _StatusTile(
                count: summary.shortlisted,
                label: 'Shortlisted',
                background: AppColors.successTint,
                color: ScoutColors.successText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.count,
    required this.label,
    required this.background,
    required this.color,
  });

  final int count;
  final String label;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(
              '$count',
              style: scoutText(20, weight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: scoutText(12, weight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
