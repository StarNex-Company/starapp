import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/features/profile/presentation/widgets/passport_card.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';

/// Sticky footer: the passport link (tap to copy) and "Share Link". Pads
/// itself above whatever sits at the bottom (home indicator or tab bar).
class PassportBottomBar extends StatelessWidget {
  const PassportBottomBar({
    super.key,
    required this.link,
    required this.onCopy,
    required this.onShare,
  });

  final String link;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final bottom = math.max(MediaQuery.paddingOf(context).bottom, 14.0);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: InsightsColors.softShadow,
            offset: Offset(0, -6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 14, 24, bottom),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              flex: 170,
              child: _LinkButton(link: link, onTap: onCopy),
            ),
            Expanded(
              flex: 163,
              child: StarPrimaryButton(
                label: 'Share Link',
                leadingIcon: PassportIcons.shareWhite,
                onPressed: onShare,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({required this.link, required this.onTap});

  final String link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Copy $link',
      excludeSemantics: true,
      child: Material(
        color: AppColors.closeButtonBg,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                spacing: 8,
                children: [
                  SvgPicture.asset(PassportIcons.link, width: 16, height: 16),
                  Expanded(
                    child: Text(
                      link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: insightsLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBody,
                      ),
                    ),
                  ),
                  SvgPicture.asset(PassportIcons.copy, width: 16, height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
