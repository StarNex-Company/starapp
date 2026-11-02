import 'package:flutter/material.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';

/// Section title with an optional blue link on the right ("See All").
///
/// [DiscoverSectionHeader.caps] is the small uppercase label style
/// ("RISING CREATORS"); the default is the bolder sentence-case heading.
class DiscoverSectionHeader extends StatelessWidget {
  const DiscoverSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  }) : _caps = false;

  const DiscoverSectionHeader.caps({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  }) : _caps = true;

  final String title;
  final String? action;

  /// Null leaves [action] as a plain label.
  final VoidCallback? onAction;
  final bool _caps;

  @override
  Widget build(BuildContext context) {
    final titleStyle = _caps
        ? discoverText(
            12,
            FontWeight.w700,
            DiscoverColors.heading,
            lineHeight: 16,
            letterSpacing: 0.6,
          )
        : discoverText(
            14,
            FontWeight.w700,
            DiscoverColors.heading,
            lineHeight: 20,
            letterSpacing: -0.35,
          );
    // The caps header's plain label is a size smaller than its links.
    final actionStyle = discoverText(
      onAction == null ? 10 : 11,
      FontWeight.w600,
      DiscoverColors.brand,
      lineHeight: 14,
    );

    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              _caps ? title.toUpperCase() : title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
          ),
        ),
        if (action != null)
          onAction == null
              ? Text(action!, style: actionStyle)
              : Semantics(
                  button: true,
                  child: InkWell(
                    onTap: onAction,
                    borderRadius: BorderRadius.circular(4),
                    child: Text(action!, style: actionStyle),
                  ),
                ),
      ],
    );
  }
}
