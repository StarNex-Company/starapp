import 'package:flutter/material.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_icons.dart';
import 'package:starapp/features/settings/presentation/widgets/settings_tile_row.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';

/// What the user picked in the Change Photo / Change Cover sheet.
enum MediaSheetAction { takePhoto, chooseFromGallery, remove }

/// Body of the "Profile photo" and "Cover photo" sheets: take a photo, choose
/// from gallery, or remove the current one. Pops with a [MediaSheetAction].
class EditProfileMediaSheet extends StatelessWidget {
  const EditProfileMediaSheet({
    super.key,
    required this.title,
    required this.removeLabel,
  });

  final String title;

  /// e.g. "Remove current photo".
  final String removeLabel;

  @override
  Widget build(BuildContext context) {
    void pick(MediaSheetAction action) => Navigator.of(context).pop(action);

    return StarSheet(
      title: title,
      children: [
        SettingsTileRow(
          icon: SettingsIcons.video,
          title: 'Take a photo',
          onTap: () => pick(MediaSheetAction.takePhoto),
        ),
        SettingsTileRow(
          icon: SettingsIcons.image,
          title: 'Choose from gallery',
          onTap: () => pick(MediaSheetAction.chooseFromGallery),
        ),
        SettingsTileRow(
          icon: SettingsIcons.trash,
          title: removeLabel,
          danger: true,
          onTap: () => pick(MediaSheetAction.remove),
        ),
      ],
    );
  }
}
