# Star App

Flutter client for Star App, a talent platform. Creators post videos, enter challenges, earn Stars and get discovered by verified companies through Scout.

## Requirements

- Flutter 3.44 (stable) or later, with Dart `^3.12.2`
- Xcode for iOS, Android Studio / SDK for Android

## Getting started

```sh
flutter pub get
flutter run
```

The app runs on built-in mock data by default, so no backend is needed.

### Against the API

```sh
flutter run --dart-define=USE_MOCK_DATA=false \
            --dart-define=API_BASE_URL=https://api.example.com/v1
```

Each feature has a mock repository and an API repository behind the same interface; this flag picks which one is used. The mock fixtures are the JSON each screen expects from the API. [docs/ARCHITECTURE_STRUCTURE.md](docs/ARCHITECTURE_STRUCTURE.md) maps where everything lives and how to add a feature. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for:
- the data layer and endpoints
- error handling
- navigation rules
- the shared UI components
- what still needs native plugins or backend work before launch

## Tests

```sh
flutter analyze
flutter test
```

`test/app/shell_navigation_test.dart` drives the real router through every route. Each feature has model tests: its fixtures parse, and `toJson`/`fromJson` round-trip.

## Project layout

```
lib/
  app/        router, bottom-nav shell, theme, localization
  core/       API client, shared models, session, navigation helpers
  shared/     design-system widgets
  features/   one folder per feature: data (models, repositories,
              providers) and presentation (pages, widgets)
```

Features don't import each other. They meet through routes (`lib/core/constants/app_routes.dart`) and the shared `core` layer.

## Branches

- `main`: finished, verified work only.
- `develop`: ongoing work; commit here directly.

`develop` is merged into `main` once its work is verified and approved.
