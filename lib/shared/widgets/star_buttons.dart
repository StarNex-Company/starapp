import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';

// 48px action buttons from the STAR-APP design.
//
// They fill the available width by default; inside a Row wrap them in
// Expanded (or pass [width]).

const _labelStyle = TextStyle(
  fontSize: 15,
  height: 1.2,
  letterSpacing: 0,
  fontWeight: FontWeight.w600,
);
const _radius = BorderRadius.all(Radius.circular(12));

/// Navy gradient call-to-action, e.g. "Continue", "Submit Entry".
class StarPrimaryButton extends StatelessWidget {
  const StarPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;

  /// SVG asset paths, drawn at 18px.
  final String? leadingIcon;
  final String? trailingIcon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Container(
        width: width ?? double.infinity,
        height: 48,
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: _radius,
          boxShadow: [
            BoxShadow(color: Color(0x2E032886), offset: Offset(0, 6), blurRadius: 8),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: _radius,
            onTap: onPressed,
            child: _ButtonContent(
              label: label,
              color: Colors.white,
              leadingIcon: leadingIcon,
              trailingIcon: trailingIcon,
            ),
          ),
        ),
      ),
    );
  }
}

/// White button with a 1.5px brand outline, e.g. "Save draft", "Keep browsing".
class StarOutlinedButton extends StatelessWidget {
  const StarOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? leadingIcon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: _radius,
          side: BorderSide(color: AppColors.brandBlue, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: _ButtonContent(
            label: label,
            color: AppColors.brandBlue,
            leadingIcon: leadingIcon,
          ),
        ),
      ),
    );
  }
}

/// Borderless 40px link-style button, e.g. "Back to Home".
class StarTextButton extends StatelessWidget {
  const StarTextButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: _radius,
          onTap: onPressed,
          child: _ButtonContent(label: label, color: AppColors.brandBlue),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.color,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final Color color;
  final String? leadingIcon;
  final String? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        if (leadingIcon != null) SvgPicture.asset(leadingIcon!, width: 18, height: 18),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _labelStyle.copyWith(color: color),
          ),
        ),
        if (trailingIcon != null) SvgPicture.asset(trailingIcon!, width: 18, height: 18),
      ],
    );
  }
}
