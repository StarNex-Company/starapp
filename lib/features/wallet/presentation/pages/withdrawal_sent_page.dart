import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/wallet/data/provider/wallet_providers.dart';
import 'package:starapp/features/wallet/presentation/widgets/wallet_style.dart';
import 'package:starapp/shared/widgets/star_bottom_bar.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_success_hero.dart';

/// Wallet — Withdrawal Sent, full screen after a successful withdrawal.
/// Shows the amount and destination from this session's withdrawal when it
/// matches [reference], and refreshes the wallet so the new balance shows.
class WithdrawalSentPage extends ConsumerStatefulWidget {
  const WithdrawalSentPage({super.key, required this.reference});

  /// The withdrawal's reference, from `?ref=`.
  final String reference;

  @override
  ConsumerState<WithdrawalSentPage> createState() => _WithdrawalSentPageState();
}

class _WithdrawalSentPageState extends ConsumerState<WithdrawalSentPage> {
  @override
  void initState() {
    super.initState();
    // Providers can't be invalidated while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) invalidateWalletData(ref);
    });
  }

  void _backToWallet() => context.go(AppRoutes.wallet);

  @override
  Widget build(BuildContext context) {
    final receipt = ref.watch(withdrawalProvider);
    final match = receipt?.withdrawal.reference == widget.reference
        ? receipt
        : null;
    final message = match == null
        ? 'Your withdrawal is on its way to your bank.'
        : '${formatAmount(match.withdrawal.amount)} is heading to '
              '${match.withdrawal.destination.label}.'
              '${_arrival(match.arrivalEstimate)}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StarIconButton.close(onPressed: _backToWallet),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 29, 24, 24),
                  child: Column(
                    spacing: 16,
                    children: [
                      const _SentEmblem(),
                      const Text(
                        'Withdrawal on its way',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          height: walletLeading,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 310),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 22 / 15,
                            letterSpacing: 0,
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ),
                      if (widget.reference.isNotEmpty)
                        StarSuccessChip(
                          icon: WalletIcons.fileSmall,
                          label: 'Ref ${widget.reference}',
                          background: AppColors.brandTint,
                          foreground: AppColors.brandBlue,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: StarBottomBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              StarPrimaryButton(
                label: 'Back to Wallet',
                onPressed: _backToWallet,
              ),
              StarTextButton(
                label: 'Go Home',
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// " It usually arrives within minutes." from the quoted "Within minutes".
  static String _arrival(String estimate) {
    final text = estimate.trim();
    if (text.isEmpty) return '';
    final sentence = '${text[0].toLowerCase()}${text.substring(1)}';
    return ' It usually arrives $sentence.';
  }
}

/// The green disc with the arrow, its halo and sparkles; scales in once.
class _SentEmblem extends StatefulWidget {
  const _SentEmblem();

  @override
  State<_SentEmblem> createState() => _SentEmblemState();
}

class _SentEmblemState extends State<_SentEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _scaleCurve;
  late final Animation<double> _scale;
  late final CurvedAnimation _fade;

  static const _sparkles = 'assets/vectors/shared';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _scale = Tween<double>(begin: 0.7, end: 1).animate(_scaleCurve);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    _scaleCurve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget sparkle(String name, double left, double top, double size) =>
        Positioned(
          left: left,
          top: top,
          child: SvgPicture.asset(
            '$_sparkles/$name.svg',
            width: size,
            height: size,
          ),
        );

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 180,
          height: 160,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 10,
                top: 0,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        WalletColors.sentGlow.withValues(alpha: 0.45),
                        WalletColors.sentGlow.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 42,
                top: 32,
                child: Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        WalletColors.sentDiscStart,
                        WalletColors.sentGlow,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4D032886),
                        offset: Offset(0, 12),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(WalletIcons.sentArrow),
                ),
              ),
              sparkle('success_sparkle_gold_18', 14, 30, 18),
              sparkle('success_sparkle_navy_14', 150, 20, 14),
              sparkle('success_sparkle_gold_20', 160, 110, 20),
              sparkle('success_sparkle_navy_12', 6, 118, 12),
            ],
          ),
        ),
      ),
    );
  }
}
