import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/data/models/interest_category.dart';
import 'package:starapp/features/auth/data/provider/auth_providers.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_interest_chip.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_kit.dart';
import 'package:starapp/features/auth/presentation/widgets/auth_sticky_layout.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';

/// Onboarding "Choose Your Interests" (Figma "Interest" `286:1551`, route
/// [AppRoutes.registerInterests]).
///
/// Logo + language chip header; a sticky panel with the heading and a search
/// field that filters the chips as you type (a category whose name matches
/// shows all of its chips); the categories of toggle chips; and a sticky
/// Skip / Continue bar. Continue needs at least one interest and records the
/// choice in `registrationProvider` (Skip records none); both go on to the
/// Welcome Challenge. The categories come from `interestCategoriesProvider`.
class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key, this.initialSelection = const {}});

  /// Interests shown as already selected.
  final Set<String> initialSelection;

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> {
  late final Set<String> _selected = {...widget.initialSelection};
  String _query = '';

  static const _categoryTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.21,
    letterSpacing: 0,
    color: AppColors.voidBlack,
  );

  void _toggle(String interest) => setState(() {
    if (!_selected.remove(interest)) _selected.add(interest);
  });

  void _continue() {
    ref.read(registrationProvider.notifier).setInterests(_selected);
    _next();
  }

  void _skip() {
    ref.read(registrationProvider.notifier).setInterests(const {});
    _next();
  }

  void _next() => context.push(AppRoutes.welcomeChallenge);

  /// Categories (and their chips) of [categories] that match the search.
  List<InterestCategory> _visible(List<InterestCategory> categories) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return categories;
    return [
      for (final c in categories)
        if (c.title.toLowerCase().contains(q))
          c
        else if (c.interests.any((i) => i.toLowerCase().contains(q)))
          InterestCategory(c.title, [
            for (final i in c.interests)
              if (i.toLowerCase().contains(q)) i,
          ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(interestCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.lunarWhite,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: AuthStickyLayout(
          header: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeaderBar(),
                const SizedBox(height: 25),
                AuthStickyPanel(
                  children: [
                    const AuthHeading(
                      title: 'Choose Your Interests',
                      subtitle:
                          'Select topics, talents, and categories '
                          'you’d like to explore and share on Star App.',
                    ),
                    AuthSearchField(
                      hint: 'Search for your interest...',
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: StarAsyncView(
            value: categories,
            onRetry: () => ref.invalidate(interestCategoriesProvider),
            builder: (categories) {
              final visible = _visible(categories);
              if (visible.isEmpty) return _NoMatches(query: _query.trim());
              return ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                // The frame's content column is x 26–371 and starts 4px
                // below the panel with 10px top padding.
                padding: const EdgeInsets.fromLTRB(26, 14, 22, 24),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 25),
                itemBuilder: (context, index) {
                  final category = visible[index];
                  return Column(
                    key: ValueKey(category.title),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(category.title, style: _categoryTitle),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 13,
                        children: [
                          for (final interest in category.interests)
                            AuthInterestChip(
                              // Keyed so filtering doesn't hand one chip's
                              // state (and colour animation) to another.
                              key: ValueKey(interest),
                              label: interest,
                              selected: _selected.contains(interest),
                              onTap: () => _toggle(interest),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          bottomBar: AuthActionBar(
            secondary: AuthSecondaryButton(
              label: 'Skip',
              size: AuthButtonSize.compact,
              onPressed: _skip,
            ),
            primary: AuthPrimaryButton(
              label: 'Continue',
              size: AuthButtonSize.compact,
              onPressed: _selected.isEmpty ? null : _continue,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Text(
        'No interests match “$query”.',
        textAlign: TextAlign.center,
        style: AuthTextStyles.subtitle,
      ),
    );
  }
}
