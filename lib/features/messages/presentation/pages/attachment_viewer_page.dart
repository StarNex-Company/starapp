import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/config/app_config.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/models/attachment.dart';
import 'package:starapp/features/messages/data/models/attachment_preview.dart';
import 'package:starapp/features/messages/data/provider/messages_providers.dart';
import 'package:starapp/features/messages/presentation/widgets/messages_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// A shared file (Figma "File — Gbedu Brief"): who sent it, its size, the
/// document's text, and Download, which hands the file to the system.
class AttachmentViewerPage extends ConsumerWidget {
  const AttachmentViewerPage({super.key, required this.attachmentId});

  final String attachmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = attachmentPreviewProvider(attachmentId);
    final preview = ref.watch(provider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: preview.value?.attachment.fileName ?? '',
        leading: StarIconButton.back(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.messages);
            }
          },
        ),
      ),
      body: StarAsyncView(
        value: preview,
        onRetry: () => ref.invalidate(provider),
        builder: (preview) => _Preview(
          preview: preview,
          onDownload: () => _download(context, ref, preview.attachment),
        ),
      ),
    );
  }

  /// Opens the file in the system's handler. Mock data has no real file, so
  /// it only confirms.
  static Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    Attachment attachment,
  ) async {
    final uri = Uri.tryParse(attachment.url);
    final real =
        !ref.read(appConfigProvider).useMockData &&
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http');
    if (!real) {
      showStarToast(context, 'Saved to your files');
      return;
    }
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      showStarToast(context, "Couldn't open this file. Please try again.");
    }
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.preview, required this.onDownload});

  final AttachmentPreview preview;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final a = preview.attachment;
    final pages = a.pageCount;
    final meta = [
      ?preview.ownerName,
      if (a.sizeBytes > 0) a.sizeLabel,
      if (pages != null) '$pages page${pages == 1 ? '' : 's'}',
    ].join(' · ');
    final title = preview.title;
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return ListView(
      padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            if (meta.isNotEmpty)
              Text(
                meta,
                style: messagesText(
                  14,
                  height: 22 / 14,
                  color: AppColors.authTextSecondary,
                ),
              ),
            if (title != null && title.isNotEmpty)
              Text(
                title,
                style: messagesText(
                  20,
                  height: 28 / 20,
                  weight: FontWeight.w700,
                ),
              ),
            if (a.kind == AttachmentKind.image)
              StarImage(
                a.url,
                borderRadius: BorderRadius.circular(16),
                fit: BoxFit.contain,
                semanticLabel: a.fileName,
              ),
            for (final section in preview.sections) ...[
              Text(
                section.heading,
                style: messagesText(
                  16,
                  height: 24 / 16,
                  weight: FontWeight.w700,
                ),
              ),
              Text(
                section.body,
                style: messagesText(
                  14,
                  height: 22 / 14,
                  color: MessagesColors.previewBody,
                ),
              ),
            ],
            StarPrimaryButton(
              label: switch (a.kind) {
                AttachmentKind.talentPassport => 'Open Talent Passport',
                _ when a.extension.isNotEmpty => 'Download ${a.extension}',
                _ => 'Download',
              },
              onPressed: onDownload,
            ),
          ],
        ),
      ],
    );
  }
}
