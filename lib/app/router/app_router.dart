import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/shell/main_shell.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/features/auth/presentation/pages/forgot_password.dart';
import 'package:starapp/features/auth/presentation/pages/interests.dart';
import 'package:starapp/features/auth/presentation/pages/language_selection.dart';
import 'package:starapp/features/auth/presentation/pages/new_password.dart';
import 'package:starapp/features/auth/presentation/pages/notification_permission.dart';
import 'package:starapp/features/auth/presentation/pages/otp_screen.dart';
import 'package:starapp/features/auth/presentation/pages/profile_picture.dart';
import 'package:starapp/features/auth/presentation/pages/secure_profile.dart';
import 'package:starapp/features/auth/presentation/pages/sign_in.dart';
import 'package:starapp/features/auth/presentation/pages/sign_up.dart';
import 'package:starapp/features/auth/presentation/pages/welcome.dart';
import 'package:starapp/features/auth/presentation/pages/welcome_challenge.dart';
import 'package:starapp/features/challenges/presentation/pages/challenge_detail_page.dart';
import 'package:starapp/features/challenges/presentation/pages/challenges_hub_page.dart';
import 'package:starapp/features/challenges/presentation/pages/leaderboard_page.dart';
import 'package:starapp/features/challenges/presentation/pages/my_entries_page.dart';
import 'package:starapp/features/challenges/presentation/pages/tier_level_up_page.dart';
import 'package:starapp/features/challenges/presentation/pages/upcoming_challenges_page.dart';
import 'package:starapp/features/challenges/presentation/pages/winners_page.dart';
import 'package:starapp/features/create/presentation/pages/camera_page.dart';
import 'package:starapp/features/create/presentation/pages/entry_submitted_page.dart';
import 'package:starapp/features/create/presentation/pages/preview_edit_page.dart';
import 'package:starapp/features/create/presentation/pages/submit_entry_page.dart';
import 'package:starapp/features/create/presentation/pages/uploading_page.dart';
import 'package:starapp/features/create/presentation/widgets/create_sheet.dart';
import 'package:starapp/features/discover/presentation/pages/discover_page.dart';
import 'package:starapp/features/discover/presentation/pages/suggested_creators_page.dart';
import 'package:starapp/features/home/presentation/pages/home_page.dart';
import 'package:starapp/features/messages/presentation/pages/attachment_viewer_page.dart';
import 'package:starapp/features/messages/presentation/pages/conversation_page.dart';
import 'package:starapp/features/messages/presentation/pages/messages_page.dart';
import 'package:starapp/features/messages/presentation/pages/new_message_page.dart';
import 'package:starapp/features/moderation/presentation/pages/appeal_page.dart';
import 'package:starapp/features/moderation/presentation/pages/appeal_submitted_page.dart';
import 'package:starapp/features/moderation/presentation/pages/content_paused_page.dart';
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
import 'package:starapp/features/splash/presentation/pages/splash_page.dart';
import 'package:starapp/features/stories/presentation/pages/story_create_page.dart';
import 'package:starapp/features/stories/presentation/pages/story_viewer_page.dart';
import 'package:starapp/features/verification/presentation/pages/creator_verification_page.dart';
import 'package:starapp/features/verification/presentation/pages/verification_submitted_page.dart';
import 'package:starapp/features/videos/data/models/feed_video.dart';
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
import 'package:starapp/features/onboarding/presentation/pages/onboarding_page.dart';

final GoRouter appRouter = createAppRouter();

/// A creator's profile with their followers/following lists. Nested under
/// each tab root (`creator/:id`) so the bottom nav stays, and at the top
/// level (`/creator/:id`) for pages outside the tabs.
GoRoute _creatorRoute(String path) => GoRoute(
  path: path,
  builder: (context, state) =>
      CreatorProfilePage(creatorId: state.pathParameters['id']!),
  routes: [
    GoRoute(
      path: 'followers',
      builder: (context, state) =>
          ConnectionsPage(creatorId: state.pathParameters['id']),
    ),
    GoRoute(
      path: 'following',
      builder: (context, state) => ConnectionsPage(
        creatorId: state.pathParameters['id'],
        showFollowing: true,
      ),
    ),
  ],
);

/// A shared message attachment; inside the Messages tab and mirrored at the
/// top level.
GoRoute _attachmentRoute(String path) => GoRoute(
  path: path,
  builder: (context, state) =>
      AttachmentViewerPage(attachmentId: state.pathParameters['id']!),
);

/// A Scout open call; inside the Messages tab and mirrored at the top level.
GoRoute _openCallRoute(String path) => GoRoute(
  path: path,
  builder: (context, state) =>
      OpenCallPage(callId: state.pathParameters['id']!),
);

/// A company's profile; inside the Messages tab and mirrored at the top level.
GoRoute _companyRoute(String path) => GoRoute(
  path: path,
  builder: (context, state) =>
      CompanyPage(companyId: state.pathParameters['id']!),
);

/// Payments & payouts with its add-method and tax pages; inside Settings and
/// mirrored at the top level (`/settings/payments`) for the full-screen
/// Withdraw page.
GoRoute _payoutsRoute(String path) => GoRoute(
  path: path,
  builder: (context, state) => const PayoutsPage(),
  routes: [
    GoRoute(
      path: 'methods/new',
      builder: (context, state) => const AddPayoutMethodPage(),
    ),
    GoRoute(path: 'tax', builder: (context, state) => const TaxInfoPage()),
  ],
);

/// [withId] when the URL carries `?[param]=`, otherwise [fallback] (the
/// page with its default id).
Widget _byId(
  GoRouterState state,
  Widget Function(String id) withId,
  Widget fallback, {
  String param = 'id',
}) => switch (state.uri.queryParameters[param]) {
  final id? => withId(id),
  null => fallback,
};

/// Builds the app's router; tests can start it at any [initialLocation].
GoRouter createAppRouter({String initialLocation = AppRoutes.splash}) {
  // Pages on this navigator cover the shell, bottom nav included. They can
  // push other root routes but must `go` to pages inside a tab.
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => OtpScreen(
          mode: OtpMode.fromQuery(state.uri.queryParameters['mode']),
        ),
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        builder: (context, state) => const NewPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),

      // Registration, after the OTP step
      GoRoute(
        path: AppRoutes.registerPassword,
        builder: (context, state) => const SecureProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerPhoto,
        builder: (context, state) => const ProfilePictureScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerInterests,
        builder: (context, state) => const InterestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcomeChallenge,
        builder: (context, state) => const WelcomeChallengeScreen(),
      ),
      GoRoute(
        path: AppRoutes.registerNotifications,
        builder: (context, state) => const NotificationPermissionScreen(),
      ),

      // Signed-in tabs. Pages inside a branch keep the bottom nav; routes
      // declared outside the shell open full screen over it.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) =>
                    HomePage(onCreate: () => showCreateSheet(context)),
                routes: [
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsPage(),
                  ),
                  _creatorRoute('creator/:id'),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverPage(),
                routes: [
                  GoRoute(
                    path: 'suggested',
                    builder: (context, state) => const SuggestedCreatorsPage(),
                  ),
                  _creatorRoute('creator/:id'),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.challenges,
                builder: (context, state) => const ChallengesHubPage(),
                routes: [
                  GoRoute(
                    path: 'leaderboard',
                    builder: (context, state) {
                      final view =
                          state.uri.queryParameters['view'] == 'all-time'
                          ? LeaderboardView.allTime
                          : LeaderboardView.thisChallenge;
                      return _byId(
                        state,
                        param: 'challenge',
                        (id) =>
                            LeaderboardPage(initialView: view, challengeId: id),
                        LeaderboardPage(initialView: view),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'upcoming',
                    builder: (context, state) => const UpcomingChallengesPage(),
                  ),
                  GoRoute(
                    path: 'my-entries',
                    builder: (context, state) => const MyEntriesPage(),
                  ),
                  _creatorRoute('creator/:id'),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const MyProfilePage(),
                routes: [
                  GoRoute(
                    path: 'followers',
                    builder: (context, state) => const ConnectionsPage(),
                  ),
                  GoRoute(
                    path: 'following',
                    builder: (context, state) =>
                        const ConnectionsPage(showFollowing: true),
                  ),
                  GoRoute(
                    path: 'saved',
                    builder: (context, state) => const SavedPage(),
                  ),
                  GoRoute(
                    path: 'insights',
                    builder: (context, state) => const StarInsightsPage(),
                  ),
                  GoRoute(
                    path: 'top-posts',
                    builder: (context, state) => const TopPostsPage(),
                  ),
                  GoRoute(
                    path: 'shortcuts',
                    builder: (context, state) => const ShortcutsPage(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsPage(),
                    routes: [
                      GoRoute(
                        path: 'privacy',
                        builder: (context, state) =>
                            const PrivacySecurityPage(),
                      ),
                      _payoutsRoute('payments'),
                    ],
                  ),
                  GoRoute(
                    path: 'wallet',
                    builder: (context, state) => const WalletPage(),
                    routes: [
                      GoRoute(
                        path: 'activity',
                        builder: (context, state) => const WalletActivityPage(),
                      ),
                      GoRoute(
                        path: 'statements',
                        builder: (context, state) => const StatementsPage(),
                      ),
                      GoRoute(
                        path: 'transactions/:id',
                        builder: (context, state) => TransactionPage(
                          transactionId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'withdraw',
                        parentNavigatorKey: rootKey,
                        builder: (context, state) => const WithdrawPage(),
                        routes: [
                          GoRoute(
                            path: 'sent',
                            parentNavigatorKey: rootKey,
                            builder: (context, state) => WithdrawalSentPage(
                              reference: state.uri.queryParameters['ref'] ?? '',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _creatorRoute('creator/:id'),

                  // Full screen over the shell: the design gives these their
                  // own bottom bars and no tab bar.
                  GoRoute(
                    path: 'passport',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => const TalentPassportPage(),
                  ),
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => const EditProfilePage(),
                  ),
                  GoRoute(
                    path: 'verification',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) =>
                        const CreatorVerificationPage(),
                    routes: [
                      GoRoute(
                        path: 'submitted',
                        parentNavigatorKey: rootKey,
                        builder: (context, state) =>
                            const VerificationSubmittedPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.messages,
                builder: (context, state) => const MessagesPage(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => NewMessagePage(
                      toUserId: state.uri.queryParameters['to'],
                    ),
                  ),
                  _attachmentRoute('attachments/:id'),
                  GoRoute(
                    path: 'requests',
                    builder: (context, state) => const ScoutRequestsPage(),
                  ),
                  GoRoute(
                    path: 'scout',
                    builder: (context, state) => const ScoutMarketplacePage(),
                    routes: [
                      GoRoute(
                        path: 'applications',
                        builder: (context, state) => const MyApplicationsPage(),
                      ),
                      _openCallRoute('calls/:id'),
                      _companyRoute('companies/:id'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Full screen over the shell
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) =>
            SearchPage(initialQuery: state.uri.queryParameters['q'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.videos,
        builder: (context, state) => VideosPage(
          initialFeed: state.uri.queryParameters['feed'] == 'following'
              ? VideosFeed.following
              : VideosFeed.forYou,
        ),
      ),
      GoRoute(
        path: AppRoutes.story,
        builder: (context, state) => StoryViewerPage(
          creator: state.uri.queryParameters['creator'] ?? 'adeboye',
        ),
      ),
      GoRoute(
        path: AppRoutes.storyCreate,
        builder: (context, state) => const StoryCreatePage(),
      ),
      _creatorRoute('/creator/:id'),
      GoRoute(
        path: '/scout/requests/:id',
        builder: (context, state) =>
            ScoutRequestPage(requestId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) =>
            ConversationPage(conversationId: state.pathParameters['id']!),
      ),

      // Top-level mirrors of tab pages, for full-screen pages to push with
      // `context.pushInTab` (see AppRoutes).
      _attachmentRoute('/attachments/:id'),
      _openCallRoute('/scout/calls/:id'),
      _payoutsRoute('/settings/payments'),
      _companyRoute('/scout/companies/:id'),
      GoRoute(
        path: '/new',
        builder: (context, state) =>
            NewMessagePage(toUserId: state.uri.queryParameters['to']),
      ),
      GoRoute(
        path: AppRoutes.post,
        builder: (context, state) => MyPostPage(
          postId: state.uri.queryParameters['id'] ?? 'late-night-vocal-run',
        ),
      ),

      // Challenges, full screen
      GoRoute(
        path: AppRoutes.challengeDetail,
        builder: (context, state) => _byId(
          state,
          (id) => ChallengeDetailPage(challengeId: id),
          const ChallengeDetailPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.challengeWinners,
        builder: (context, state) => _byId(
          state,
          (id) => WinnersPage(challengeId: id),
          const WinnersPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.tierLevelUp,
        builder: (context, state) => const TierLevelUpPage(),
      ),

      // Create & upload flow
      GoRoute(
        path: AppRoutes.createCamera,
        builder: (context, state) => const CameraPage(),
      ),
      GoRoute(
        path: AppRoutes.createPreview,
        builder: (context, state) => const PreviewEditPage(),
      ),
      GoRoute(
        path: AppRoutes.createSubmitEntry,
        builder: (context, state) => const SubmitEntryPage(),
      ),
      GoRoute(
        path: AppRoutes.createUploading,
        builder: (context, state) => const UploadingPage(),
      ),
      GoRoute(
        path: AppRoutes.createSubmitted,
        builder: (context, state) => const EntrySubmittedPage(),
      ),

      // Moderation
      GoRoute(
        path: AppRoutes.moderationPaused,
        builder: (context, state) => _byId(
          state,
          (id) => ContentPausedPage(caseId: id),
          const ContentPausedPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.moderationAppeal,
        builder: (context, state) =>
            _byId(state, (id) => AppealPage(caseId: id), const AppealPage()),
      ),
      GoRoute(
        path: AppRoutes.moderationAppealSubmitted,
        builder: (context, state) => _byId(
          state,
          (id) => AppealSubmittedPage(caseId: id),
          const AppealSubmittedPage(),
        ),
      ),
    ],
  );
}
