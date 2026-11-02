# Star App architecture

How the app is put together and how to connect it to the backend. The data
layer is complete against mock data; going live means pointing it at the API.

## Running against the API

```sh
flutter run --dart-define=API_BASE_URL=https://api.example.com/v1 \
            --dart-define=USE_MOCK_DATA=false
```

`USE_MOCK_DATA` defaults to `true`. In that mode every repository provider
hands out its `Mock…Repository`. With `false`, they switch to
`Api…Repository`. See `lib/core/config/app_config.dart`.

## Layout

```
lib/
  app/        router, shell (bottom nav), theme, localization
  core/
    config/     AppConfig (base URL, mock switch)
    network/    ApiClient (Dio), ApiException, TokenStore, Paged<T>
    models/     entities shared by features: CreatorSummary, CreatorTier,
                Money/Currency, CompanySummary, Attachment
    session/    the signed-in user (currentUserProvider) and follows
                (followingProvider)
    navigation/ pushCreator, pushInTab
    utils/      json.dart (fromJson helpers), formatters.dart (display)
  shared/widgets/  design-system widgets (StarImage, StarAvatar, StarSheet,
                   showStarToast, StarAsyncView, buttons, headers…)
  features/<feature>/
    data/models/        immutable models with fromJson / toJson
    data/repositories/  <x>_repository.dart      interface
                        api_<x>_repository.dart  ApiClient implementation
                        mock_<x>_repository.dart JSON fixtures → fromJson
    data/provider/      Riverpod providers (hand-written, no codegen)
    presentation/pages/ one page per route
    presentation/widgets/
```

**Imports between features are not allowed.**
- A feature imports only `core`, `shared` and its own files.
- Features reach each other through routes in `lib/core/constants/app_routes.dart`.
- The `app` layer composes features.

## Data layer rules

**Models carry raw API values.**
- Numbers are `int`/`double`, never strings like `"48K"`.
- Times are `DateTime`.
- Money is `Money` (minor units plus currency).
- Images are URL strings named `…Url`.
- Enums are serialized by their Dart name.
- Formatting happens in widgets, through `core/utils/formatters.dart`: `formatCompact`, `formatGrouped`, `formatAgo`, `Money.format()`, and so on.

**JSON keys are camelCase** and match the field names. Every model has `fromJson` and `toJson`, written by hand with the helpers in `core/utils/json.dart`. These helpers are tolerant: missing lists come back empty, and unknown enum values fall back to a default. If the backend uses snake_case or wraps responses (`{"data": …}`), change it in one place:
- for wrapped responses, `ApiClient._unwrap`;
- for key naming, the model factories.

**Shared entities live in `core/models`, defined once.** For example:
- A person in any list is a `CreatorSummary`.
- A feature model that needs a person holds a `CreatorSummary`; it doesn't copy its fields.

**Repositories**
- Each repository is an `abstract interface class`.
- The provider picks the implementation:
  ```dart
  final xRepositoryProvider = Provider<XRepository>(
    (ref) => selectRepository(ref, mock: MockXRepository.new, api: ApiXRepository.new),
  );
  ```
- Screens never call a repository directly. They read providers.

**Mock repositories parse JSON fixtures through the real `fromJson`.** That means:
- Mock mode exercises the same parsing as production.
- Each fixture documents the response the screen expects from the API.
- Fixtures are kept to the minimum that shows every state the design has.
- Dates are relative to now.

**API repositories use conventional REST paths**, for example:
- `GET /me`, `GET /creators/{id}`, `PUT/DELETE /creators/{id}/follow`
- `GET /notifications?cursor=`

Paths are guesses until the backend contract exists. Each one is a single line in its `Api…Repository`.

**Lists that can grow return `Paged<T>`** (`{"items": [...], "nextCursor": …}`). The provider exposes `loadMore()`. `NotificationsNotifier` is the reference implementation.

**Mutations are optimistic.**
1. Update the state.
2. Call the API.
3. On failure, restore the previous state and rethrow.

The screen catches the error and shows `describeError(e)` in a `showStarToast`.

**Errors**
- `ApiClient` throws only `ApiException` subtypes: `NetworkException`, `UnauthorizedException`, `ValidationException` (which carries `fieldErrors`), `NotFoundException`, `ServerException` and others.
- `StarAsyncView` shows their message with a retry.
- A 401 clears the stored token, and the app routes to sign in (see `sessionExpiredProvider` in `main.dart`).

**Auth.** Sign-in stores the access token in `TokenStore` (secure storage). `ApiClient` sends it as `Authorization: Bearer …` on every request.

## Images

Draw content images with `StarImage(url)`, `StarAvatar(url, size:)` or `starImageProvider(url)`, never `Image.asset`/`Image.network` directly.
- Network URLs are cached on disk.
- Mock fixtures use asset paths, which these widgets also accept.
- A missing or broken image shows a neutral placeholder.

Bundled UI art (icons, logos, illustrations) stays in `assets/vectors` and `assets/images`.

## Tabs and filter pills

All tabs and single-choice filter rows use `lib/shared/widgets/star_tabs.dart`, styled after the Challenges hub.
- **`StarTabBar`:** a grey track with the selected tab on a white card. It takes optional icons and count badges.
  - `expand: true` (the default) fills the width.
  - `expand: false` hugs the labels and scrolls, for longer sets.
- **`StarChoiceChips`:** navy when selected, light grey otherwise. It scrolls, or wraps with `wrap: true`.
- **`StarPill`:** a single pill, for rows that aren't a single choice.

Don't build feature-specific tab or chip widgets. Only controls drawn over dark photo or video screens (camera, story camera roll, video feed) have their own style.

## Navigation

- Tabs are a `StatefulShellRoute`: Home, Discover, Challenges, Messages, Profile. Pages inside a tab keep the bottom nav.
- Full-screen pages sit on the root navigator: videos, stories, post, conversation, Scout request, withdraw, and others. They are either top-level routes or use `parentNavigatorKey: rootKey`.
- **A page on the root navigator cannot `push` a route that lives inside a tab** (go_router asserts). Use one of these instead:
  - `context.pushInTab(AppRoutes.x)` for the routes that have a top-level mirror (documented in `AppRoutes`),
  - `context.pushCreator(id)` for creator profiles,
  - `context.go(...)`, which switches tab.

## Tests

- `test/app/shell_navigation_test.dart` drives the real router.
- Each feature has model tests that parse its fixtures and round-trip `toJson`→`fromJson`.
- Run `flutter test` with the default test font. It surfaces overflows that large accessibility text would cause.

## Before launch: what isn't wired yet

The app is complete against mock data. These need native plugins or
backend work; each one is hidden or stubbed where the design shows it,
rather than faked.

| Capability | Where it shows | What's needed |
|---|---|---|
| Camera, gallery, file picking | Create, stories, chat attachments (photo/document), verification ID, edit-profile photo, appeal proof | e.g. `camera`, `image_picker`, `file_picker`; repositories already upload with `ApiClient.upload` |
| Video playback | Videos feed, posts | e.g. `video_player`; models carry `videoUrl` |
| Real-time chat | Conversations, inbox | `ApiMessagesRepository.watch*` polls every 5 s; swap in WebSockets/FCM there |
| Push notifications | — | FCM/APNs and deep links to the routes in `AppRoutes` |
| Voice / video calls | Conversation menu (rows hidden) | WebRTC provider, CallKit/ConnectionService |
| Add to calendar | Scout request (icon hidden) | e.g. `add_2_calendar` |
| Help centre | Withdraw "?", transaction "Get help" (hidden) | the Help screens |
| Withdrawal security | Withdraw | PIN/OTP/biometric step-up (not in the design) |

The backend must enforce every rule the app only displays: withdrawal
min/max/fees and the `Idempotency-Key`, eligibility, rate limits, and
signed short-lived URLs for statements and attachments.
