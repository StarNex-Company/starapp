import 'package:flutter/material.dart';

/// Full-bleed camera viewfinder.
///
/// Currently shows a still [placeholder] photo; to be replaced by a live
/// camera preview once a camera plugin is added. Keep the same full-bleed
/// "cover" sizing so the camera page overlays line up.
class CameraViewfinder extends StatelessWidget {
  const CameraViewfinder({super.key, required this.placeholder});

  final ImageProvider placeholder;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: placeholder,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      excludeFromSemantics: true,
    );
  }
}
