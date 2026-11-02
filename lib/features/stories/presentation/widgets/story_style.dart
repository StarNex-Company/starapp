import 'package:flutter/material.dart';

/// Story colours the shared AppColors palette doesn't have.
abstract final class StoryColors {
  /// Dark text/icons on the gold buttons ("Next", "Your story").
  static const onGold = Color(0xFF2A1C00);

  /// Story settings sheet.
  static const sheetLabel = Color(0xFF59606D);
  static const optionFill = Color(0xFFF6F8FC);
  static const optionBorder = Color(0xFFE2E6EE);
  static const durationFill = Color(0xFFF1F4F9);
  static const durationText = Color(0xFF3A4255);

  /// Text-story background.
  static const textStoryStart = Color(0xFF0B46C5);
  static const textStoryEnd = Color(0xFF010F3D);

  static const textStoryGradient = LinearGradient(
    // CSS linear-gradient(121.59deg, …) on a 393×852 story.
    begin: Alignment(-1.693, -0.48),
    end: Alignment(1.693, 0.48),
    colors: [textStoryStart, textStoryEnd],
    stops: [0, 0.71429],
  );
}

/// Inter text with the design's "normal" leading and no tracking.
TextStyle storyText(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = Colors.white,
  double? height,
}) => TextStyle(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height ?? 1.21,
  letterSpacing: 0,
);
