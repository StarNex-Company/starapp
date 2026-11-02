import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/profile/data/provider/insights_providers.dart';
import 'package:starapp/features/profile/data/provider/my_post_providers.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_post_row.dart';
import 'package:starapp/features/profile/presentation/widgets/insights_style.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_icon_button.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// "Profile — Top Posts": every post, best performing first. A row opens the
/// post.
class TopPostsPage extends ConsumerWidget {
  const TopPostsPage({super.key});

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profileInsights);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deleted = ref.watch(myPostInteractionsProvider).deleted;
    final posts = ref
        .watch(topPostsProvider)
        .whenData(
          (posts) => [
            for (final post in posts)
              if (!deleted.contains(post.id)) post,
          ],
        );
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StarScreenHeader(
        title: 'Top posts',
        leading: StarIconButton.back(onPressed: () => _back(context)),
      ),
      body: StarAsyncView(
        value: posts,
        onRetry: () => ref.invalidate(topPostsProvider),
        builder: (posts) {
          if (posts.isEmpty) return const _Empty();
          return NotificationListener<ScrollUpdateNotification>(
            // Fetch the next page as the end comes into view.
            onNotification: (scroll) {
              if (scroll.metrics.extentAfter < 400) {
                ref.read(topPostsProvider.notifier).loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(24, 25, 24, bottom),
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => InsightsPostRow(
                key: ValueKey(posts[i].id),
                post: posts[i],
                onTap: () =>
                    context.push('${AppRoutes.post}?id=${posts[i].id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Text(
        'Your posts will show here once you share them.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          height: insightsLeading,
          letterSpacing: 0,
          color: AppColors.textSubtle,
        ),
      ),
    );
  }
}
