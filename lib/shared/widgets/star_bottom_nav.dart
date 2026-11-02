import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/shared/widgets/star_image.dart';

const _selectedTint = Color(0xFFD7E3FF); // surface/brand-tint/d7e3ff
const _fadeMid = Color(0xBC435A94); // rgba(67, 90, 148, 0.736)

const _barHeight = 55.0;
const _itemSize = 35.0;

/// One destination in [StarBottomNav]: either an SVG icon or an avatar photo.
class StarBottomNavItem {
  const StarBottomNavItem.icon({
    required this.label,
    required String this.icon,
    this.selectedIcon,
    this.showDot = false,
  }) : isAvatar = false,
       avatarUrl = null;

  /// [avatarUrl] may be null (not loaded or not set): shows a placeholder.
  const StarBottomNavItem.avatar({
    required this.label,
    this.avatarUrl,
    this.showDot = false,
  }) : isAvatar = true,
       icon = null,
       selectedIcon = null;

  /// Used for semantics and the long-press tooltip.
  final String label;

  /// SVG asset paths, drawn at their intrinsic size (about 25px).
  final String? icon;
  final String? selectedIcon;
  final bool isAvatar;
  final String? avatarUrl;

  /// A small red dot on the icon, e.g. unread messages.
  final bool showDot;
}

/// Floating pill navigation with a round create button, over a navy fade.
/// Use as `Scaffold.bottomNavigationBar` with `extendBody: true` so content
/// scrolls underneath it.
///
/// ```dart
/// StarBottomNav(
///   items: const [StarBottomNavItem.icon(label: 'Home', icon: homeSvg), ...],
///   selectedIndex: _index,
///   onTap: (i) => setState(() => _index = i),
///   createIcon: createSvg,
///   onCreate: () => showCreateSheet(context),
/// )
/// ```
class StarBottomNav extends StatelessWidget {
  const StarBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.createIcon,
    required this.onCreate,
    this.createLabel = 'Create',
  });

  final List<StarBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  /// SVG asset path for the create button, drawn at 22px.
  final String createIcon;
  final VoidCallback onCreate;
  final String createLabel;

  @override
  Widget build(BuildContext context) {
    // The design sits the bar 23px above the edge of a 34px-inset iPhone.
    final bottom = math.max(
      MediaQuery.viewPaddingOf(context).bottom - 11,
      16.0,
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.35, sigmaY: 2.35),
        child: DecoratedBox(
          // Navy is reached just below the bar's bottom edge, as rendered
          // in the design.
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0, 1.224),
              end: Alignment.topCenter,
              colors: [AppColors.brandNavy, _fadeMid, Color(0x00FFFFFF)],
              stops: [0, 0.2765, 1],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 29, 24, bottom),
            child: SizedBox(
              height: _barHeight,
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: _Pill(
                      items: items,
                      selectedIndex: selectedIndex,
                      onTap: onTap,
                    ),
                  ),
                  _CreateButton(
                    icon: createIcon,
                    label: createLabel,
                    onPressed: onCreate,
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<StarBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _barHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(100)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14001F6E),
            offset: Offset(0, -4),
            blurRadius: 2,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final row = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < items.length; i++)
                _NavButton(
                  item: items[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onTap(i),
                ),
            ],
          );
          // On very narrow phones, shrink the tabs rather than overflow.
          final needed = items.length * _itemSize;
          if (constraints.maxWidth >= needed) return row;
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(width: needed, height: _itemSize, child: row),
          );
        },
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final StarBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = !item.isAvatar
        ? Center(
            child: SvgPicture.asset(
              isSelected ? item.selectedIcon ?? item.icon! : item.icon!,
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandNavy, width: 1.7),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: LayoutBuilder(
                builder: (context, box) =>
                    StarAvatar(item.avatarUrl, size: box.maxWidth),
              ),
            ),
          );

    final button = Material(
      color: isSelected ? _selectedTint : Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(dimension: _itemSize, child: content),
      ),
    );

    return Semantics(
      selected: isSelected,
      label: item.showDot ? '${item.label}, new activity' : null,
      child: Tooltip(
        message: item.label,
        child: !item.showDot
            ? button
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  button,
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, -4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: AppColors.brandNavy,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: _barHeight,
              child: Center(
                child: SvgPicture.asset(icon, width: 22, height: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
