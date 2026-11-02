import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/creator_profile.dart';
import 'package:starapp/features/profile/presentation/widgets/creator_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_image.dart';
import 'package:starapp/shared/widgets/star_tabs.dart';

enum _Tab {
  content('Content'),
  challenges('Challenges'),
  stats('Stats');

  const _Tab(this.label);

  final String label;
}

/// "Content Tabs": Content (video grid), Challenges (results) and Stats
/// (performance cards), switched in place. [posts] loads apart from the
/// profile, a page at a time.
class CreatorContentTabs extends StatefulWidget {
  const CreatorContentTabs({
    super.key,
    required this.profile,
    required this.posts,
    required this.onRetryPosts,
    required this.onOpenPost,
    required this.onOpenChallenge,
  });

  final CreatorProfile profile;
  final AsyncValue<List<CreatorPost>> posts;
  final VoidCallback onRetryPosts;
  final ValueChanged<CreatorPost> onOpenPost;
  final ValueChanged<CreatorChallengeEntry> onOpenChallenge;

  @override
  State<CreatorContentTabs> createState() => _CreatorContentTabsState();
}

class _CreatorContentTabsState extends State<CreatorContentTabs> {
  var _tab = _Tab.content;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final body = switch (_tab) {
      _Tab.content => StarAsyncView(
        value: widget.posts,
        onRetry: widget.onRetryPosts,
        builder: (posts) => _PostGrid(posts: posts, onOpen: widget.onOpenPost),
      ),
      _Tab.challenges => _ChallengeList(
        results: profile.challenges,
        onOpen: widget.onOpenChallenge,
      ),
      _Tab.stats => _StatGrid(stats: profile.stats, wins: profile.wins),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          StarTabBar(
            tabs: [for (final tab in _Tab.values) StarTab(label: tab.label)],
            selected: _tab.index,
            onSelected: (i) => setState(() => _tab = _Tab.values[i]),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: KeyedSubtree(key: ValueKey(_tab), child: body),
          ),
        ],
      ),
    );
  }
}

/// Three-across grid of 150px video thumbnails.
class _PostGrid extends StatelessWidget {
  const _PostGrid({required this.posts, required this.onOpen});

  final List<CreatorPost> posts;
  final ValueChanged<CreatorPost> onOpen;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const _Empty(message: 'No posts yet.');
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 8) / 3;
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final post in posts)
              SizedBox(
                width: width,
                height: 150,
                child: _Thumbnail(post: post, onTap: () => onOpen(post)),
              ),
          ],
        );
      },
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.post, required this.onTap});

  final CreatorPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final views = formatCompact(post.views);
    return Semantics(
      button: true,
      label: '${post.isEntry ? 'Challenge entry, ' : ''}$views views',
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              StarImage(post.thumbnailUrl),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 75,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x0007090D), CreatorColors.thumbScrim],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  spacing: 4,
                  children: [
                    SvgPicture.asset(CreatorIcons.play, width: 10, height: 10),
                    Flexible(
                      child: Text(
                        views,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          height: creatorLeading,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (post.isEntry)
                const Positioned(top: 8, left: 8, child: _EntryPill()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gold "🏆 Entry" pill on challenge entries.
class _EntryPill extends StatelessWidget {
  const _EntryPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment(-0.34, -0.94),
          end: Alignment(0.34, 0.94),
          colors: [AppColors.goldLight, AppColors.gold, AppColors.goldDeep],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SizedBox.square(
            dimension: 11,
            child: OverflowBox(
              maxWidth: 11.767,
              maxHeight: 11.767,
              child: SvgPicture.asset(
                CreatorIcons.entryTrophy,
                width: 11.767,
                height: 11.767,
              ),
            ),
          ),
          const Text(
            'Entry',
            style: TextStyle(
              fontSize: 10,
              height: creatorLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              color: AppColors.inkDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeList extends StatelessWidget {
  const _ChallengeList({required this.results, required this.onOpen});

  final List<CreatorChallengeEntry> results;
  final ValueChanged<CreatorChallengeEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const _Empty(message: 'No challenges yet.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        for (final result in results)
          _ChallengeRow(result: result, onTap: () => onOpen(result)),
      ],
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.result, required this.onTap});

  final CreatorChallengeEntry result;
  final VoidCallback onTap;

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: _radius,
        side: BorderSide(color: AppColors.borderField),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CreatorColors.goldTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  CreatorIcons.trophyTile,
                  width: 20,
                  height: 20,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      result.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: creatorLeading,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      result.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: creatorLeading,
                        letterSpacing: 0,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CreatorColors.goldTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  result.badge,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 10,
                    height: creatorLeading,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.goldText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-across performance cards; each keeps its own height.
class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats, required this.wins});

  final CreatorStats? stats;
  final int wins;

  @override
  Widget build(BuildContext context) {
    final stats = this.stats;
    if (stats == null) return const _Empty(message: 'No stats yet.');
    final firstWin = stats.firstWinAt;
    final cards = [
      (
        label: 'Views · 30 days',
        value: formatCompact(stats.views30d),
        note: formatChange(stats.viewsChange),
      ),
      (
        label: 'Avg. watch time',
        value: formatRatio(stats.watchRatio),
        note: null,
      ),
      (
        label: 'Challenge wins',
        value: '$wins',
        note: firstWin != null
            ? 'Since ${DateFormat('MMM y').format(firstWin)}'
            : stats.entries == 1
            ? '1 entry'
            : '${stats.entries} entries',
      ),
      (
        label: 'Top category',
        value: stats.topCategory,
        note: stats.topSubcategory,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 13) / 2;
        return Wrap(
          spacing: 13,
          runSpacing: 13,
          children: [
            for (final card in cards)
              SizedBox(
                width: width,
                child: _StatCard(
                  label: card.label,
                  value: card.value,
                  note: card.note,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.note});

  final String label;
  final String value;

  /// Green line under the value, e.g. "+18%".
  final String? note;

  @override
  Widget build(BuildContext context) {
    final note = this.note;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CreatorColors.statCardBorder),
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
              height: creatorLeading,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              color: CreatorColors.statLabel,
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
                height: creatorLeading,
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
              style: const TextStyle(
                fontSize: 12,
                height: creatorLeading,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: CreatorColors.statNote,
              ),
            ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

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
          height: creatorLeading,
          letterSpacing: 0,
          color: AppColors.textSubtle,
        ),
      ),
    );
  }
}
