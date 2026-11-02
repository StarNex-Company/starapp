import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/models/preset_avatar.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_toast.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _addIcon = 'assets/vectors/auth_add.svg'; // material-symbols:add-rounded
const _selectedIcon =
    'assets/vectors/auth_avatar_check.svg'; // #000207 disc + tick

const _uploadBg = Color(0xFF011F6C);

// Photo ring: 3px inside stroke, Figma angular gradient (stops 0/.25/.5/1).
const _ringColors = [
  Color(0xFFF90000),
  Color(0xFFF4A202),
  Color(0xFF00993B),
  Color(0xFF001F6E),
];
const _ringStops = [0.0, 0.25, 0.5, 1.0];

const double _photoSize = 172;
const double _thumbSize = 45;

/// Decodes [asset] at the width it is drawn at (keeps the aspect ratio).
ImageProvider _avatarImage(String asset, double logicalWidth, double dpr) =>
    ResizeImage(starImageProvider(asset), width: (logicalWidth * dpr).ceil());

/// Registration step 4 of 4 — "Add a Profile Photo" (Figma `241:1385`).
///
/// A 172px photo with the spinning gradient ring and a "+" upload button
/// ('Coming soon' — no image picker yet), and a scrollable row of nine preset
/// avatars (from `presetAvatarsProvider`): tapping one selects it (black disc
/// and tick) and shows it in the photo. Skip and Continue both push
/// [AppRoutes.registerInterests]; Continue records the chosen avatar in
/// `registrationProvider`, Skip clears it.
///
/// Motion (Figma "Profile Selection Animated" `279:1174`): the ring's angular
/// gradient turns 90° clockwise every 300ms (ease-out, looping); a selection
/// swaps the photo and tick straight away in the prototype — here with a
/// 300ms ease-out cross-fade. Reduced motion stops the ring.
class ProfilePictureScreen extends ConsumerStatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  ConsumerState<ProfilePictureScreen> createState() =>
      _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends ConsumerState<ProfilePictureScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring;
  late final Animation<double> _ringAngle;

  int _selected = 0;
  bool _reduceMotion = false;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    // Four 300ms quarter turns (Border-radius variants 279:1163 → 279:1166).
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringAngle = _ring.drive(const _QuarterTurns());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _ring
        ..stop()
        ..value = 0;
    } else if (!_ring.isAnimating) {
      _ring.repeat();
    }
  }

  /// Decodes every preset at photo size once, so a selection swaps at once.
  void _precache(List<PresetAvatar> avatars) {
    if (_precached) return;
    _precached = true;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    for (final a in avatars) {
      precacheImage(
        _avatarImage(a.imageUrl, a.photo.width * _photoSize, dpr),
        context,
      );
    }
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  Duration get _fade =>
      _reduceMotion ? Duration.zero : const Duration(milliseconds: 300);

  void _continue() {
    final avatars = ref.read(presetAvatarsProvider).value;
    ref
        .read(registrationProvider.notifier)
        .setAvatar(avatars == null ? null : avatars[_selected].imageUrl);
    _next();
  }

  void _skip() {
    ref.read(registrationProvider.notifier).setAvatar(null);
    _next();
  }

  void _next() => context.push(AppRoutes.registerInterests);

  @override
  Widget build(BuildContext context) {
    final avatars = ref.watch(presetAvatarsProvider);
    return AuthScaffold(
      step: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeading(
            title: 'Add a Profile Photo',
            subtitle:
                'Add a profile picture so people can recognize your '
                'account and connect with you more easily.',
          ),
          const SizedBox(height: 30),
          StarAsyncView(
            value: avatars,
            onRetry: () => ref.invalidate(presetAvatarsProvider),
            // Holds the photo and thumbnails' space while the presets load.
            loading: const SizedBox(height: _photoSize + 30 + _thumbSize),
            builder: (avatars) {
              _precache(avatars);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: _ProfilePhoto(
                      avatar: avatars[_selected],
                      ringAngle: _ringAngle,
                      fade: _fade,
                      onUpload: () => showStarToast(context, 'Coming soon'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: _thumbSize,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: avatars.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 7),
                      itemBuilder: (context, i) => _AvatarThumb(
                        avatar: avatars[i],
                        selected: i == _selected,
                        fade: _fade,
                        onTap: () {
                          if (i != _selected) setState(() => _selected = i);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          // The design's buttons are 50 high with radius 10: the compact
          // (r10) skin stretched to 50 by the tight parent.
          SizedBox(
            height: 50,
            child: AuthSecondaryButton(
              label: 'Skip',
              size: AuthButtonSize.compact,
              onPressed: _skip,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: AuthPrimaryButton(
              label: 'Continue',
              size: AuthButtonSize.compact,
              onPressed: _continue,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ring angle for the controller's 0→1 loop: four quarter turns, each eased
/// with the prototype's cubic-bezier(0, 0, 0.58, 1) (= [Curves.easeOut]).
class _QuarterTurns extends Animatable<double> {
  const _QuarterTurns();

  @override
  double transform(double t) {
    final quarters = t * 4;
    final step = math.min(quarters.floorToDouble(), 3.0);
    return (step + Curves.easeOut.transform(quarters - step)) * math.pi / 2;
  }
}

/// 172px circular photo, 3px gradient ring and the 47px "+" button at its
/// bottom-right (Figma "Profile Picture" `279:1176`).
class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({
    required this.avatar,
    required this.ringAngle,
    required this.fade,
    required this.onUpload,
  });

  final PresetAvatar avatar;
  final Animation<double> ringAngle;
  final Duration fade;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _photoSize,
      child: Stack(
        children: [
          Semantics(
            image: true,
            label: 'Profile photo',
            child: AnimatedSwitcher(
              duration: fade,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              child: _CroppedAvatar(
                key: ValueKey(avatar.imageUrl),
                asset: avatar.imageUrl,
                crop: avatar.photo,
                size: _photoSize,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _RingPainter(ringAngle)),
              ),
            ),
          ),
          Positioned(
            left: 124.5,
            top: 125,
            child: _UploadButton(onTap: onUpload),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.angle) : super(repaint: angle);

  final Animation<double> angle;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = SweepGradient(
        colors: _ringColors,
        stops: _ringStops,
        // At rest the gradient starts at the bottom (red) and runs clockwise.
        transform: GradientRotation(math.pi / 2 + angle.value),
      ).createShader(rect);
    canvas.drawOval(rect.deflate(stroke / 2), paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.angle != angle;
}

/// 47px #011F6C disc with the 41px add icon ("Add/Upload Picture").
class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Upload a photo',
      excludeSemantics: true,
      child: Material(
        color: _uploadBg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 47,
            child: Center(
              child: SvgPicture.asset(_addIcon, width: 41, height: 41),
            ),
          ),
        ),
      ),
    );
  }
}

/// 45px preset avatar; selected shows the #000207 disc with a white tick.
class _AvatarThumb extends StatelessWidget {
  const _AvatarThumb({
    required this.avatar,
    required this.selected,
    required this.fade,
    required this.onTap,
  });

  final PresetAvatar avatar;
  final bool selected;
  final Duration fade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: avatar.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox.square(
            dimension: _thumbSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CroppedAvatar(
                  asset: avatar.imageUrl,
                  crop: avatar.thumb,
                  size: _thumbSize,
                ),
                AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: fade,
                  curve: Curves.easeOut,
                  child: SvgPicture.asset(
                    _selectedIcon,
                    width: _thumbSize,
                    height: _thumbSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circle of [size] showing [asset] laid out at [crop] (fractions of the
/// circle's box) — the Figma CROP image fill.
class _CroppedAvatar extends StatelessWidget {
  const _CroppedAvatar({
    super.key,
    required this.asset,
    required this.crop,
    required this.size,
  });

  final String asset;
  final Rect crop;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          children: [
            Positioned(
              left: crop.left * size,
              top: crop.top * size,
              width: crop.width * size,
              height: crop.height * size,
              child: Image(
                image: _avatarImage(asset, crop.width * size, dpr),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
