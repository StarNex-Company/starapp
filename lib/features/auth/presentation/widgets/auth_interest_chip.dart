import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Toggle pill of the Interest screen (Figma "Interest Selection" `347:1823`).
///
/// 23 high, fully rounded, 10px sides, 12px icon + 2px gap + 12 Regular label.
/// * selected — #001F6E fill, ✓ icon, #F7F7F8 label;
/// * unselected — white @ 46% fill, 1px #59606D border, ✕ icon, #000207 label.
///
/// ```dart
/// AuthInterestChip(
///   label: 'Singing',
///   selected: _selected.contains('Singing'),
///   onTap: () => _toggle('Singing'),
/// )
/// ```
class AuthInterestChip extends StatelessWidget {
  const AuthInterestChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  static const String iconOn = 'assets/vectors/auth_interest_on.svg';
  static const String iconOff = 'assets/vectors/auth_interest_off.svg';

  static const double height = 23;

  /// Unselected fill: white @ 46%.
  static const Color _idleFill = Color(0x75FFFFFF);

  static const TextStyle _label = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.21,
    letterSpacing: 0,
  );

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    final duration = animate
        ? const Duration(milliseconds: 150)
        : Duration.zero;
    final radius = BorderRadius.circular(height / 2);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: duration,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.brandNavy : _idleFill,
              borderRadius: radius,
            ),
            // Inside stroke that doesn't change the pill's size.
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : AppColors.authTextSecondary,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                SvgPicture.asset(
                  selected ? iconOn : iconOff,
                  width: 12,
                  height: 12,
                ),
                Text(
                  label,
                  maxLines: 1,
                  style: _label.copyWith(
                    color: selected
                        ? AppColors.lunarWhite
                        : AppColors.voidBlack,
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
