import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';

/// White top bar with a centred navy title and optional leading/trailing
/// actions. Use as `Scaffold.appBar`; it pads itself below the status bar.
///
/// ```dart
/// StarScreenHeader(
///   title: 'New Post',
///   leading: StarIconButton.back(onPressed: () => context.pop()),
///   trailing: StarHeaderTextAction(label: 'Drafts', onTap: _openDrafts),
/// )
/// ```
class StarScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const StarScreenHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  static const barHeight = 67.0;

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(barHeight);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: barHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 52),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        height: 1.2,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandNavy,
                      ),
                    ),
                  ),
                  if (leading != null)
                    Align(alignment: Alignment.centerLeft, child: leading),
                  if (trailing != null)
                    Align(alignment: Alignment.centerRight, child: trailing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text action for the header's trailing slot, e.g. "Drafts".
class StarHeaderTextAction extends StatelessWidget {
  const StarHeaderTextAction({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            height: 1.2,
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
            color: AppColors.brandBlue,
          ),
        ),
      ),
    );
  }
}

/// Convenience: header back button that pops the current route.
class StarBackButton extends StatelessWidget {
  const StarBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StarIconButton.back(onPressed: () => Navigator.of(context).maybePop());
  }
}
