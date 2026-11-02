import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/core/network/api_exception.dart';
import 'package:starapp/features/scout/data/models/open_call.dart';
import 'package:starapp/features/scout/data/models/open_call_filters.dart';
import 'package:starapp/features/scout/data/models/talent_category.dart';
import 'package:starapp/features/scout/data/provider/scout_providers.dart';
import 'package:starapp/features/scout/presentation/widgets/marketplace_header.dart';
import 'package:starapp/features/scout/presentation/widgets/open_call_cards.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_filters_sheet.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_style.dart';
import 'package:starapp/features/scout/presentation/widgets/scout_widgets.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_buttons.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';
import 'package:starapp/shared/widgets/star_toast.dart';

/// Scout Marketplace (Figma "Scout — Marketplace"), inside the Messages tab:
/// search, the applications summary, category chips, the featured call and
/// the open calls. Apply is one tap from any card; the header's sliders
/// open the filter sheet.
class ScoutMarketplacePage extends ConsumerStatefulWidget {
  const ScoutMarketplacePage({super.key});

  @override
  ConsumerState<ScoutMarketplacePage> createState() =>
      _ScoutMarketplacePageState();
}

class _ScoutMarketplacePageState extends ConsumerState<ScoutMarketplacePage> {
  late final TextEditingController _search;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(openCallFiltersProvider).query ?? '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  OpenCallFilters get _filters => ref.read(openCallFiltersProvider);

  void _setFilters(OpenCallFilters filters) =>
      ref.read(openCallFiltersProvider.notifier).set(filters);

  void _onSearch(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = text.trim();
      _setFilters(_filters.copyWith(query: query.isEmpty ? null : query));
    });
  }

  Future<void> _openFilters() async {
    final filters = await showScoutFiltersSheet(context, _filters);
    if (filters != null) _setFilters(filters);
  }

  void _resetFilters() {
    _debounce?.cancel();
    _search.clear();
    _setFilters(const OpenCallFilters());
  }

  void _openCall(OpenCallSummary call) =>
      context.push(AppRoutes.scoutCall(call.id));

  void _openApplications() => context.push(AppRoutes.scoutApplications);

  /// One-tap apply. A call the user can't apply to opens its page, which
  /// names the missing requirement.
  Future<void> _apply(OpenCallSummary call) async {
    if (!call.isEligible) return _openCall(call);
    try {
      await ref.read(scoutApplyProvider.notifier).apply(call.id);
    } catch (e) {
      if (mounted) showStarToast(context, describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(openCallFiltersProvider);
    final calls = ref.watch(openCallsProvider);
    final summary = ref.watch(applicationsSummaryProvider).value;
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Scout Marketplace',
        leading: StarIconButton.back(
          onPressed: () => scoutBack(context, AppRoutes.messages),
        ),
        trailing: StarIconButton(
          icon: ScoutIcons.sliders,
          tooltip: 'Filter open calls',
          onPressed: _openFilters,
        ),
      ),
      body: NotificationListener<ScrollUpdateNotification>(
        // Fetch the next page as the end comes into view.
        onNotification: (scroll) {
          if (scroll.metrics.extentAfter < 400) {
            ref.read(openCallsProvider.notifier).loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 25, 24, 16),
              sliver: SliverList.list(
                children: [
                  ScoutSearchField(controller: _search, onChanged: _onSearch),
                  const SizedBox(height: 16),
                  ScoutSegments(
                    applicationsCount: summary?.total,
                    onApplications: _openApplications,
                  ),
                  if (summary != null && summary.total > 0) ...[
                    const SizedBox(height: 16),
                    ApplicationsSummaryCard(
                      summary: summary,
                      onViewAll: _openApplications,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _CategoryChips(filters: filters, onChanged: _setFilters),
                ],
              ),
            ),
            ...calls.when(
              skipLoadingOnReload: true,
              data: (items) => _callSlivers(items, filters, bottom),
              loading: () => [_status(calls)],
              error: (_, _) => [_status(calls)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _status(AsyncValue<List<OpenCallSummary>> calls) => SliverToBoxAdapter(
    child: SizedBox(
      height: 240,
      child: StarAsyncView(
        value: calls,
        onRetry: () => ref.invalidate(openCallsProvider),
        builder: (_) => const SizedBox.shrink(),
      ),
    ),
  );

  List<Widget> _callSlivers(
    List<OpenCallSummary> items,
    OpenCallFilters filters,
    double bottom,
  ) {
    if (items.isEmpty) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, bottom),
          sliver: SliverToBoxAdapter(
            child: ScoutEmptyState(
              'No open calls match your search.',
              action: filters == const OpenCallFilters()
                  ? null
                  : StarTextButton(
                      label: 'Reset filters',
                      onPressed: _resetFilters,
                    ),
            ),
          ),
        ),
      ];
    }

    final apply = ref.watch(scoutApplyProvider);
    final featured = items.where((c) => c.isFeatured).firstOrNull;
    final rest = [
      for (final call in items)
        if (call != featured) call,
    ];
    final hasMore = ref.read(openCallsProvider.notifier).hasMore;

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverList.list(
          children: [
            if (featured != null) ...[
              FeaturedCallCard(
                call: featured,
                status: apply.statusOf(featured),
                applying: apply.isApplying(featured.id),
                onTap: () => _openCall(featured),
                onApply: () => _apply(featured),
              ),
              const SizedBox(height: 16),
            ],
            if (rest.isNotEmpty) ...[
              Semantics(
                header: true,
                child: Text(
                  'Open calls for you',
                  style: scoutText(
                    16,
                    weight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, bottom),
        sliver: SliverList.separated(
          itemCount: rest.length + (hasMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            if (i == rest.length) return const ScoutLoadingMore();
            final call = rest[i];
            return OpenCallRow(
              key: ValueKey(call.id),
              call: call,
              status: apply.statusOf(call),
              applying: apply.isApplying(call.id),
              onTap: () => _openCall(call),
              onApply: () => _apply(call),
            );
          },
        ),
      ),
    ];
  }
}

/// All, the categories, and Remote; clipped to the content width as in the
/// design.
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.filters, required this.onChanged});

  final OpenCallFilters filters;
  final ValueChanged<OpenCallFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        children: [
          ScoutChip(
            label: 'All',
            selected: filters.category == null,
            onTap: () => onChanged(filters.copyWith(category: null)),
          ),
          for (final category in TalentCategory.values) ...[
            const SizedBox(width: 4),
            ScoutChip(
              label: category.label,
              selected: filters.category == category,
              onTap: () => onChanged(filters.copyWith(category: category)),
            ),
          ],
          const SizedBox(width: 4),
          ScoutChip(
            label: 'Remote',
            selected: filters.remoteOnly,
            onTap: () => onChanged(
              filters.remoteOnly
                  ? filters.copyWith(remoteOnly: false)
                  : filters.copyWith(remoteOnly: true, city: null),
            ),
          ),
        ],
      ),
    );
  }
}
