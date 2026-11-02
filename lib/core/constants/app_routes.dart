class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const welcome = '/';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const newPassword = '/new-password';
  static const language = '/language';
  static const home = '/home';

  // Registration, after OTP (the OTP screen takes `?mode=reset` for the
  // password-reset flow; registration is the default)
  static const registerPassword = '/register/password';
  static const registerPhoto = '/register/photo';
  static const registerInterests = '/register/interests';
  static const welcomeChallenge = '/register/welcome-challenge';
  static const registerNotifications = '/register/notifications';

  // Create & upload flow
  static const createCamera = '/create/camera';
  static const createPreview = '/create/preview';
  static const createSubmitEntry = '/create/submit-entry';
  static const createUploading = '/create/uploading';
  static const createSubmitted = '/create/submitted';

  // Moderation
  static const moderationPaused = '/moderation/paused';
  static const moderationAppeal = '/moderation/appeal';
  static const moderationAppealSubmitted = '/moderation/appeal-submitted';

  // Home tab (inside the bottom-nav shell)
  static const notifications = '/home/notifications';

  // Discover tab (inside the shell)
  static const discover = '/discover';
  static const discoverSuggested = '/discover/suggested';

  // Challenges tab (inside the shell): the hub is the tab's first page
  static const challenges = '/challenges';
  static const challengesLeaderboard = '/challenges/leaderboard';
  static const challengesUpcoming = '/challenges/upcoming';
  static const challengesMyEntries = '/challenges/my-entries';

  // Profile tab (inside the shell). Edit profile, the passport and
  // verification open full screen over it (no bottom nav).
  static const profile = '/profile';
  static const profileFollowers = '/profile/followers';
  static const profileFollowing = '/profile/following';
  static const profileSaved = '/profile/saved';
  static const profileInsights = '/profile/insights';
  static const profileTopPosts = '/profile/top-posts';
  static const profilePassport = '/profile/passport';
  static const profileShortcuts = '/profile/shortcuts';
  static const settings = '/profile/settings';
  static const settingsPrivacy = '/profile/settings/privacy';
  static const editProfile = '/profile/edit';
  static const verification = '/profile/verification';
  static const verificationDone = '/profile/verification/submitted';

  // Wallet (Profile tab). Withdraw and its confirmation open full screen.
  static const wallet = '/profile/wallet';
  static const walletActivity = '/profile/wallet/activity';
  static const walletStatements = '/profile/wallet/statements';
  static const walletWithdraw = '/profile/wallet/withdraw';
  static const walletWithdrawSent = '/profile/wallet/withdraw/sent'; // ?ref=
  static String walletTransaction(String id) =>
      '/profile/wallet/transactions/$id';

  // Payments & payouts (Settings). All three have top-level mirrors under
  // /settings/payments for the full-screen Withdraw page: link with
  // `context.pushInTab`.
  static const payouts = '/profile/settings/payments';
  static const payoutMethodNew = '/profile/settings/payments/methods/new';
  static const payoutTax = '/profile/settings/payments/tax';

  // Messages tab (inside the shell). Scout lives under it: the inbox's Scout
  // segment opens the marketplace.
  static const messages = '/messages';
  static const messageRequests = '/messages/requests';
  // ?to=<userId>; mirrored at /new for full-screen callers (pushInTab).
  static const newMessage = '/messages/new';
  static const scout = '/messages/scout';
  static const scoutApplications = '/messages/scout/applications';
  // These three also have top-level mirrors (`/scout/calls/:id`, …) for the
  // full-screen pages: link with `context.pushInTab`.
  static String scoutCall(String id) => '/messages/scout/calls/$id';
  static String company(String id) => '/messages/scout/companies/$id';
  static String attachment(String id) => '/messages/attachments/$id';

  // Full screen: a conversation and an incoming Scout request.
  static String conversation(String id) => '/chat/$id';
  static String scoutRequest(String id) => '/scout/requests/$id';

  // A creator's profile opens inside the current tab — use
  // `context.pushCreator(id)` (lib/core/navigation/creator_navigation.dart).
  // Each tab has `creator/:id` (+ `/followers`, `/following`) under its root,
  // plus a full-screen `/creator/:id` for pages outside the tabs.

  // Full screen over the shell
  static const search = '/search';
  static const videos = '/videos';
  static const story = '/story';
  static const storyCreate = '/story/create';
  static const post = '/post'; // ?id=<postId>, the user's own video

  // Challenges, full screen (outside the shell)
  // `?id=` picks the challenge (the leaderboard takes `?challenge=`); the
  // moderation pages take `?id=` for the case.
  static const challengeDetail = '/challenge';
  static const challengeWinners = '/challenge/winners';
  static const tierLevelUp = '/tiers/level-up';
}
