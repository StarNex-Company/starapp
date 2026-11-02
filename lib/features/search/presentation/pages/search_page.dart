import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/models/creator_summary.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/search/data/models/search_models.dart';
import 'package:starapp/features/search/data/provider/search_providers.dart';
import 'package:starapp/features/search/presentation/widgets/search_header.dart';
import 'package:starapp/features/search/presentation/widgets/search_recent_row.dart';
import 'package:starapp/features/search/presentation/widgets/search_result_rows.dart';
import 'package:starapp/features/search/presentation/widgets/search_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Full-screen search (Figma "Search — Home"). With an empty field it shows
/// recent searches and trending chips; typing switches to matching creators
/// and challenges.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialQuery = '', this.autofocus = true});

  /// Pre-fills the field, e.g. from a `?q=` link.
  final String initialQuery;

  /// Opens the keyboard on arrival, as the design shows.
  final bool autofocus;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _query;
  late final FocusNode _focus;

  /// Last results shown, kept on screen while the next query's load so
  /// typing doesn't flash a spinner.
  ({String query, SearchResults results})? _lastResults;

  @override
  void initState() {
    super.initState();
    // A valid caret up front, so autofocus doesn't pop a selection handle.
    _query = TextEditingController.fromValue(
      TextEditingValue(
        text: widget.initialQuery,
        selection: TextSelection.collapsed(offset: widget.initialQuery.length),
      ),
    )..addListener(_onQueryChanged);
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _query
      ..removeListener(_onQueryChanged)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  String _lastQuery = '';

  void _onQueryChanged() {
    final q = _query.text.trim();
    if (q == _lastQuery) return;
    _lastQuery = q;
    setState(() {});
  }

  void _close() {
    _focus.unfocus();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  /// Fills the field with [term], shows its results and records it. The
  /// keyboard closes so the results are in view.
  void _run(String term) {
    final text = term.trim();
    if (text.isEmpty) return;
    _focus.unfocus();
    _query.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    // History is best-effort: a failed save just leaves the list as it was.
    ref.read(recentSearchesProvider.notifier).add(text).ignore();
  }

  /// Runs a change to the recent searches, showing why if it fails.
  Future<void> _editRecent(Future<void> change) async {
    try {
      await change;
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.text.trim();
    final bottom = MediaQuery.viewPaddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SearchHeader(
        controller: _query,
        focusNode: _focus,
        autofocus: widget.autofocus,
        onBack: _close,
        onCancel: _close,
        onSubmitted: _run,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topLeft,
            children: [...previous, ?current],
          ),
          child: query.isEmpty ? _home() : _results(query),
        ),
      ),
    );
  }

  /// Empty field: recent searches and trending chips.
  Widget _home() {
    final recent = ref.watch(recentSearchesProvider);
    final trending = ref.watch(trendingSearchesProvider);
    final recentNotifier = ref.read(recentSearchesProvider.notifier);

    return Column(
      key: const ValueKey('home'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StarAsyncView(
          value: recent,
          onRetry: () => ref.invalidate(recentSearchesProvider),
          builder: (recent) => _RecentSearches(
            recent: recent,
            onTap: _run,
            onRemoved: (term) => _editRecent(recentNotifier.remove(term)),
            onClearAll: () => _editRecent(recentNotifier.clear()),
          ),
        ),
        const SizedBox(height: 12),
        const SearchSectionTitle('Trending searches'),
        const SizedBox(height: 12),
        StarAsyncView(
          value: trending,
          onRetry: () => ref.invalidate(trendingSearchesProvider),
          builder: (trending) =>
              _TrendingSearches(trending: trending, onTap: _run),
        ),
      ],
    );
  }

  /// Typed query: matching creators and challenges.
  Widget _results(String query) {
    final results = ref.watch(searchResultsProvider(query));
    final following = ref.watch(followingProvider);
    final followNotifier = ref.read(followingProvider.notifier);

    Widget view(String query, SearchResults results) => _Results(
      query: query,
      results: results,
      following: following,
      onCreatorTap: (c) => context.pushCreator(c.id),
      onFollowTap: (c) => followNotifier.toggle(c.id),
      onChallengeTap: (_) => context.push(AppRoutes.challengeDetail),
    );

    if (results.value case final value?) {
      _lastResults = (query: query, results: value);
    }
    final last = _lastResults;

    return StarAsyncView(
      key: const ValueKey('results'),
      value: results,
      onRetry: () => ref.invalidate(searchResultsProvider(query)),
      loading: last == null ? null : view(last.query, last.results),
      builder: (results) => view(query, results),
    );
  }
}

/// "Recent searches" heading and rows (or the cleared message).
class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.recent,
    required this.onTap,
    required this.onRemoved,
    required this.onClearAll,
  });

  final List<String> recent;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemoved;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(child: SearchSectionTitle('Recent searches')),
              if (recent.isNotEmpty) _ClearAllButton(onTap: onClearAll),
            ],
          ),
        ),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: SearchEmptyText(
              'No recent searches. Try a creator, talent or challenge.',
            ),
          )
        else
          for (final term in recent)
            SearchRecentRow(
              key: ValueKey(term),
              query: term,
              topGap: 12,
              onTap: () => onTap(term),
              onRemoved: () => onRemoved(term),
            ),
      ],
    );
  }
}

class _TrendingSearches extends StatelessWidget {
  const _TrendingSearches({required this.trending, required this.onTap});

  final List<String> trending;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final term in trending)
          SearchChip(label: term, onTap: () => onTap(term)),
      ],
    );
  }
}

class _ClearAllButton extends StatelessWidget {
  const _ClearAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'Clear all',
          style: TextStyle(
            fontSize: 13,
            height: searchLeading,
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            color: AppColors.brandNavy,
          ),
        ),
      ),
    );
  }
}

/// Typed query: matching creators and challenges (Figma "Discover — Search").
class _Results extends StatelessWidget {
  const _Results({
    required this.query,
    required this.results,
    required this.following,
    required this.onCreatorTap,
    required this.onFollowTap,
    required this.onChallengeTap,
  });

  final String query;
  final SearchResults results;

  /// Ids of followed creators.
  final Set<String> following;
  final ValueChanged<CreatorSummary> onCreatorTap;
  final ValueChanged<CreatorSummary> onFollowTap;
  final ValueChanged<SearchChallenge> onChallengeTap;

  @override
  Widget build(BuildContext context) {
    final SearchResults(:creators, :challenges) = results;

    if (results.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          const SearchSectionTitle('No results'),
          SearchEmptyText(
            'Nothing matches “$query”. Try a creator, talent or challenge.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (creators.isNotEmpty) ...[
          const SearchSectionTitle('Creators'),
          for (final c in creators)
            SearchCreatorRow(
              creator: c,
              following: following.contains(c.id),
              onTap: () => onCreatorTap(c),
              onFollowTap: () => onFollowTap(c),
            ),
        ],
        if (challenges.isNotEmpty) ...[
          const SearchSectionTitle('Challenges'),
          for (final c in challenges)
            SearchChallengeRow(challenge: c, onTap: () => onChallengeTap(c)),
        ],
      ],
    );
  }
}
