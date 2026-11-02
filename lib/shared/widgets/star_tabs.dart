import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starapp/core/utils/formatters.dart';

// The Challenges hub's tab strip and arena pills are the app's one style for
// tabs and single-choice filters; every screen uses these two widgets.

const _track = Color(0xFFECEEF0); // surface/muted/eceef0
const _body = Color(0xFF444652); // text/body/444652
const _selectedText = Color(0xFF042E9A); // text/brand/042e9a
const _countSelected = Color(0xFFDDE1FF); // surface/brand-tint/dde1ff
const _countSelectedInk = Color(0xFF001F6E); // text/brand/001f6e
const _countMuted = Color(0xFFE0E3E5); // surface/muted/e0e3e5
const _countWarm = Color(0xFFFFDEA9); // surface/tint/ffdea9
const _countWarmInk = Color(0xFF271900);
const _chipSelected = Color(0xFF042987);
const _chipIdle = Color(0xFFF2F4F6); // surface/muted/f2f4f6
const _lift = BoxShadow(
  color: Color(0x0D000000),
  offset: Offset(0, 1),
  blurRadius: 1,
);
const _fade = Duration(milliseconds: 160);

/// Side padding of a tab in an equal-share [StarTabBar]; labels are
/// centred there, so it only keeps text off the card's edge.
const _expandedPadding = 8.0;

TextStyle _label(double size, FontWeight weight, Color color) => TextStyle(
  fontFamily: 'Inter',
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: 16 / 12,
  letterSpacing: 0,
);

/// Colour of a [StarTab]'s count badge while the tab isn't selected.
enum StarTabCountTone { neutral, highlight }

/// One entry of [StarTabBar]: a label with an optional leading icon and a
/// trailing count badge ("Requests 2").
class StarTab {
  const StarTab({
    required this.label,
    this.icon,
    this.count,
    this.countTone = StarTabCountTone.neutral,
  });

  final String label;

  /// SVG asset path; recoloured to match the label.
  final String? icon;
  final int? count;
  final StarTabCountTone countTone;
}

/// Grey tab strip with the selected tab on a white card, as on the
/// Challenges hub.
///
/// With [expand] (the default) the tabs share the width equally, for two to
/// four tabs. Without it they hug their labels and the strip scrolls, for
/// longer sets. [selected] may be null when no tab applies (e.g. a custom
/// date range).
class StarTabBar extends StatelessWidget {
  const StarTabBar({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    this.expand = true,
  });

  final List<StarTab> tabs;
  final int? selected;
  final ValueChanged<int> onSelected;
  final bool expand;

  static const _gap = 3.4;

  /// Each tab's natural width (bold, as when selected) plus an equal share
  /// of what's left, so short labels balance and long ones aren't cut. When
  /// they don't all fit, widths shrink in proportion and labels ellipsize.
  List<double> _shareWidth(BuildContext context, double available) {
    final scaler = MediaQuery.textScalerOf(context);
    double measure(String text, TextStyle style) => (TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout()).width;

    final natural = [
      for (final tab in tabs)
        2 * _expandedPadding +
            measure(tab.label, _label(12, FontWeight.w700, _selectedText)) +
            (tab.icon == null ? 0 : 12 + 6) +
            (tab.count == null
                ? 0
                : 6 +
                      12 +
                      measure(
                        formatCompact(tab.count!),
                        _label(10, FontWeight.w700, _body),
                      )),
    ];
    final room = available - _gap * (tabs.length - 1);
    final total = natural.fold<double>(0, (a, b) => a + b);
    if (total >= room) return [for (final w in natural) w * room / total];
    final extra = (room - total) / tabs.length;
    return [for (final w in natural) w + extra];
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      for (var i = 0; i < tabs.length; i++)
        _TabButton(
          tab: tabs[i],
          selected: i == selected,
          expand: expand,
          onTap: () => onSelected(i),
        ),
    ];

    return Container(
      height: 40,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _track,
        borderRadius: BorderRadius.circular(12),
      ),
      child: expand
          ? Padding(
              padding: const EdgeInsets.all(4),
              child: LayoutBuilder(
                builder: (context, box) {
                  final widths = _shareWidth(context, box.maxWidth);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: _gap,
                    children: [
                      for (var i = 0; i < buttons.length; i++)
                        SizedBox(width: widths[i], child: buttons[i]),
                    ],
                  );
                },
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: _gap,
                children: buttons,
              ),
            ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.expand,
    required this.onTap,
  });

  final StarTab tab;
  final bool selected;
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = tab.icon;
    final count = tab.count;
    final ink = selected ? _selectedText : _body;
    final label = Text(
      tab.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _label(12, selected ? FontWeight.w700 : FontWeight.w500, ink),
    );

    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: _fade,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected ? const [_lift] : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            // Equal-width tabs centre their label, so they only need a
            // little side padding; hugging tabs keep the hub's 14.
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expand ? _expandedPadding : 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  if (icon != null)
                    SvgPicture.asset(
                      icon,
                      height: 12,
                      colorFilter: ColorFilter.mode(ink, BlendMode.srcIn),
                    ),
                  if (expand) Flexible(child: label) else label,
                  if (count != null)
                    _CountBadge(
                      count: count,
                      selected: selected,
                      tone: tab.countTone,
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

class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.selected,
    required this.tone,
  });

  final int count;
  final bool selected;
  final StarTabCountTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, ink) = selected
        ? (_countSelected, _countSelectedInk)
        : switch (tone) {
            StarTabCountTone.neutral => (_countMuted, _body),
            StarTabCountTone.highlight => (_countWarm, _countWarmInk),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        formatCompact(count),
        style: _label(10, FontWeight.w700, ink).copyWith(height: 1),
      ),
    );
  }
}

/// One option of [StarChoiceChips].
class StarChip<T> {
  const StarChip({
    required this.value,
    required this.label,
    this.icon,
    this.keepIconColors = false,
  });

  final T value;
  final String label;

  /// SVG asset path. Recoloured to the label colour, unless
  /// [keepIconColors] keeps its own colours while the chip is unselected.
  final String? icon;
  final bool keepIconColors;
}

/// Single-choice row of pills ("All Arenas", "Music & Audio", …): navy when
/// selected, light grey otherwise, as on the Challenges hub.
///
/// Scrolls horizontally and brings the selected pill into view when the
/// selection changes from elsewhere; [wrap] lays the pills out on several
/// lines instead. [padding] insets the scrolling row (e.g. the page gutter,
/// so pills scroll to the screen edge).
class StarChoiceChips<T> extends StatefulWidget {
  const StarChoiceChips({
    super.key,
    required this.chips,
    required this.selected,
    required this.onSelected,
    this.wrap = false,
    this.padding = EdgeInsets.zero,
  });

  final List<StarChip<T>> chips;

  /// May match none of [chips].
  final T? selected;
  final ValueChanged<T> onSelected;
  final bool wrap;
  final EdgeInsetsGeometry padding;

  @override
  State<StarChoiceChips<T>> createState() => _StarChoiceChipsState<T>();
}

class _StarChoiceChipsState<T> extends State<StarChoiceChips<T>> {
  final _keys = <Object?, GlobalKey>{};

  @override
  void didUpdateWidget(StarChoiceChips<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wrap || oldWidget.selected == widget.selected) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chip = _keys[widget.selected]?.currentContext;
      if (chip == null || !chip.mounted) return;
      Scrollable.ensureVisible(
        chip,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final pills = [
      for (final chip in widget.chips)
        StarPill(
          key: _keys.putIfAbsent(chip.value, GlobalKey.new),
          label: chip.label,
          icon: chip.icon,
          keepIconColors: chip.keepIconColors,
          selected: chip.value == widget.selected,
          onTap: () => widget.onSelected(chip.value),
        ),
    ];

    if (widget.wrap) {
      return Padding(
        padding: widget.padding,
        child: Wrap(spacing: 4, runSpacing: 8, children: pills),
      );
    }
    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: widget.padding,
        child: Row(spacing: 4, children: pills),
      ),
    );
  }
}

/// One pill of [StarChoiceChips], for rows that aren't a single choice
/// (e.g. a category plus an independent "Remote" toggle).
class StarPill extends StatelessWidget {
  const StarPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.keepIconColors = false,
  });

  final String label;
  final bool selected;

  /// Null disables the pill (drawn at half opacity).
  final VoidCallback? onTap;

  /// See [StarChip.icon].
  final String? icon;
  final bool keepIconColors;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    final ink = selected ? Colors.white : _body;
    final tint = selected || !keepIconColors
        ? ColorFilter.mode(ink, BlendMode.srcIn)
        : null;

    return Semantics(
      selected: selected,
      button: true,
      enabled: onTap != null,
      child: AnimatedContainer(
        duration: _fade,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? _chipSelected : _chipIdle,
          borderRadius: BorderRadius.circular(99),
          boxShadow: selected ? const [_lift] : const [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Opacity(
                opacity: onTap == null ? 0.5 : 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    if (icon != null)
                      SvgPicture.asset(icon, height: 12, colorFilter: tint),
                    Text(
                      label,
                      maxLines: 1,
                      style: _label(12, FontWeight.w600, ink),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
