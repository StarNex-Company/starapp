import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/models/company_summary.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// A company's logo, or its initials on a gradient when it has none.
class CompanyLogo extends StatelessWidget {
  const CompanyLogo({
    super.key,
    required this.company,
    required this.size,
    this.radius,
    this.border = 0,
  });

  final CompanySummary company;
  final double size;

  /// Corner radius; null for a circle.
  final double? radius;

  /// White ring drawn inside [size], as on the company page and request.
  final double border;

  @override
  Widget build(BuildContext context) {
    final shape = radius == null
        ? const CircleBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius!))
              as ShapeBorder;
    final logo = company.logoUrl;
    final inner = size - border * 2;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(border),
      decoration: ShapeDecoration(color: Colors.white, shape: shape),
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: radius == null
              ? const CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    (radius! - border).clamp(0, radius!),
                  ),
                ),
        ),
        child: logo != null && logo.isNotEmpty
            ? StarImage(logo, width: inner, height: inner)
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: ScoutColors.logoGradient(company.id),
                ),
                child: Center(
                  child: Text(
                    company.initials,
                    maxLines: 1,
                    style: scoutText(
                      // The design sets initials at 36% of the logo.
                      inner * 0.36,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Navy circle with a white check beside a verified company's name.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, required this.size});

  /// 13, 14 or 18, matching the design's three badges.
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = switch (size) {
      <= 13 => ScoutIcons.verified13,
      <= 14 => ScoutIcons.verified14,
      _ => ScoutIcons.verified18,
    };
    return Semantics(
      label: 'Verified',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.brandBlue,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(icon),
      ),
    );
  }
}

/// A company's name with its verified badge; the name shrinks first.
class CompanyNameRow extends StatelessWidget {
  const CompanyNameRow({
    super.key,
    required this.company,
    required this.style,
    required this.badgeSize,
    this.gap = 5,
  });

  final CompanySummary company;
  final TextStyle style;
  final double badgeSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: gap,
      children: [
        Flexible(
          child: Text(
            company.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        if (company.isVerified) VerifiedBadge(size: badgeSize),
      ],
    );
  }
}

/// 40px brand-tint square holding a 20px icon.
class ScoutIconTile extends StatelessWidget {
  const ScoutIconTile({
    super.key,
    required this.icon,
    this.background = AppColors.brandTint,
    this.iconBox = 20,
  });

  final String icon;
  final Color background;
  final double iconBox;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ScoutSvg(icon, box: iconBox),
    );
  }
}

/// Icon tile, title and subtitle, with an optional value and chevron on the
/// right. Tappable when [onTap] is set; the chevron shows only then.
class ScoutListRow extends StatelessWidget {
  const ScoutListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          ScoutIconTile(icon: icon),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: scoutText(15, weight: FontWeight.w500),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: scoutText(12, color: AppColors.textSubtle),
                  ),
              ],
            ),
          ),
          if (value != null || onTap != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                if (value != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      value!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: scoutText(13, color: AppColors.textSubtle),
                    ),
                  ),
                if (onTap != null) SvgPicture.asset(ScoutIcons.chevron),
              ],
            ),
        ],
      ),
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: row,
      ),
    );
  }
}

/// 1px rule between list rows.
class ScoutDivider extends StatelessWidget {
  const ScoutDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.borderField,
      child: SizedBox(height: 1, width: double.infinity),
    );
  }
}

/// [children] with a [ScoutDivider] between each pair.
List<Widget> withDividers(Iterable<Widget> children) => [
  for (final (i, child) in children.indexed) ...[
    if (i > 0) const ScoutDivider(),
    child,
  ],
];

/// Navy 18px heading: "About the role", "Open roles", "Active".
class ScoutSectionTitle extends StatelessWidget {
  const ScoutSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: scoutText(
          18,
          weight: FontWeight.w600,
          color: AppColors.brandBlue,
        ),
      ),
    );
  }
}

/// Tinted card with an icon, a bold line and a note: "Verified company",
/// "Stay safe", the Stars bonus.
class ScoutNotice extends StatelessWidget {
  const ScoutNotice({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.background = AppColors.brandTint,
    this.titleColor = AppColors.brandBlue,
    this.onTap,
  });

  final String icon;
  final String title;
  final String body;
  final Color background;
  final Color titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                ScoutSvg(icon, box: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        title,
                        style: scoutText(
                          14,
                          weight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      if (body.isNotEmpty)
                        Text(
                          body,
                          style: scoutText(
                            12.5,
                            color: AppColors.textBody,
                            height: 18 / 12.5,
                          ),
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

/// A Scout filter pill; the app's shared [StarPill].
class ScoutChip extends StatelessWidget {
  const ScoutChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      StarPill(label: label, selected: selected, onTap: onTap);
}

/// The design's 48×22 switch: filled navy when on, outlined when off.
class ScoutToggle extends StatelessWidget {
  const ScoutToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppColors.brandNavy : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: value
                  ? null
                  : Border.all(color: AppColors.brandNavy, width: 1.5),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: value ? 4 : 2.5),
                child: Container(
                  width: 25,
                  height: 16,
                  decoration: BoxDecoration(
                    color: value ? Colors.white : ScoutColors.knobOff,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small progress ring for buttons that are waiting on the server.
class ScoutSpinner extends StatelessWidget {
  const ScoutSpinner({super.key, required this.color, this.size = 16});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}

/// The page's loading-more footer.
class ScoutLoadingMore extends StatelessWidget {
  const ScoutLoadingMore({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: ScoutSpinner(color: AppColors.brandNavy, size: 22)),
    );
  }
}

/// Centered grey line for empty lists.
class ScoutEmptyState extends StatelessWidget {
  const ScoutEmptyState(this.message, {super.key, this.action});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        spacing: 8,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: scoutText(14, color: AppColors.textSubtle),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Pops back, or goes to [fallback] when the page was opened directly.
void scoutBack(BuildContext context, String fallback) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}
