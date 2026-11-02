import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/core/utils/formatters.dart';
import 'package:starapp/features/profile/data/models/saved_item.dart';
import 'package:starapp/features/profile/data/provider/saved_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_filter_chips.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_grid_card.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_list_row.dart';
import 'package:starapp/features/profile/presentation/widgets/saved_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// The user's saved posts (Figma "Profile — Saved" / "Saved (List)"). Chips
/// filter by kind, the header action switches grid and list, a post opens
/// the video feed and its bookmark unsaves it.
class SavedPage extends ConsumerStatefulWidget {
  const SavedPage({super.key});

  @override
  ConsumerState<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends ConsumerState<SavedPage> {
  /// `null` = All.
  SavedKind? _filter;
  bool _asList = false;

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  void _open(SavedItem item) => context.push(AppRoutes.videos);

  Future<void> _unsave(SavedItem item) async {
    final unsave = ref.read(savedItemsProvider(_filter).notifier).unsave;
    showStarToast(context, 'Removed from Saved');
    try {
      await unsave(item.id);
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(savedItemsProvider(_filter));
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    final chips = SliverPadding(
      // The design's 20px top gap is measured from a 5px taller header than
      // StarScreenHeader.
      padding: const EdgeInsets.only(top: 25),
      sliver: SliverToBoxAdapter(
        child: SavedFilterChips(
          selected: _filter,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          onChanged: (kind) => setState(() => _filter = kind),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Saved',
        leading: StarIconButton.back(onPressed: _back),
        trailing: StarIconButton(
          icon: _asList ? SavedIcons.grid : SavedIcons.list,
          tooltip: _asList ? 'Show as grid' : 'Show as list',
          onPressed: () => setState(() => _asList = !_asList),
        ),
      ),
      // The chips stay put while a filter loads; only the list below waits.
      body: NotificationListener<ScrollUpdateNotification>(
        // Fetch the next page as the end comes into view.
        onNotification: (scroll) {
          if (scroll.metrics.extentAfter < 400) {
            ref.read(savedItemsProvider(_filter).notifier).loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            chips,
            if (saved.value case final page?) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    '${formatGrouped(page.total)} saved · only you can see '
                    'these',
                    style: const TextStyle(
                      fontSize: 13,
                      height: savedLeading,
                      letterSpacing: 0,
                      color: AppColors.textSubtle,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, bottom),
                sliver: page.items.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyState())
                    : _asList
                    ? _listSliver(page.items)
                    : _gridSliver(page.items),
              ),
            ] else
              SliverFillRemaining(
                hasScrollBody: false,
                child: StarAsyncView(
                  value: saved,
                  onRetry: () => ref.invalidate(savedItemsProvider(_filter)),
                  builder: (_) => const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _listSliver(List<SavedItem> items) {
    return SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => SavedListRow(
        key: ValueKey(items[i].id),
        item: items[i],
        onTap: () => _open(items[i]),
        onUnsave: () => _unsave(items[i]),
      ),
    );
  }

  /// Two columns, 13px apart, rows 16px apart. Built as rows rather than a
  /// fixed-ratio grid so tall text never clips.
  Widget _gridSliver(List<SavedItem> items) {
    final rows = (items.length / 2).ceil();
    return SliverList.separated(
      itemCount: rows,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, row) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 13,
        children: [
          for (var i = row * 2; i < row * 2 + 2; i++)
            Expanded(
              child: i < items.length
                  ? SavedGridCard(
                      key: ValueKey(items[i].id),
                      item: items[i],
                      onTap: () => _open(items[i]),
                      onUnsave: () => _unsave(items[i]),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 40),
      child: Text(
        'Nothing saved here yet.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          height: savedLeading,
          letterSpacing: 0,
          color: AppColors.textSubtle,
        ),
      ),
    );
  }
}
