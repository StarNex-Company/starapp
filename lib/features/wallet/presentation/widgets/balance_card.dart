import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/wallet/data/models/wallet_summary.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';

const _radius = BorderRadius.all(Radius.circular(12));

/// The navy card at the top of the Wallet: available balance, its dollar
/// value, and the Withdraw / Statements buttons.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.summary,
    required this.onWithdraw,
    required this.onStatements,
  });

  final WalletSummary summary;

  /// Null disables Withdraw (nothing to withdraw).
  final VoidCallback? onWithdraw;
  final VoidCallback onStatements;

  @override
  Widget build(BuildContext context) {
    final usd = summary.approxUsd;
    final ago = formatAgo(summary.updatedAt);
    final updated = 'updated ${ago == 'Just now' ? 'just now' : ago}';

    return Container(
      constraints: const BoxConstraints(minHeight: 196),
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        gradient: LinearGradient(
          // 150° across the 345×196 card.
          begin: Alignment(-0.488, -1.512),
          end: Alignment(0.488, 1.512),
          colors: [
            AppColors.navyLight,
            AppColors.brandGradStart,
            AppColors.navyDeep,
          ],
          stops: [0, 0.6, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x47032886),
            offset: Offset(0, 12),
            blurRadius: 30,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -85,
            top: -110,
            child: SvgPicture.asset(WalletIcons.balanceGlow),
          ),
          Positioned(
            right: -15,
            top: 60,
            child: SvgPicture.asset(WalletIcons.balanceLogo),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Available balance',
                  style: TextStyle(
                    fontSize: 13,
                    height: walletLeading,
                    letterSpacing: 0,
                    color: WalletColors.balanceLabel,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    summary.available.format(decimals: true),
                    style: const TextStyle(
                      fontSize: 31,
                      height: walletLeading,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  usd == null
                      ? updated
                      : '≈ ${usd.format(decimals: true)} · $updated',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: walletLeading,
                    letterSpacing: 0,
                    color: WalletColors.balanceLabel,
                  ),
                ),
                const SizedBox(height: 36),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(child: _WithdrawButton(onPressed: onWithdraw)),
                    Expanded(child: _StatementsButton(onPressed: onStatements)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: _radius,
          gradient: LinearGradient(
            // 163° across the button.
            begin: Alignment(-0.163, -1.836),
            end: Alignment(0.163, 1.836),
            colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDeep],
            stops: [0, 0.45, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x47E7A91A),
              offset: Offset(0, 6),
              blurRadius: 9,
            ),
          ],
        ),
        child: _CardButton(
          icon: WalletIcons.arrowUpRightInk,
          label: 'Withdraw',
          color: AppColors.inkDeep,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _StatementsButton extends StatelessWidget {
  const _StatementsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: _radius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: _CardButton(
        icon: WalletIcons.fileWhite,
        label: 'Statements',
        color: Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: _radius,
        onTap: onPressed,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              SvgPicture.asset(icon),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    height: walletLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
