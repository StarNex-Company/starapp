import 'package:flutter/material.dart';

/// Edit Profile colours that aren't app tokens (the form uses the design's
/// slate palette).
abstract final class EditProfileColors {
  static const label = Color(0xFF64748B); // text/secondary/64748b
  static const coverLabel = Color(0xFF6B7380);
  static const hint = Color(0xFF999EAB);
  static const muted = Color(0xFF94A3B8); // "@", counter
  static const text = Color(0xFF0F172A); // text/primary/0f172a
  static const border = Color(0xFFE2E8F0); // border/default/e2e8f0
  static const tint = Color(0xFFEFF6FF); // surface/brand-tint/eff6ff
  static const pillBorder = Color(0xFFDBEAFE);
  static const addPillBorder = Color(0x99BFDBFE); // bfdbfe @ 60%
  static const brand = Color(0xFF042987); // text/brand/042987
  static const coverScrim = Color(0x4000051A); // 00051a @ 25%
  static const coverButton = Color(0x8C000000); // black @ 55%
  static const avatarRing = Color(0xE6F1F5F9); // f1f5f9 @ 90%
}

/// Card surface of the form fields: white, slate hairline, faint drop shadow.
const editProfileFieldDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(8)),
  boxShadow: [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ],
);

/// Uppercase slate field label ("DISPLAY NAME").
class EditProfileLabel extends StatelessWidget {
  const EditProfileLabel(this.text, {super.key, this.trailing});

  final String text;

  /// Right-aligned note, e.g. the bio counter.
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 16 / 12,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
              color: EditProfileColors.label,
            ),
          ),
        ),
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              trailing!,
              style: const TextStyle(
                fontSize: 12,
                height: 16 / 12,
                letterSpacing: 0,
                color: EditProfileColors.muted,
              ),
            ),
          ),
      ],
    );
  }
}
