import 'package:starapp/features/onboarding/data/models/onboarding_slide.dart';

/// Where the onboarding pages come from. Screens never use this directly:
/// they read `onboardingSlidesProvider`, so swapping
/// [MockOnboardingRepository] for a remote implementation in
/// `onboardingRepositoryProvider` is the only change needed.
abstract interface class OnboardingRepository {
  /// The carousel's pages, in order.
  Future<List<OnboardingSlide>> fetchSlides();
}

class MockOnboardingRepository implements OnboardingRepository {
  const MockOnboardingRepository();

  @override
  Future<List<OnboardingSlide>> fetchSlides() async => _slides;
}

/// Figma "Onboarding 1–3" (`50:146`, `438:5244`, `438:5270`).
const _slides = [
  OnboardingSlide(
    title: 'Show What Makes You Different',
    subtitle:
        'Share your talent, creativity, and ideas with people who love '
        'discovering new voices.',
    image: 'assets/images/ob1.png',
  ),
  OnboardingSlide(
    title: 'Grow Through Community',
    subtitle:
        'Build your audience, connect with communities, and gain '
        'recognition for what you create.',
    image: 'assets/images/ob2.png',
  ),
  OnboardingSlide(
    title: 'Your Stage Is Waiting',
    subtitle:
        'Share your creativity, explore opportunities, and grow your '
        'presence on a platform built for talent.',
    image: 'assets/images/ob3.png',
  ),
];
