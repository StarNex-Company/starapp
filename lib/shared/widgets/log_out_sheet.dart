import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_bottom_sheet.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';

/// Figma "Sheet — Log Out". Completes with `true` when the user confirms.
Future<bool> showLogOutSheet(BuildContext context) async {
  final confirmed = await showStarSheet<bool>(
    context: context,
    builder: (_) => const LogOutSheet(),
  );
  return confirmed ?? false;
}

class LogOutSheet extends StatelessWidget {
  const LogOutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return StarSheet(
      title: 'Log out of Star App?',
      subtitle: 'You can log back in any time with email or Google.',
      children: [
        _DangerButton(
          label: 'Log out',
          onPressed: () => Navigator.of(context).pop(true),
        ),
        StarOutlinedButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

/// 48px red-on-pink action.
class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Material(
        color: AppColors.dangerTint,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                height: 1.2,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
