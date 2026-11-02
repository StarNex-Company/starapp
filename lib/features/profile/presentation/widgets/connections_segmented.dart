import 'package:flutter/material.dart';
import 'package:starapp/features/profile/data/models/connections.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// Followers / Following switcher with each list's size.
class ConnectionsSegmented extends StatelessWidget {
  const ConnectionsSegmented({
    super.key,
    required this.selected,
    required this.followers,
    required this.following,
    required this.onChanged,
  });

  final ConnectionsTab selected;
  final int followers;
  final int following;
  final ValueChanged<ConnectionsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return StarTabBar(
      tabs: [
        StarTab(label: 'Followers', count: followers),
        StarTab(label: 'Following', count: following),
      ],
      selected: selected.index,
      onSelected: (i) => onChanged(ConnectionsTab.values[i]),
    );
  }
}
