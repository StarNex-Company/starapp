import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_toast.dart';
import 'package:url_launcher/url_launcher.dart';

const _dir = 'assets/vectors/shared';
const _labelInk = Color(0xFF3A4255); // text/body/3a4255
const _whatsAppTint = Color(0xFFDCFCE7); // surface/brand-tint/dcfce7
const _instagramTint = Color(0xFFFCE7F3); // surface/tint/fce7f3

/// Opens the design's Share sheet: Copy link, WhatsApp, Instagram, X and
/// More targets above a copyable link row.
///
/// Copying (the first target or the link row) puts `https://[link]` on the
/// clipboard and shows "Link copied to clipboard". WhatsApp and X open their
/// share links; Instagram and More open the system share sheet (Instagram
/// has no link-share intent). The sheet closes first, then [onShared] runs
/// once a target has been used, e.g. to count the share.
///
/// [link] defaults to the signed-in user's profile link.
///
/// ```dart
/// showStarShareSheet(context); // your profile link, as designed
/// showStarShareSheet(
///   context,
///   title: 'Share challenge',
///   link: 'starapp.io/c/afro-beats-clash',
///   linkCaption: 'Challenge link',
/// );
/// ```
Future<void> showStarShareSheet(
  BuildContext context, {
  String? title,
  String? subtitle,
  String? link,
  String linkCaption = 'Your public profile link',
  VoidCallback? onShared,
}) {
  final handle = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(currentUserProvider).value?.handle;
  final shownLink = link ?? 'starapp.io/@${handle ?? ''}';
  final url = 'https://$shownLink';

  return showStarSheet<void>(
    context: context,
    builder: (sheetContext) {
      void copy() {
        unawaited(Clipboard.setData(ClipboardData(text: url)));
        Navigator.of(sheetContext).pop();
        if (context.mounted) showStarToast(context, 'Link copied to clipboard');
        onShared?.call();
      }

      void open(_ShareTarget target) {
        Navigator.of(sheetContext).pop();
        unawaited(
          _share(target, url, title).then((ok) {
            if (ok) {
              onShared?.call();
            } else if (context.mounted) {
              showStarToast(context, "Couldn't open sharing on this device");
            }
          }),
        );
      }

      void whatsApp() => open(_ShareTarget.whatsApp);
      void x() => open(_ShareTarget.x);
      void system() => open(_ShareTarget.system);

      return StarSheet(
        title: title ?? 'Share',
        subtitle: subtitle ?? 'Send it to friends, fans and scouts',
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Target(
                label: 'Copy link',
                icon: '$_dir/share_copy.svg',
                tint: AppColors.brandTint,
                onTap: copy,
              ),
              _Target(
                label: 'WhatsApp',
                icon: '$_dir/share_whatsapp.svg',
                tint: _whatsAppTint,
                onTap: whatsApp,
              ),
              _Target(
                label: 'Instagram',
                icon: '$_dir/share_instagram.svg',
                tint: _instagramTint,
                onTap: system,
              ),
              _Target(
                label: 'X',
                icon: '$_dir/share_x.svg',
                tint: AppColors.track,
                onTap: x,
              ),
              _Target(
                label: 'More',
                icon: '$_dir/share_more.svg',
                tint: AppColors.closeButtonBg,
                onTap: system,
              ),
            ],
          ),
          _LinkRow(link: shownLink, caption: linkCaption, onTap: copy),
        ],
      );
    },
  );
}

enum _ShareTarget { whatsApp, x, system }

/// Opens [target] with [url]; false when nothing could handle it.
Future<bool> _share(_ShareTarget target, String url, String? title) async {
  try {
    final intent = switch (target) {
      _ShareTarget.whatsApp =>
        'https://wa.me/?text=${Uri.encodeComponent(url)}',
      _ShareTarget.x =>
        'https://x.com/intent/post?url=${Uri.encodeComponent(url)}',
      _ShareTarget.system => null,
    };
    if (intent != null &&
        await launchUrl(
          Uri.parse(intent),
          mode: LaunchMode.externalApplication,
        )) {
      return true;
    }
    final result = await SharePlus.instance.share(
      ShareParams(text: url, subject: title),
    );
    return result.status == ShareResultStatus.success;
  } on Exception {
    // No plugin (tests, unsupported platform) or no app to handle it.
    return false;
  }
}

class _Target extends StatelessWidget {
  const _Target({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final String icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 64,
          child: Column(
            spacing: 8,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: SvgPicture.asset(icon, width: 24, height: 24),
              ),
              Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.21,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  color: _labelInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.link,
    required this.caption,
    required this.onTap,
  });

  final String link;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Copy $link',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  '$_dir/share_link.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              Flexible(
                child: SizedBox(
                  width: 201,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        link,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.21,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.21,
                          letterSpacing: 0,
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  const Text(
                    'Copy',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.21,
                      letterSpacing: 0,
                      color: AppColors.textSubtle,
                    ),
                  ),
                  SvgPicture.asset(
                    '$_dir/share_chevron.svg',
                    width: 18,
                    height: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
