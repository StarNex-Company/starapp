import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

enum AppButtonVariant { filled, outlined, ghost }

/// General-purpose button used anywhere in the app.
///
/// ```dart
/// // Filled
/// AppButton(label: 'Submit', onPressed: _submit)
///
/// // Outlined
/// AppButton.outlined(label: 'Cancel', onPressed: _cancel)
///
/// // Text / ghost
/// AppButton.ghost(label: 'Forgot password?', onPressed: _reset)
///
/// // Icon only
/// AppButton.icon(icon: Icons.arrow_back, onPressed: _back)
///
/// // Filled with leading icon
/// AppButton(label: 'Next', onPressed: _next, leadingIcon: Icons.arrow_forward)
///
/// // Loading
/// AppButton(label: 'Submit', onPressed: _submit, isLoading: true)
/// ```
class AppButton extends StatelessWidget {
  // ── Filled ───────────────────────────────────────────────────────────────
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 54,
    this.leadingIcon,
    this.trailingIcon,
    this.borderRadius = 14,
  })  : variant = AppButtonVariant.filled,
        icon = null;

  // ── Outlined ─────────────────────────────────────────────────────────────
  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 54,
    this.leadingIcon,
    this.trailingIcon,
    this.borderRadius = 14,
  })  : variant = AppButtonVariant.outlined,
        icon = null;

  // ── Ghost / text ──────────────────────────────────────────────────────────
  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 44,
    this.leadingIcon,
    this.trailingIcon,
    this.borderRadius = 8,
  })  : variant = AppButtonVariant.ghost,
        icon = null;

  // ── Icon only ─────────────────────────────────────────────────────────────
  const AppButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.borderRadius = 12,
  })  : variant = AppButtonVariant.ghost,
        label = '',
        isFullWidth = false,
        height = 44,
        leadingIcon = null,
        trailingIcon = null;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double borderRadius;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Used only by [AppButton.icon] — renders a plain icon button.
  final IconData? icon;

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get _isIconOnly => icon != null;

  Color get _fgColor => variant == AppButtonVariant.filled
      ? Colors.white
      : AppColors.btnColor;

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
            strokeWidth: 2.5, color: _fgColor),
      );
    }

    if (_isIconOnly) {
      return Icon(icon, color: AppColors.btnColor);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 18),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius));
    final minSize = Size(isFullWidth ? double.infinity : 0, height);
    final callback = isLoading ? null : onPressed;

    // Icon-only → plain IconButton
    if (_isIconOnly) {
      return IconButton(
        onPressed: callback,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.btnColor),
              )
            : Icon(icon, color: AppColors.btnColor),
      );
    }

    Widget button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: callback,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.btnColor,
            foregroundColor: Colors.white,
            minimumSize: minSize,
            shape: shape,
            elevation: 0,
            disabledBackgroundColor: AppColors.btnColor.withAlpha(120),
          ),
          child: _buildChild(),
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: callback,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.btnColor,
            minimumSize: minSize,
            side: const BorderSide(color: AppColors.btnColor, width: 1.5),
            shape: shape,
          ),
          child: _buildChild(),
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: callback,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.btnColor,
            minimumSize: minSize,
            shape: shape,
          ),
          child: _buildChild(),
        ),
    };

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
