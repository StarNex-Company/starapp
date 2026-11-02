/// One page of the onboarding carousel.
class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final String title;
  final String subtitle;

  /// Full-screen artwork asset (the fade and rings are baked in).
  final String image;
}
