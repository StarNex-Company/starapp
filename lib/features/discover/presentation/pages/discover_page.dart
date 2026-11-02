import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/discover/data/models/discover_models.dart';
import 'package:starapp/features/discover/data/provider/discover_providers.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_category_chips.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_filters_sheet.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_search_field.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_section_header.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_video_card.dart';
import 'package:starapp/features/discover/presentation/widgets/featured_challenge_card.dart';
import 'package:starapp/features/discover/presentation/widgets/rising_creators_rail.dart';
import 'package:starapp/features/discover/presentation/widgets/suggested_creator_card.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

// Vertical gap between the page's sections.
const _sectionGap = 19.0;

// Suggestions shown in the carousel; dismissing one brings in the next.
const _carouselSize = 4;

// How close to the bottom (in px) the next page of videos starts loading.
const _loadMoreExtent = 600.0;

/// Discover tab: search, talent categories, rising creators' stories,
/// suggested creators, featured challenges and a grid of talent videos.
/// Hosted by `MainShell`, which floats the bottom navigation over it.
class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  Future<void> _openFilters() async {
    final filters = await showDiscoverFiltersSheet(
      context,
      initial: ref.read(discoverFiltersProvider),
    );
    if (filters != null && mounted) {
      ref.read(discoverFiltersProvider.notifier).apply(filters);
    }
  }

  /// Shows [message] at once and runs [mutation], which updates the screen
  /// first and rolls back if the server rejects it; then the error shows.
  Future<void> _optimistic(String message, Future<void> mutation) async {
    showStarToast(context, message);
    try {
      await mutation;
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  void _dismiss(SuggestedCreator suggestion) => _optimistic(
    'Suggestion hidden',
    ref.read(suggestedCreatorsProvider.notifier).dismiss(suggestion.id),
  );

  void _toggleBookmark(DiscoverVideo video) => _optimistic(
    video.isSaved ? 'Removed from bookmarks' : 'Saved to your bookmarks',
    ref.read(discoverVideosProvider.notifier).toggleSaved(video.id),
  );

  /// Loads the next page of videos as the grid's end comes into view.
  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical &&
        notification.metrics.extentAfter < _loadMoreExtent) {
      ref.read(discoverVideosProvider.notifier).loadMore().ignore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(discoverCategoriesProvider);
    final category = ref.watch(discoverCategoryProvider);
    final risingCreators = ref.watch(risingCreatorsProvider);
    final userAvatar = ref.watch(
      currentUserProvider.select((user) => user.value?.avatarUrl),
    );
    final suggested = ref.watch(suggestedCreatorsProvider);
    final challenges = ref.watch(featuredChallengesProvider);
    final videos = ref.watch(discoverVideosProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Discover',
        leading: Semantics(
          label: 'StarApp',
          image: true,
          child: SvgPicture.asset(DiscoverIcons.logo, width: 28, height: 24),
        ),
        trailing: Tooltip(
          message: 'Filters',
          child: StarIconButton(
            icon: DiscoverIcons.filter,
            iconSize: 20,
            onPressed: _openFilters,
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ListView(
          // Bottom inset clears the nav bar the shell floats over us.
          padding: EdgeInsets.only(
            top: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DiscoverSearchField(
                onTap: () => context.push(AppRoutes.search),
              ),
            ),
            const SizedBox(height: _sectionGap),
            StarAsyncView(
              value: categories,
              onRetry: () => ref.invalidate(discoverCategoriesProvider),
              builder: (categories) => DiscoverCategoryChips(
                categories: categories,
                selected: category,
                onSelected: ref.read(discoverCategoryProvider.notifier).select,
              ),
            ),
            const SizedBox(height: _sectionGap),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: DiscoverSectionHeader.caps(
                title: 'Rising Creators',
                action: '24h Stories',
              ),
            ),
            const SizedBox(height: 10),
            StarAsyncView(
              value: risingCreators,
              onRetry: () => ref.invalidate(risingCreatorsProvider),
              builder: (creators) => RisingCreatorsRail(
                userAvatarUrl: userAvatar,
                creators: creators,
                onAddStory: () => context.push(AppRoutes.storyCreate),
                onOpenStory: (c) =>
                    context.push('${AppRoutes.story}?creator=${c.storyKey}'),
              ),
            ),
            StarAsyncView(
              value: suggested,
              onRetry: () => ref.invalidate(suggestedCreatorsProvider),
              builder: _suggestedSection,
            ),
            const SizedBox(height: _sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DiscoverSectionHeader.caps(
                title: 'Featured challenges',
                action: 'View All',
                onAction: () => context.go(AppRoutes.challenges),
              ),
            ),
            const SizedBox(height: 10),
            StarAsyncView(
              value: challenges,
              onRetry: () => ref.invalidate(featuredChallengesProvider),
              builder: (challenges) => SizedBox(
                height: FeaturedChallengeCard.height,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: challenges.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 15),
                  itemBuilder: (_, i) => FeaturedChallengeCard(
                    challenge: challenges[i],
                    onOpen: () => context.push(AppRoutes.challengeDetail),
                    onEnter: () => context.push(AppRoutes.challengeDetail),
                  ),
                ),
              ),
            ),
            const SizedBox(height: _sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: StarAsyncView(
                value: videos,
                onRetry: () => ref.invalidate(discoverVideosProvider),
                builder: (videos) => _VideoGrid(
                  videos: videos,
                  onOpen: (_) => context.push(AppRoutes.videos),
                  onBookmark: _toggleBookmark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Suggested Creators" heading and carousel; gone once all are dismissed.
  Widget _suggestedSection(List<SuggestedCreator> creators) {
    final shown = creators.take(_carouselSize).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    final following = ref.watch(followingProvider);
    final follows = ref.read(followingProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: _sectionGap),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DiscoverSectionHeader(
            title: 'Suggested Creators',
            action: 'See All',
            onAction: () => context.push(AppRoutes.discoverSuggested),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: SuggestedCreatorCard.height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: shown.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final suggestion = shown[i];
              return SuggestedCreatorCard(
                key: ValueKey(suggestion.id),
                suggestion: suggestion,
                following: following.contains(suggestion.id),
                onFollow: () => follows.toggle(suggestion.id),
                onDismiss: () => _dismiss(suggestion),
                onTap: () => context.pushCreator(suggestion.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Two-column grid of video thumbnails.
class _VideoGrid extends StatelessWidget {
  const _VideoGrid({
    required this.videos,
    required this.onOpen,
    required this.onBookmark,
  });

  final List<DiscoverVideo> videos;
  final ValueChanged<DiscoverVideo> onOpen;
  final ValueChanged<DiscoverVideo> onBookmark;

  @override
  Widget build(BuildContext context) {
    Widget cell(int i) => i >= videos.length
        ? const SizedBox.shrink()
        : DiscoverVideoCard(
            video: videos[i],
            onTap: () => onOpen(videos[i]),
            onBookmark: () => onBookmark(videos[i]),
          );

    return Column(
      spacing: 16,
      children: [
        for (var i = 0; i < videos.length; i += 2)
          Row(
            spacing: 16,
            children: [
              Expanded(child: cell(i)),
              Expanded(child: cell(i + 1)),
            ],
          ),
      ],
    );
  }
}
