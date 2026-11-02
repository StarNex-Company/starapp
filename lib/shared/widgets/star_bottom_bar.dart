import 'dart:math' as math;

import 'package:flutter/material.dart';

/// White action bar pinned to the bottom of a screen, with a soft upward
/// shadow. Use as `Scaffold.bottomNavigationBar`.
///
/// ```dart
/// StarBottomBar(
///   child: Column(mainAxisSize: MainAxisSize.min, spacing: 6, children: [
///     StarPrimaryButton(label: 'View Challenge', onPressed: ...),
///     StarTextButton(label: 'Back to Home', onPressed: ...),
///   ]),
/// )
/// ```
class StarBottomBar extends StatelessWidget {
  const StarBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Design reserves 34px for the iPhone home indicator.
    final bottom = math.max(MediaQuery.viewPaddingOf(context).bottom, 16.0);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x140B1020), offset: Offset(0, -6), blurRadius: 12),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 14, 24, bottom),
        child: child,
      ),
    );
  }
}
