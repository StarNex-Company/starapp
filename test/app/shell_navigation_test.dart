import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/router/app_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/challenges/presentation/pages/challenge_detail_page.dart';
import 'package:starapp/features/challenges/presentation/pages/challenges_hub_page.dart';
import 'package:starapp/features/challenges/presentation/pages/leaderboard_page.dart';
import 'package:starapp/features/challenges/presentation/pages/my_entries_page.dart';
import 'package:starapp/features/challenges/presentation/pages/tier_level_up_page.dart';
import 'package:starapp/features/challenges/presentation/pages/upcoming_challenges_page.dart';
import 'package:starapp/features/challenges/presentation/pages/winners_page.dart';
import 'package:starapp/features/discover/presentation/pages/discover_page.dart';
import 'package:starapp/features/discover/presentation/pages/suggested_creators_page.dart';
import 'package:starapp/features/home/presentation/pages/home_page.dart';
import 'package:starapp/features/messages/presentation/pages/attachment_viewer_page.dart';
import 'package:starapp/features/messages/presentation/pages/conversation_page.dart';
import 'package:starapp/features/messages/presentation/pages/messages_page.dart';
import 'package:starapp/features/messages/presentation/pages/new_message_page.dart';
import 'package:starapp/features/notifications/presentation/pages/notifications_page.dart';
import 'package:starapp/features/profile/presentation/pages/connections_page.dart';
import 'package:starapp/features/profile/presentation/pages/creator_profile_page.dart';
import 'package:starapp/features/profile/presentation/pages/my_post_page.dart';
import 'package:starapp/features/profile/presentation/pages/my_profile_page.dart';
import 'package:starapp/features/profile/presentation/pages/saved_page.dart';
import 'package:starapp/features/profile/presentation/pages/shortcuts_page.dart';
import 'package:starapp/features/profile/presentation/pages/star_insights_page.dart';
import 'package:starapp/features/profile/presentation/pages/talent_passport_page.dart';
import 'package:starapp/features/profile/presentation/pages/top_posts_page.dart';
import 'package:starapp/core/navigation/tab_navigation.dart';
import 'package:starapp/features/scout/presentation/pages/company_page.dart';
import 'package:starapp/features/scout/presentation/pages/my_applications_page.dart';
import 'package:starapp/features/scout/presentation/pages/open_call_page.dart';
import 'package:starapp/features/scout/presentation/pages/scout_marketplace_page.dart';
import 'package:starapp/features/scout/presentation/pages/scout_request_page.dart';
import 'package:starapp/features/scout/presentation/pages/scout_requests_page.dart';
import 'package:starapp/features/search/presentation/pages/search_page.dart';
import 'package:starapp/features/settings/presentation/pages/edit_profile_page.dart';
import 'package:starapp/features/settings/presentation/pages/privacy_security_page.dart';
import 'package:starapp/features/settings/presentation/pages/settings_page.dart';
import 'package:starapp/features/stories/presentation/pages/story_create_page.dart';
import 'package:starapp/features/stories/presentation/pages/story_viewer_page.dart';
import 'package:starapp/features/verification/presentation/pages/creator_verification_page.dart';
import 'package:starapp/features/verification/presentation/pages/verification_submitted_page.dart';
import 'package:starapp/features/videos/presentation/pages/videos_page.dart';
import 'package:starapp/features/wallet/presentation/pages/add_payout_method_page.dart';
import 'package:starapp/features/wallet/presentation/pages/payouts_page.dart';
import 'package:starapp/features/wallet/presentation/pages/statements_page.dart';
import 'package:starapp/features/wallet/presentation/pages/tax_info_page.dart';
import 'package:starapp/features/wallet/presentation/pages/transaction_page.dart';
import 'package:starapp/features/wallet/presentation/pages/wallet_activity_page.dart';
import 'package:starapp/features/wallet/presentation/pages/wallet_page.dart';
import 'package:starapp/features/wallet/presentation/pages/withdraw_page.dart';
import 'package:starapp/features/wallet/presentation/pages/withdrawal_sent_page.dart';
import 'package:starapp/shared/widgets/star_bottom_nav.dart';

Future<GoRouter> _pumpApp(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 62, bottom: 34);
  addTearDown(tester.view.reset);

  final router = createAppRouter(initialLocation: location);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await _settle(tester);
  return router;
}

// Pages here run endless animations (live board, countdown, confetti, video
// progress), so advance a fixed amount of time instead of pumpAndSettle.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

// Lets toasts finish, then unmounts so periodic timers are cancelled.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpWidget(const SizedBox());
}

void main() {
  testWidgets('accepting a Scout request opens its chat; the chat reaches '
      'the company through its mirror route', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.messages);

    router.push(AppRoutes.scoutRequest('sr-gbedu'));
    await _settle(tester);
    expect(find.byType(ScoutRequestPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsNothing);

    await tester.tap(find.text('Accept'));
    // The accept call answers inside the first settle; the chat builds on
    // the next frame.
    await _settle(tester);
    await _settle(tester);
    expect(find.byType(ConversationPage), findsOneWidget);

    // Full-screen page → tab page: must go through the mirror.
    final chat = tester.element(find.byType(ConversationPage));
    chat.pushInTab(AppRoutes.company('afrowave-records'));
    await _settle(tester);
    expect(find.byType(CompanyPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _unmount(tester);
  });

  testWidgets('wallet pages: a deal opens from Messages, payouts open from '
      'the full-screen Withdraw', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.scoutApplications);

    // Messages tab → a Profile-tab page opens inside the current tab.
    router.push(AppRoutes.walletTransaction('tx-scout-kora'));
    await _settle(tester);
    expect(find.byType(TransactionPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsOneWidget);

    router.go(AppRoutes.wallet);
    await _settle(tester);
    router.push(AppRoutes.walletWithdraw);
    await _settle(tester);
    expect(find.byType(WithdrawPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsNothing);

    final withdraw = tester.element(find.byType(WithdrawPage));
    withdraw.pushInTab(AppRoutes.payouts);
    await _settle(tester);
    expect(find.byType(PayoutsPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _unmount(tester);
  });

  testWidgets('tabs keep the nav and their own stacks', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.home);
    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.byTooltip('Challenges'));
    await _settle(tester);
    expect(find.byType(ChallengesHubPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsOneWidget);

    router.push(AppRoutes.challengesUpcoming);
    await _settle(tester);
    expect(find.byType(UpcomingChallengesPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsOneWidget);

    await tester.tap(find.byTooltip('Discover'));
    await _settle(tester);
    expect(find.byType(DiscoverPage), findsOneWidget);

    await tester.tap(find.byTooltip('Challenges'));
    await _settle(tester);
    expect(find.byType(UpcomingChallengesPage), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('the Videos tab opens the full-screen feed', (tester) async {
    await _pumpApp(tester, AppRoutes.home);

    await tester.tap(find.byTooltip('Videos'));
    await _settle(tester);

    expect(find.byType(VideosPage), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('the Profile tab keeps the nav', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.home);

    await tester.tap(find.byTooltip('Profile'));
    await _settle(tester);
    expect(find.byType(MyProfilePage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsOneWidget);

    router.push(AppRoutes.settings);
    await _settle(tester);
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsOneWidget);

    // Pages from another tab open inside this one.
    router.push(AppRoutes.challengesLeaderboard);
    await _settle(tester);
    expect(find.byType(LeaderboardPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('passport, edit and verification cover the nav', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.profile);

    for (final location in [
      AppRoutes.profilePassport,
      AppRoutes.editProfile,
      AppRoutes.verification,
    ]) {
      router.push(location);
      await _settle(tester);
      expect(find.byType(StarBottomNav), findsNothing, reason: location);

      router.pop();
      await _settle(tester);
      expect(find.byType(MyProfilePage), findsOneWidget, reason: location);
      expect(find.byType(StarBottomNav), findsOneWidget, reason: location);
    }

    await _unmount(tester);
  });

  testWidgets('the passport reaches tab pages without crashing', (
    tester,
  ) async {
    final router = await _pumpApp(tester, AppRoutes.profile);
    router.push(AppRoutes.profilePassport);
    await _settle(tester);

    final seeAll = find.text('See all').first;
    await tester.ensureVisible(seeAll);
    await tester.tap(seeAll);
    await _settle(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(TopPostsPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets('creator profiles open inside the current tab', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.discover);

    router.push('${AppRoutes.discover}/creator/nia');
    await _settle(tester);
    expect(find.byType(CreatorProfilePage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsOneWidget);

    await tester.tap(find.byTooltip('Home'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Discover'));
    await _settle(tester);
    expect(find.byType(CreatorProfilePage), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('the Messages tab opens the inbox', (tester) async {
    final router = await _pumpApp(tester, AppRoutes.home);

    await tester.tap(find.byTooltip('Messages'));
    await _settle(tester);
    expect(find.byType(MessagesPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsOneWidget);

    // A conversation covers the nav.
    router.push(AppRoutes.conversation('c-afrowave'));
    await _settle(tester);
    expect(find.byType(ConversationPage), findsOneWidget);
    expect(find.byType(StarBottomNav), findsNothing);
    expect(tester.takeException(), isNull);

    await _unmount(tester);
  });

  final pages = <String, Type>{
    AppRoutes.notifications: NotificationsPage,
    AppRoutes.discover: DiscoverPage,
    AppRoutes.discoverSuggested: SuggestedCreatorsPage,
    AppRoutes.challenges: ChallengesHubPage,
    AppRoutes.challengesLeaderboard: LeaderboardPage,
    '${AppRoutes.challengesLeaderboard}?view=all-time': LeaderboardPage,
    AppRoutes.challengesUpcoming: UpcomingChallengesPage,
    AppRoutes.challengesMyEntries: MyEntriesPage,
    AppRoutes.challengeDetail: ChallengeDetailPage,
    AppRoutes.challengeWinners: WinnersPage,
    AppRoutes.tierLevelUp: TierLevelUpPage,
    AppRoutes.search: SearchPage,
    AppRoutes.videos: VideosPage,
    '${AppRoutes.story}?creator=sarah': StoryViewerPage,
    AppRoutes.storyCreate: StoryCreatePage,
    AppRoutes.profile: MyProfilePage,
    AppRoutes.profileFollowers: ConnectionsPage,
    AppRoutes.profileFollowing: ConnectionsPage,
    AppRoutes.profileSaved: SavedPage,
    AppRoutes.profileInsights: StarInsightsPage,
    AppRoutes.profileTopPosts: TopPostsPage,
    AppRoutes.profilePassport: TalentPassportPage,
    AppRoutes.profileShortcuts: ShortcutsPage,
    AppRoutes.settings: SettingsPage,
    AppRoutes.settingsPrivacy: PrivacySecurityPage,
    AppRoutes.editProfile: EditProfilePage,
    AppRoutes.verification: CreatorVerificationPage,
    AppRoutes.verificationDone: VerificationSubmittedPage,
    '${AppRoutes.post}?id=gbedu-dance-cover': MyPostPage,
    '${AppRoutes.home}/creator/chidi': CreatorProfilePage,
    '${AppRoutes.challenges}/creator/gloria/followers': ConnectionsPage,
    '${AppRoutes.profile}/creator/ayeni/following': ConnectionsPage,
    '/creator/amina': CreatorProfilePage,
    AppRoutes.messages: MessagesPage,
    AppRoutes.newMessage: NewMessagePage,
    AppRoutes.messageRequests: ScoutRequestsPage,
    AppRoutes.scout: ScoutMarketplacePage,
    AppRoutes.scoutApplications: MyApplicationsPage,
    '/messages/scout/calls/gold-coast-tour': OpenCallPage,
    '/scout/calls/gold-coast-tour': OpenCallPage,
    '/messages/scout/companies/kora-studios': CompanyPage,
    '/scout/companies/kora-studios': CompanyPage,
    '/scout/requests/sr-kora-live': ScoutRequestPage,
    '/attachments/att-gbedu-brief': AttachmentViewerPage,
    '/new': NewMessagePage,
    AppRoutes.wallet: WalletPage,
    AppRoutes.walletActivity: WalletActivityPage,
    AppRoutes.walletStatements: StatementsPage,
    '/profile/wallet/transactions/tx-prize-afro-dance': TransactionPage,
    AppRoutes.walletWithdraw: WithdrawPage,
    '${AppRoutes.walletWithdrawSent}?ref=SA-WD-1': WithdrawalSentPage,
    AppRoutes.payouts: PayoutsPage,
    AppRoutes.payoutMethodNew: AddPayoutMethodPage,
    AppRoutes.payoutTax: TaxInfoPage,
    '/settings/payments': PayoutsPage,
    '/settings/payments/methods/new': AddPayoutMethodPage,
  };
  for (final MapEntry(key: location, value: page) in pages.entries) {
    testWidgets('$location renders without layout errors', (tester) async {
      await _pumpApp(tester, location);

      expect(find.byType(page), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _unmount(tester);
    });
  }
}
