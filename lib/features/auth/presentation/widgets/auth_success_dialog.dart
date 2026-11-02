import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/auth_buttons.dart';

/// 85px green check-circle (Figma `icon-park-solid:check-one`).
const _successIcon = 'assets/vectors/auth_success_check.svg';

/// Card border (surface/brand-tint #DEE6FB).
const _cardBorder = AppColors.authChipBg;

/// Shows the auth "Success Card" (Figma `590:1887`) over a dimmed screen:
/// green check, [title], centred [message] and a primary [actionLabel]
/// button. The button closes the dialog, then calls [onAction]. The dialog
/// can only be left through that button (no barrier tap / back).
///
/// ```dart
/// await showAuthSuccessDialog(
///   context,
///   title: 'Password Updated',
///   message: 'Your password has been successfully changed. …',
///   actionLabel: 'Continue to Login',
///   onAction: () => context.go(AppRoutes.signIn),
/// );
/// ```
Future<void> showAuthSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: title,
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, _) => PopScope(
      canPop: false,
      child: AuthSuccessCard(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: () {
          Navigator.of(dialogContext).pop();
          onAction();
        },
      ),
    ),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// The card itself, centred with 25px side margins (343 wide on a 393
/// screen): #F7F7F8, 2px #DEE6FB border, radius 10, 30/20 padding; 85px
/// check, 10px, title 21 SemiBold + body 11 Regular (3px apart), 20px, a
/// 45-high primary button (radius 13).
class AuthSuccessCard extends StatelessWidget {
  const AuthSuccessCard({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  static const _titleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1.21,
    letterSpacing: 0,
    color: AppColors.voidBlack,
  );

  static const _messageStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 18 / 11,
    letterSpacing: 0,
    color: AppColors.authTextSecondary,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 343),
          child: Material(
            type: MaterialType.transparency,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.lunarWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _cardBorder, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The exported vector is the 72.83px mask group inside
                    // the 85px icon frame.
                    Center(
                      child: SizedBox.square(
                        dimension: 85,
                        child: Center(
                          child: SvgPicture.asset(
                            _successIcon,
                            width: 72.8334,
                            height: 72.8334,
                            semanticsLabel: 'Success',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 67),
                      // The design's message box is 293 wide; Flutter's
                      // Inter runs slightly wider than Figma's, so the
                      // (centred) text gets the full 303 to wrap the same.
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: _titleStyle,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: _messageStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Regular button skin (radius 13) at the card's 45px.
                    SizedBox(
                      height: 45,
                      child: AuthPrimaryButton(
                        label: actionLabel,
                        onPressed: onAction,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
