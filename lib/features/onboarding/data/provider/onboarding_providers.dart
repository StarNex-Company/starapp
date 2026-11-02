import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starapp/features/onboarding/data/models/onboarding_slide.dart';
import 'package:starapp/features/onboarding/data/repositories/onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => const MockOnboardingRepository(),
);

/// The onboarding carousel's pages.
final onboardingSlidesProvider = FutureProvider<List<OnboardingSlide>>(
  (ref) => ref.watch(onboardingRepositoryProvider).fetchSlides(),
);
