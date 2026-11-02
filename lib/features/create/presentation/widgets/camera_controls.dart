import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/create/presentation/widgets/camera_icons.dart';

const _soundPillFill = Color(0x1AFFFFFF); // rgba(255,255,255,0.1), no token

/// Frosted dark circle used for every icon control on the camera screen.
class CameraGlassButton extends StatelessWidget {
  const CameraGlassButton({
    super.key,
    required this.size,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
  });

  final double size;
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Material(
            color: AppColors.glass,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: size,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 44px glass button with a caption underneath, for the right tools column.
class CameraToolButton extends StatelessWidget {
  const CameraToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// SVG asset path (20px icon).
  final String icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CameraGlassButton(
            size: 44,
            onPressed: onPressed,
            child: SvgPicture.asset(icon),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              height: 1.2,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Translucent "Add sound" pill at the top of the viewfinder.
class CameraAddSoundPill extends StatelessWidget {
  const CameraAddSoundPill({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _soundPillFill,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(CameraIcons.music),
              const SizedBox(width: 6),
              const Text(
                'Add sound',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.2,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded thumbnail of the latest gallery item; opens the gallery picker.
class CameraGalleryButton extends StatelessWidget {
  const CameraGalleryButton({
    super.key,
    required this.thumbnail,
    required this.onPressed,
  });

  /// Empty until the latest item has loaded.
  final ImageProvider? thumbnail;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final thumbnail = this.thumbnail;
    return Semantics(
      button: true,
      label: 'Open gallery',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: thumbnail == null
                ? null
                : Image(
                    image: thumbnail,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
          ),
        ),
      ),
    );
  }
}

/// 86px shutter: a red dot when idle, a red stop square while recording.
class CameraRecordButton extends StatelessWidget {
  const CameraRecordButton({
    super.key,
    required this.recording,
    required this.onPressed,
  });

  final bool recording;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: recording ? 'Stop recording' : 'Start recording',
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: SvgPicture.asset(
            recording ? CameraIcons.recordStop : CameraIcons.recordIdle,
            key: ValueKey(recording),
          ),
        ),
      ),
    );
  }
}
