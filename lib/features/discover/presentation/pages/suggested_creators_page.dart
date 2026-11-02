import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/navigation/creator_navigation.dart';
import 'package:starapp/core/session/data/provider/session_providers.dart';
import 'package:starapp/features/discover/data/provider/discover_providers.dart';
import 'package:starapp/features/discover/presentation/widgets/discover_style.dart';
import 'package:starapp/features/discover/presentation/widgets/suggested_creator_row.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';
import 'package:starapp/shared/widgets/star_screen_header.dart';

/// "Suggested for you": every creator suggested on Discover, with Follow
/// toggles. Pushed inside the Discover tab, so the bottom navigation stays.
class SuggestedCreatorsPage extends ConsumerWidget {
  const SuggestedCreatorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggested = ref.watch(suggestedCreatorsProvider);
    final following = ref.watch(followingProvider);
    final follows = ref.read(followingProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const StarScreenHeader(
        title: 'Suggested for you',
        leading: StarBackButton(),
      ),
      body: StarAsyncView(
        value: suggested,
        onRetry: () => ref.invalidate(suggestedCreatorsProvider),
        builder: (creators) => ListView(
          // Bottom inset clears the nav bar the shell floats over us.
          padding: EdgeInsets.fromLTRB(
            24,
            25,
            24,
            MediaQuery.paddingOf(context).bottom + 16,
          ),
          children: [
            Semantics(
              header: true,
              child: Text(
                'Based on your talents',
                style: discoverText(18, FontWeight.w600, AppColors.brandBlue),
              ),
            ),
            for (final suggestion in creators) ...[
              const SizedBox(height: 12),
              SuggestedCreatorRow(
                suggestion: suggestion,
                following: following.contains(suggestion.id),
                onFollow: () => follows.toggle(suggestion.id),
                onTap: () => context.pushCreator(suggestion.id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
