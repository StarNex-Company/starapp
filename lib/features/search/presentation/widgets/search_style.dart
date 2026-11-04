import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// Inter's "normal" line height, so text boxes match the design.
const searchLeading = 1.21;

abstract final class SearchIcons {
  static const _dir = 'assets/vectors/search';

  static const search = 'assets/vectors/shared/ic_search.svg';
  static const clock = 'assets/vectors/shared/ic_clock.svg';
  static const remove = '$_dir/search_ic_remove.svg';
  static const trophy = 'assets/vectors/shared/ic_trophy.svg';
  static const chevron = 'assets/vectors/shared/share_chevron.svg';
  static const ring = 'assets/vectors/shared/avatar_ring.svg';
  static const ringGap = 'assets/vectors/shared/avatar_ring_gap.svg';
}

abstract final class SearchColors {
  /// text/secondary/5d5d5d — search field placeholder.
  static const placeholder = Color(0xFF5D5D5D);

  /// Empty-state copy ("No recent searches…").
  static const emptyText = Color(0xFF6B7380);
}

/// Navy group heading: "Recent searches", "Creators", "Challenges".
class SearchSectionTitle extends StatelessWidget {
  const SearchSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 18,
        height: searchLeading,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: AppColors.brandBlue,
      ),
    );
  }
}

/// Grey helper line under a heading when a group has nothing to show.
class SearchEmptyText extends StatelessWidget {
  const SearchEmptyText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: searchLeading,
        letterSpacing: 0,
        color: SearchColors.emptyText,
      ),
    );
  }
}
