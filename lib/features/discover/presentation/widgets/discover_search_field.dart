import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';

/// Grey "Search creators or talents" pill. It isn't a text field: tapping it
/// opens the search screen.
class DiscoverSearchField extends StatelessWidget {
  const DiscoverSearchField({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search creators or talents',
      excludeSemantics: true,
      child: Material(
        color: AppColors.iconButtonBg,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 45,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 7,
                children: [
                  SvgPicture.asset(DiscoverIcons.search, width: 22, height: 22),
                  Expanded(
                    child: Text(
                      'Search creators or talents',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: discoverText(
                        16,
                        FontWeight.w500,
                        DiscoverColors.searchHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
