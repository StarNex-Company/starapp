import 'package:flutter/material.dart';
import 'package:starapp/core/utils/formatters.dart';

// Colours and helpers shared by the videos feed widgets. Colours missing from
// AppColors live here so the feed's glass chrome stays consistent.

/// Rail and back-button circles: 7d7d80 @ 52%.
const videoGlass = Color(0x857D7D80);

/// Caption hashtags.
const videoHashtag = Color(0xFFBACDFF);

/// Cobalt avatar ring and verified badge.
const videoCobaltRing = Color(0xFF3B82F6);
const videoCobalt = Color(0xFF2563EB);

/// Text over the video, e.g. caption and meta lines.
const videoCaption = Color(0xFFE2E2E2);
const videoMeta = Color(0xFFD5D5D5);
const videoChipText = Color(0xFFE5E5E5);
const videoTimeText = Color(0xFFD4D4D4);

/// Soft shadow the design puts under names and captions.
const videoTextShadows = [
  Shadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 0.5),
  Shadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 1),
];

/// Inter text style with the line height and tracking pinned, so Material's
/// defaults don't leak in. [lineHeight] is in pixels; null means Inter's
/// "normal" leading.
TextStyle videoText(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = Colors.white,
  double? lineHeight,
  double letterSpacing = 0,
  List<Shadow>? shadows,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: lineHeight == null ? 1.21 : lineHeight / size,
    letterSpacing: letterSpacing,
    shadows: shadows,
  );
}

/// Star and save counts: "742", "2,431", "18.4k".
String formatGroupedCount(int n) =>
    n >= 10000 ? formatCompactCount(n) : formatGrouped(n);

/// Comment counts: "980", "4.8k", "30.1k", "1.2M".
String formatCompactCount(int n) => formatCompact(n).replaceFirst('K', 'k');
