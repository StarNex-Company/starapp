import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';

// Inter's "normal" line height, so text boxes match the design.
const _leading = 1.21;

/// Slides a [StarSheet] up over the current screen with the design's scrim.
/// Pop the sheet's own context with a result to return it.
Future<T?> showStarSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: AppColors.scrim,
    builder: builder,
  );
}

/// White rounded sheet with a grab handle, a title row with a close button,
/// and [children] stacked [spacing] apart. Scrolls when taller than the screen.
///
/// ```dart
/// showStarSheet<void>(
///   context: context,
///   builder: (_) => StarSheet(
///     title: 'Challenge rules',
///     subtitle: 'Afro-Beats Producer & Vocal Clash',
///     children: [...rows, StarPrimaryButton(label: 'Got it', onPressed: ...)],
///   ),
/// );
/// ```
class StarSheet extends StatelessWidget {
  const StarSheet({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.onClose,
    this.spacing = 18,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Defaults to popping the sheet.
  final VoidCallback? onClose;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 40.0);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Color(0x2E0B1020), offset: Offset(0, -10), blurRadius: 20),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 12, 24, bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderMuted,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            _SheetHead(
              title: title,
              subtitle: subtitle,
              onClose: onClose ?? () => Navigator.of(context).pop(),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SheetHead extends StatelessWidget {
  const _SheetHead({required this.title, required this.onClose, this.subtitle});

  final String title;
  final String? subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                style: const TextStyle(
                  height: _leading,
                  letterSpacing: 0,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: _leading,
                    letterSpacing: 0,
                    fontSize: 13,
                    color: AppColors.textSubtle,
                  ),
                ),
            ],
          ),
        ),
        StarIconButton.close(onPressed: onClose),
      ],
    );
  }
}
