import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Whether [src] is a network URL rather than a bundled asset path.
bool isNetworkImage(String src) =>
    src.startsWith('http://') || src.startsWith('https://');

/// The [ImageProvider] for an image field from the API: network URLs are
/// disk-cached; asset paths (mock data) load from the bundle.
ImageProvider starImageProvider(String src) => isNetworkImage(src)
    ? CachedNetworkImageProvider(src)
    : AssetImage(src) as ImageProvider;

/// Every content image (avatars, covers, thumbnails, posters) goes through
/// this, never `Image.asset`/`Image.network` directly, so URLs from the API
/// and asset paths from mock data both work. A null or empty [src], a
/// loading image and a failed one all show the muted placeholder.
class StarImage extends StatelessWidget {
  const StarImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.placeholderColor = AppColors.surfaceMuted,
    this.semanticLabel,
  });

  final String? src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final Color placeholderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: placeholderColor,
      child: SizedBox(width: width, height: height),
    );
    final source = src;

    final Widget image;
    if (source == null || source.isEmpty) {
      image = placeholder;
    } else if (isNetworkImage(source)) {
      image = CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      );
    } else {
      image = Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    final radius = borderRadius;
    return radius == null
        ? image
        : ClipRRect(borderRadius: radius, child: image);
  }
}

/// A round profile photo of [size]; shows a person glyph when [src] is
/// null, still loading, or broken.
class StarAvatar extends StatelessWidget {
  const StarAvatar(
    this.src, {
    super.key,
    required this.size,
    this.semanticLabel,
  });

  final String? src;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: size * 0.6,
        color: AppColors.avatarFallback,
      ),
    );
    final source = src;

    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: source == null || source.isEmpty
            ? fallback
            : isNetworkImage(source)
            ? CachedNetworkImage(
                imageUrl: source,
                width: size,
                height: size,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (_, _) => fallback,
                errorWidget: (_, _, _) => fallback,
              )
            : Image.asset(
                source,
                width: size,
                height: size,
                fit: BoxFit.cover,
                semanticLabel: semanticLabel,
                excludeFromSemantics: semanticLabel == null,
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}
