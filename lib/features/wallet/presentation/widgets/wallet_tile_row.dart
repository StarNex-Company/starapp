import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';

/// Row with a 40px navy icon tile, a title and optional caption, and a grey
/// value before an optional chevron (All activity, Transaction, Statements,
/// Payments & payouts).
class WalletTileRow extends StatelessWidget {
  const WalletTileRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.chevron = true,
  });

  /// SVG asset, drawn at its own size (20px).
  final String icon;
  final String title;
  final String? subtitle;

  /// Grey text before the chevron, e.g. "+₦900,000", "PDF".
  final String? value;

  /// Replaces the value and chevron, e.g. a [WalletToggle].
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Shown only for rows that open something.
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            spacing: 12,
            children: [
              WalletIconTile(icon: icon),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: walletLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: walletLeading,
                          letterSpacing: 0,
                          color: AppColors.textSubtle,
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      if (value != null)
                        ConstrainedBox(
                          // Leaves the title room at large text sizes.
                          constraints: const BoxConstraints(maxWidth: 170),
                          child: Text(
                            value!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              height: walletLeading,
                              letterSpacing: 0,
                              color: AppColors.textSubtle,
                            ),
                          ),
                        ),
                      if (chevron) SvgPicture.asset(WalletIcons.chevron),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 40px brand-tint square with a 20px navy icon.
class WalletIconTile extends StatelessWidget {
  const WalletIconTile({super.key, required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.brandTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(icon),
    );
  }
}

/// 1px hairline between rows.
class WalletDivider extends StatelessWidget {
  const WalletDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.borderField,
      child: SizedBox(height: 1, width: double.infinity),
    );
  }
}

/// 18px navy section heading, e.g. "October", "Payout methods".
class WalletSectionTitle extends StatelessWidget {
  const WalletSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        height: walletLeading,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: AppColors.brandBlue,
      ),
    );
  }
}

/// Grey intro paragraph at the top of a page (Statements, Add payout method).
class WalletIntro extends StatelessWidget {
  const WalletIntro(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 22 / 14,
        letterSpacing: 0,
        color: AppColors.authTextSecondary,
      ),
    );
  }
}

/// Centred icon, title and line for a list with nothing in it yet.
class WalletEmptyState extends StatelessWidget {
  const WalletEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final String icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        spacing: 8,
        children: [
          WalletIconTile(icon: icon),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: walletLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0,
              color: AppColors.textSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
