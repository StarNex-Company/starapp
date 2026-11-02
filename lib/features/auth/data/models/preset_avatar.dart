import 'dart:ui' show Rect;

import 'package:starapp/core/utils/json.dart';

/// A preset profile avatar (`GET /avatars/presets`) and how the design crops
/// it ("Profile Selection" `258:859` / `279:1174`): each rect is the image's
/// fill box relative to the circle (Figma CROP fills), for the 45px
/// thumbnail and for the 172px photo. Without crops the image fills the
/// circle.
class PresetAvatar {
  const PresetAvatar({
    required this.imageUrl,
    required this.label,
    this.thumb = _fill,
    this.photo = _fill,
  });

  factory PresetAvatar.fromJson(Json json) => PresetAvatar(
    imageUrl: json['imageUrl'] as String,
    label: json['label'] as String? ?? '',
    thumb: _readRect(json['thumb']),
    photo: _readRect(json['photo']),
  );

  static const _fill = Rect.fromLTWH(0, 0, 1, 1);

  /// The image; also identifies the avatar in the registration.
  final String imageUrl;

  /// Accessibility label ("No photo", "Avatar 1"…).
  final String label;
  final Rect thumb;
  final Rect photo;

  Json toJson() => {
    'imageUrl': imageUrl,
    'label': label,
    'thumb': _rectJson(thumb),
    'photo': _rectJson(photo),
  };

  /// `{"left", "top", "width", "height"}` as fractions of the circle.
  static Rect _readRect(Object? json) => json is Map
      ? Rect.fromLTWH(
          readDouble(json['left']),
          readDouble(json['top']),
          readDouble(json['width'], 1),
          readDouble(json['height'], 1),
        )
      : _fill;

  static Json _rectJson(Rect rect) => {
    'left': rect.left,
    'top': rect.top,
    'width': rect.width,
    'height': rect.height,
  };
}
