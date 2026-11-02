import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

// Button label: 16 Regular, Inter's "normal" line height.
const _labelStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.21,
  letterSpacing: 0,
);

/// Size of an auth button.
///
/// * [regular] — 50 high, radius 13 (Welcome, Login, Register, Forgot…).
/// * [compact] — 45 high, radius 10 (OTP, Verify Email, onboarding,
///   Language selection, Interest, Profile Picture).
enum AuthButtonSize {
  regular(height: 50, radius: 13),
  compact(height: 45, radius: 10);

  const AuthButtonSize({required this.height, required this.radius});

  final double height;
  final double radius;
}

/// Filled navy-gradient button (Figma "Primary Button" `86:313`).
///
/// Gradient #00164D → #001F6E left → right, no shadow, 16 Regular #F7F7F8
/// label. Pressed shows the component's reversed-gradient variant.
/// `onPressed: null` disables it (40% opacity); `isLoading` swaps the label
/// for [AuthLoadingDots] and ignores taps.
///
/// Fills the available width; put it in an `Expanded` to sit side by side.
///
/// ```dart
/// AuthPrimaryButton(label: 'Log In', onPressed: _submit)
/// AuthPrimaryButton(label: 'Done', size: AuthButtonSize.compact, onPressed: _done)
/// AuthPrimaryButton(label: 'Send Code', isLoading: _sending, onPressed: _send)
/// ```
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AuthButtonSize.regular,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AuthButtonSize size;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return _AuthButtonBase(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      size: size,
      builder: (pressed) => _ButtonSkin(
        size: size,
        decoration: BoxDecoration(
          gradient: pressed
              ? AppColors.authButtonGradientPressed
              : AppColors.authButtonGradient,
          borderRadius: BorderRadius.circular(size.radius),
        ),
        foreground: AppColors.lunarWhite,
        label: label,
        isLoading: isLoading,
      ),
    );
  }
}

/// Outlined button (Figma "Secondary Button" `86:323`).
///
/// 1.5px gradient stroke (#00164D → #001F6E), transparent fill, 16 Regular
/// #001F6E label. Same sizes and states as [AuthPrimaryButton].
///
/// ```dart
/// AuthSecondaryButton(label: 'Log In', onPressed: () => context.go(AppRoutes.signIn))
/// ```
class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AuthButtonSize.regular,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AuthButtonSize size;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return _AuthButtonBase(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      size: size,
      builder: (pressed) => CustomPaint(
        foregroundPainter: _GradientStrokePainter(
          gradient: AppColors.authButtonGradient,
          radius: size.radius,
          strokeWidth: 1.5,
        ),
        child: _ButtonSkin(
          size: size,
          decoration: BoxDecoration(
            color: pressed
                ? AppColors.brandNavy.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(size.radius),
          ),
          foreground: AppColors.brandNavy,
          label: label,
          isLoading: isLoading,
        ),
      ),
    );
  }
}

/// Shared tap / disabled / semantics handling for the auth buttons.
class _AuthButtonBase extends StatefulWidget {
  const _AuthButtonBase({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.size,
    required this.builder,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AuthButtonSize size;
  final Widget Function(bool pressed) builder;

  @override
  State<_AuthButtonBase> createState() => _AuthButtonBaseState();
}

class _AuthButtonBaseState extends State<_AuthButtonBase> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(_AuthButtonBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null && !widget.isLoading;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      excludeSemantics: true,
      onTap: _enabled ? widget.onPressed : null,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: _enabled ? () => _setPressed(false) : null,
          onTap: _enabled ? widget.onPressed : null,
          child: AnimatedOpacity(
            opacity: disabled ? 0.4 : 1,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              width: double.infinity,
              height: widget.size.height,
              child: widget.builder(_pressed),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonSkin extends StatelessWidget {
  const _ButtonSkin({
    required this.size,
    required this.decoration,
    required this.foreground,
    required this.label,
    required this.isLoading,
  });

  final AuthButtonSize size;
  final BoxDecoration decoration;
  final Color foreground;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: decoration,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isLoading
          ? AuthLoadingDots(color: foreground)
          : Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: _labelStyle.copyWith(color: foreground),
            ),
    );
  }
}

/// Paints a gradient stroke inside the bounds (like a Figma inside stroke).
class _GradientStrokePainter extends CustomPainter {
  const _GradientStrokePainter({
    required this.gradient,
    required this.radius,
    required this.strokeWidth,
  });

  final Gradient gradient;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final half = strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(half),
      Radius.circular(math.max(0, radius - half)),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_GradientStrokePainter old) =>
      old.gradient != gradient ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}

/// Four-dot loading indicator (Figma "Loading Bar" `86:268`): 7px dots,
/// the active one stretches to 7×13 and the highlight travels left → right.
/// 46×13. Defaults to the design's #032886; buttons pass their label colour.
class AuthLoadingDots extends StatefulWidget {
  const AuthLoadingDots({super.key, this.color = AppColors.brandBlue});

  final Color color;

  @override
  State<AuthLoadingDots> createState() => _AuthLoadingDotsState();
}

class _AuthLoadingDotsState extends State<AuthLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // The prototype steps the active dot every 0.32s: four steps per cycle.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1280),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: SizedBox(
        width: 46,
        height: 13,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // Continuous position of the highlight across the 4 dots.
            final pos = _controller.value * 4;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) {
                var d = (pos - i).abs();
                d = math.min(d, 4 - d); // wrap around
                final t = (1 - d).clamp(0.0, 1.0);
                return Container(
                  width: 7,
                  height: 7 + 6 * Curves.easeInOut.transform(t),
                  decoration: ShapeDecoration(
                    color: widget.color,
                    shape: const OvalBorder(),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
