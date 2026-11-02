import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_assets.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_text.dart';

/// 14px auth checkbox (Figma "Check" `216:527` + "Warning" `238:939`).
///
/// * unchecked — 1.5px #000207 stroke, radius 4
/// * checked — filled #000207 with a #F7F7F8 tick
/// * warning — when [warning] turns `true` while unchecked, the box goes
///   1.5px #A3A3A3 straight away and, after 0.8s, 1.5px #B10003 (red) and
///   stays red until [warning] is cleared or the box is checked.
///
/// With [label] the whole row (box, 4px gap, label) toggles; the label gets a
/// 12 Regular #000207 default style, and `TextSpan` recognizers inside it
/// (e.g. "Terms") still win their own taps.
///
/// ```dart
/// AuthCheck(
///   value: _agreed,
///   warning: _showTermsWarning,          // set true when Continue is tapped unchecked
///   onChanged: (v) => setState(() {
///     _agreed = v;
///     _showTermsWarning = false;
///   }),
///   label: const Text('Remember me'),
/// )
/// ```
class AuthCheck extends StatefulWidget {
  const AuthCheck({
    super.key,
    required this.value,
    required this.onChanged,
    this.warning = false,
    this.label,
  });

  final bool value;

  /// Called with the new value. `null` disables the control.
  final ValueChanged<bool>? onChanged;

  /// Plays the grey → red warning while unchecked. Re-trigger the animation by
  /// setting it `false` and then `true` again.
  final bool warning;

  final Widget? label;

  /// Delay before the warning stroke turns red (from the prototype).
  static const warningDelay = Duration(milliseconds: 800);

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  Timer? _timer;
  bool _red = false;

  @override
  void initState() {
    super.initState();
    if (widget.warning) _startWarning();
  }

  @override
  void didUpdateWidget(AuthCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.warning && !oldWidget.warning) {
      _startWarning();
    } else if (!widget.warning && oldWidget.warning) {
      _timer?.cancel();
      _red = false;
    }
  }

  void _startWarning() {
    _timer?.cancel();
    _red = false;
    _timer = Timer(AuthCheck.warningDelay, () {
      if (mounted) setState(() => _red = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() => widget.onChanged?.call(!widget.value);

  @override
  Widget build(BuildContext context) {
    final Widget box;
    if (widget.value) {
      box = SvgPicture.asset(AuthAssets.checkOn, width: 14, height: 14);
    } else {
      final Color stroke = !widget.warning
          ? AppColors.voidBlack
          : (_red ? AppColors.authError : AppColors.authCheckIdle);
      box = AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: stroke, width: 1.5),
        ),
      );
    }

    final enabled = widget.onChanged != null;
    Widget content = SizedBox.square(dimension: 14, child: box);
    if (widget.label != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          const SizedBox(width: 4),
          Flexible(
            child: DefaultTextStyle.merge(
              style: AuthTextStyles.small,
              child: widget.label!,
            ),
          ),
        ],
      );
    }

    return Semantics(
      checked: widget.value,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _toggle : null,
          child: Opacity(opacity: enabled ? 1 : 0.5, child: content),
        ),
      ),
    );
  }
}
