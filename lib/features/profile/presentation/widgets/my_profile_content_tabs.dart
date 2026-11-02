import 'package:flutter/material.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/my_profile.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_challenge_row.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_post_tile.dart';
import 'package:starapp/features/profile/presentation/widgets/my_profile_style.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

/// "Content Tabs" (Figma "Profile Tabs (Mine)"): My Content grid, Challenge
/// History rows and Stats cards. The selected tab is visual state only.
class MyProfileContentTabs extends StatefulWidget {
  const MyProfileContentTabs({
    super.key,
    required this.posts,
    required this.challenges,
    required this.stats,
    required this.onOpenPost,
    required this.onOpenChallenge,
    required this.onOpenInsights,
  });

  final List<ProfileGridPost> posts;
  final List<ChallengeHistoryEntry> challenges;
  final List<ProfileStat> stats;
  final ValueChanged<ProfileGridPost> onOpenPost;

  /// Null for entries that don't open anything (completed one-offs).
  final VoidCallback? Function(ChallengeHistoryEntry) onOpenChallenge;
  final VoidCallback onOpenInsights;

  static const tabs = ['My Content', 'Challenge History', 'Stats'];

  @override
  State<MyProfileContentTabs> createState() => _MyProfileContentTabsState();
}

class _MyProfileContentTabsState extends State<MyProfileContentTabs> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pane = switch (_tab) {
      0 => _PostsGrid(posts: widget.posts, onOpen: widget.onOpenPost),
      1 => _ChallengeHistory(
        entries: widget.challenges,
        onOpen: widget.onOpenChallenge,
      ),
      _ => _StatsGrid(
        stats: widget.stats,
        onOpenInsights: widget.onOpenInsights,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _TabBar(selected: _tab, onSelect: (i) => setState(() => _tab = i)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            children: [...previous, ?current],
          ),
          child: KeyedSubtree(key: ValueKey(_tab), child: pane),
        ),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => StarTabBar(
    tabs: [
      for (final label in MyProfileContentTabs.tabs) StarTab(label: label),
    ],
    selected: selected,
    onSelected: onSelect,
  );
}

/// Three-column grid of 112×150 thumbnails, 4px apart.
class _PostsGrid extends StatelessWidget {
  const _PostsGrid({required this.posts, required this.onOpen});

  final List<ProfileGridPost> posts;
  final ValueChanged<ProfileGridPost> onOpen;

  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const _Empty('No posts yet.');
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - _gap * 2) / 3;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final post in posts)
              SizedBox(
                width: width,
                height: width * 150 / 112.333,
                child: MyProfilePostTile(
                  key: ValueKey(post.id),
                  post: post,
                  onTap: () => onOpen(post),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChallengeHistory extends StatelessWidget {
  const _ChallengeHistory({required this.entries, required this.onOpen});

  final List<ChallengeHistoryEntry> entries;
  final VoidCallback? Function(ChallengeHistoryEntry) onOpen;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const _Empty('No challenges entered yet.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        for (final entry in entries)
          MyProfileChallengeRow(
            key: ValueKey(entry.id),
            entry: entry,
            onTap: onOpen(entry),
          ),
      ],
    );
  }
}

/// Two-column stat cards and the "Open Star Insights" button, 13px apart.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.onOpenInsights});

  final List<ProfileStat> stats;
  final VoidCallback onOpenInsights;

  static const _gap = 13.0;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (var i = 0; i < stats.length; i += 2)
        stats.sublist(i, i + 2 > stats.length ? stats.length : i + 2),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: _gap,
      children: [
        for (final row in rows)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: _gap,
              children: [
                for (final stat in row) Expanded(child: _StatCard(stat: stat)),
                if (row.length == 1) const Spacer(),
              ],
            ),
          ),
        StarPrimaryButton(
          label: 'Open Star Insights',
          onPressed: onOpenInsights,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    final (label, value, note) = _describe(stat);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyProfileColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: myProfileLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              color: MyProfileColors.textMuted,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 22,
                height: myProfileLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          if (note != null)
            Text(
              note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: myProfileLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: (stat.changePercent ?? 0) < 0 && !stat.isRecord
                    ? AppColors.danger
                    : MyProfileColors.positive,
              ),
            ),
        ],
      ),
    );
  }
}

/// A stat's label, its value as the card shows it and the note below.
(String, String, String?) _describe(ProfileStat stat) {
  final change = switch (stat.changePercent) {
    final percent? => formatChange(percent),
    null => null,
  };
  return switch (stat.kind) {
    ProfileStatKind.views => (
      'Views · 30 days',
      formatCompact(stat.value),
      change,
    ),
    ProfileStatKind.watchTime => ('Avg. watch time', '${stat.value}%', change),
    ProfileStatKind.starsThisMonth => (
      'Stars this month',
      '+${formatGrouped(stat.value)}',
      stat.isRecord ? 'Best month yet' : change,
    ),
    ProfileStatKind.topCategory => (
      'Top category',
      stat.category ?? '',
      '${stat.value}% of your Stars',
    ),
  };
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          height: myProfileLeading,
          letterSpacing: 0,
          color: AppColors.textSubtle,
        ),
      ),
    );
  }
}
