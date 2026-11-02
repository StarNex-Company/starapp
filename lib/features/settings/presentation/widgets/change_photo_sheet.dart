import 'package:flutter/material.dart';
import 'package:starapp/features/settings/presentation/widgets/edit_profile_media_sheet.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';

/// Figma "Sheet — Change Photo". Completes with the chosen action, or null
/// when dismissed.
Future<MediaSheetAction?> showChangePhotoSheet(BuildContext context) {
  return showStarSheet<MediaSheetAction>(
    context: context,
    builder: (_) => const EditProfileMediaSheet(
      title: 'Profile photo',
      removeLabel: 'Remove current photo',
    ),
  );
}
