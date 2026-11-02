import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/profile/presentation/widgets/connections_style.dart';

/// Grey search input above the list. Typing filters the list in place; the
/// magnifier opens the app-wide search.
class ConnectionsSearchField extends StatelessWidget {
  const ConnectionsSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSearchTap,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        color: AppColors.closeButtonBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderField),
      ),
      child: Row(
        children: [
          // The 18px icon sits 16px in, with a wider tap target around it.
          Semantics(
            button: true,
            label: 'Open search',
            child: InkResponse(
              onTap: onSearchTap,
              radius: 20,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 10, 13),
                child: SvgPicture.asset(
                  ConnectionsIcons.search,
                  width: 18,
                  height: 18,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.brandBlue,
              style: const TextStyle(
                fontSize: 15,
                height: 22 / 15,
                letterSpacing: 0,
                color: AppColors.ink,
              ),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 15,
                  height: 22 / 15,
                  letterSpacing: 0,
                  color: AppColors.textFaint,
                ),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => controller.text.isEmpty
                ? const SizedBox(width: 16)
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: controller.clear,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSubtle,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// "Followers  842" heading above the rows.
class ConnectionsSectionHeader extends StatelessWidget {
  const ConnectionsSectionHeader({
    super.key,
    required this.title,
    required this.count,
  });

  final String title;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              height: connectionsLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
        ),
        Text(
          count,
          style: const TextStyle(
            fontSize: 13,
            height: connectionsLeading,
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
            color: AppColors.brandBlue,
          ),
        ),
      ],
    );
  }
}
