import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';

/// White bordered card that stacks [children] with hairline dividers between
/// them (settings lists, radio lists).
class StarDividedCard extends StatelessWidget {
  const StarDividedCard({super.key, required this.children});

  /// Card surface shared by the bordered cards of the create & moderation
  /// flows.
  static const decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: AppColors.borderField)),
    boxShadow: [
      BoxShadow(color: Color(0x0F0B1020), offset: Offset(0, 4), blurRadius: 9),
    ],
  );

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const ColoredBox(color: AppColors.borderField, child: SizedBox(height: 1)),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class StarRadioOption<T> {
  const StarRadioOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.enabled = true,
  });

  final T value;
  final String title;
  final String? subtitle;

  /// Disabled options are greyed out and can't be selected.
  final bool enabled;
}

/// Single-choice list in a [StarDividedCard]: radio, title and subtitle per
/// row (Select challenge, Why should we review this?).
class StarRadioCard<T> extends StatelessWidget {
  const StarRadioCard({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<StarRadioOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return StarDividedCard(
      children: [
        for (final option in options)
          _RadioRow(
            option: option,
            selected: option.value == selected,
            onTap: option.enabled ? () => onChanged(option.value) : null,
          ),
      ],
    );
  }
}

class _RadioRow<T> extends StatelessWidget {
  const _RadioRow({required this.option, required this.selected, required this.onTap});

  final StarRadioOption<T> option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: option.enabled,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: option.enabled ? 1 : 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              spacing: 12,
              children: [
                StarRadioDot(selected: selected),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      Text(
                        option.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          height: 1.2,
                          letterSpacing: 0,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      if (option.subtitle != null)
                        Text(
                          option.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.2,
                            letterSpacing: 0,
                            fontSize: 12,
                            color: AppColors.textSubtle,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 22px radio indicator.
class StarRadioDot extends StatelessWidget {
  const StarRadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: selected
            ? Border.all(color: AppColors.brandBlue, width: 2)
            : Border.all(color: AppColors.borderControl, width: 1.5),
      ),
      child: selected
          ? const DecoratedBox(
              decoration: BoxDecoration(color: AppColors.brandBlue, shape: BoxShape.circle),
              child: SizedBox.square(dimension: 12),
            )
          : null,
    );
  }
}
