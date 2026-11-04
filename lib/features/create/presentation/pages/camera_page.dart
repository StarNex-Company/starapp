import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/create/presentation/widgets/camera_controls.dart';
import 'package:starapp/features/create/presentation/widgets/camera_icons.dart';
import 'package:starapp/features/create/presentation/widgets/camera_rec_status.dart';
import 'package:starapp/features/create/presentation/widgets/camera_selectors.dart';
import 'package:starapp/features/create/presentation/widgets/camera_viewfinder.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

const _bottomScrim = Color(0xCC07090D); // rgba(7,9,13,0.8)
const _scrimClear = Color(0x0007090D);

// Stand-ins for the live preview and the latest gallery item until camera
// and gallery access exist.
const _viewfinderPlaceholder = 'assets/images/shared/entry_video_frame.jpg';
const _galleryPlaceholder = 'assets/images/create/camera_gallery_thumb.jpg';

const _tools = [
  (icon: CameraIcons.flip, label: 'Flip'),
  (icon: CameraIcons.flash, label: 'Flash'),
  (icon: CameraIcons.timer, label: 'Timer'),
  (icon: CameraIcons.sparkle, label: 'Effects'),
  (icon: CameraIcons.mic, label: 'Voice'),
];

/// Full-bleed video capture screen (idle and recording states).
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  Duration _maxDuration = cameraDurations.last;
  CameraMode _mode = CameraMode.video;
  bool _recording = false;
  bool _paused = false;
  bool _finishing = false;

  /// Runs from 0 to 1 over [_maxDuration] while recording.
  late final AnimationController _clip =
      AnimationController(vsync: this, duration: _maxDuration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) _finish();
        });

  Duration get _elapsed => _maxDuration * _clip.value;

  @override
  void dispose() {
    _clip.dispose();
    super.dispose();
  }

  void _comingSoon() {
    showStarToast(context, 'Coming soon');
  }

  void _close() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.home);

  void _selectDuration(Duration duration) {
    setState(() => _maxDuration = duration);
    _clip.duration = duration;
  }

  void _onRecordPressed() {
    if (_finishing) return;
    if (_recording) {
      _finish();
    } else if (_mode != CameraMode.video) {
      _comingSoon();
    } else {
      setState(() {
        _recording = true;
        _paused = false;
      });
      _clip.forward(from: 0);
    }
  }

  void _togglePause() {
    if (_finishing) return;
    setState(() => _paused = !_paused);
    _paused ? _clip.stop() : _clip.forward();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    _clip.stop();
    await context.push(AppRoutes.createPreview);
    if (!mounted) return;
    _clip.reset();
    setState(() {
      _recording = false;
      _paused = false;
      _finishing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.inkDeep,
        body: Stack(
          children: [
            const Positioned.fill(
              child: CameraViewfinder(
                placeholder: AssetImage(_viewfinderPlaceholder),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 220,
              child: _Scrim(colors: [AppColors.scrim, _scrimClear]),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 320,
              child: _Scrim(colors: [_scrimClear, _bottomScrim]),
            ),
            // The progress bar sits just under the status bar text.
            Positioned(
              top: math.max(insets.top - 4, 8),
              left: 24,
              right: 24,
              child: _buildTop(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: math.max(insets.bottom + 1 - CameraModeTabs.vPad, 0),
              child: _buildBottom(_galleryPlaceholder),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _clip,
          builder: (_, _) => CameraRecProgress(progress: _clip.value),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CameraGlassButton(
                  size: 40,
                  onPressed: _close,
                  semanticLabel: 'Close',
                  child: SvgPicture.asset(CameraIcons.close),
                ),
              ),
              _Hideable(
                hidden: _recording,
                child: CameraAddSoundPill(onPressed: _comingSoon),
              ),
              _Hideable(
                hidden: !_recording,
                child: AnimatedBuilder(
                  animation: _clip,
                  builder: (_, _) =>
                      CameraRecTimerPill(elapsed: _elapsed, max: _maxDuration),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Align(
          alignment: Alignment.centerRight,
          child: _Hideable(
            hidden: _recording,
            child: Column(
              children: [
                for (var i = 0; i < _tools.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  CameraToolButton(
                    icon: _tools[i].icon,
                    label: _tools[i].label,
                    onPressed: _comingSoon,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottom(String? galleryThumbnail) {
    final Widget rightIcon;
    final String rightLabel;
    if (!_recording) {
      rightIcon = SvgPicture.asset(CameraIcons.sparkle);
      rightLabel = 'Enhance';
    } else if (_paused) {
      rightIcon = const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
        size: 24,
      );
      rightLabel = 'Resume recording';
    } else {
      rightIcon = SvgPicture.asset(CameraIcons.pause);
      rightLabel = 'Pause recording';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Hideable(
          hidden: _recording,
          child: CameraDurationChips(
            selected: _maxDuration,
            onSelected: _selectDuration,
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 52),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Hideable(
                hidden: _recording,
                child: CameraGalleryButton(
                  thumbnail: galleryThumbnail == null
                      ? null
                      : AssetImage(galleryThumbnail),
                  onPressed: _comingSoon,
                ),
              ),
              CameraRecordButton(
                recording: _recording,
                onPressed: _onRecordPressed,
              ),
              CameraGlassButton(
                size: 46,
                onPressed: _recording ? _togglePause : _comingSoon,
                semanticLabel: rightLabel,
                child: rightIcon,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22 - CameraModeTabs.vPad),
        _Hideable(
          hidden: _recording,
          child: CameraModeTabs(
            selected: _mode,
            onSelected: (mode) => setState(() => _mode = mode),
          ),
        ),
      ],
    );
  }
}

/// Fades a control out while recording, keeping its layout slot.
class _Hideable extends StatelessWidget {
  const _Hideable({required this.hidden, required this.child});

  final bool hidden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hidden ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: hidden,
        child: ExcludeSemantics(excluding: hidden, child: child),
      ),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
      ),
    );
  }
}
