import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starapp/app/theme/app_theme.dart';
import 'package:starapp/core/constants/app_routes.dart';
import 'package:starapp/shared/widgets/auth_buttons.dart';
import 'package:starapp/features/onboarding/data/models/onboarding_slide.dart';
import 'package:starapp/features/onboarding/data/provider/onboarding_providers.dart';
import 'package:starapp/shared/widgets/star_async_view.dart';

/// Title: 37 Medium #000207, Inter "normal" line height.
const _titleStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 37,
  fontWeight: FontWeight.w500,
  height: 1.21,
  letterSpacing: 0,
  color: AppColors.voidBlack,
);

/// Subtitle: 16 Regular #000207, line height 24.
const _subtitleStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 24 / 16,
  letterSpacing: 0,
  color: AppColors.voidBlack,
);

/// Inactive page dot (Frame 47 "Ellipse 75/76").
const _dotIdle = Color(0xFF647BB4);

/// Onboarding (Figma "Onboarding 1–3": `50:146`, `438:5244`, `438:5270`).
///
/// Full-screen artwork per page (the fade and rings are baked into the
/// images), copy at 24px sides, page dots at y 695 and the action row at
/// y 757 (16 above the home indicator). Next / swipe advance; Skip and
/// Get Started go to [AppRoutes.welcome]. The pages' copy and artwork come
/// from `onboardingSlidesProvider`.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  /// Copy top above the page dots: the design puts the copy 158 above the
  /// dots on page 1 and 212 on the others.
  static double _copyLift(int page) => page == 0 ? 158 : 212;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(int count) {
    if (_page < count - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  void _skip() => context.go(AppRoutes.welcome);

  @override
  Widget build(BuildContext context) {
    final slides = ref.watch(onboardingSlidesProvider);

    return Scaffold(
      backgroundColor: AppColors.authWelcomeTint,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: StarAsyncView(
        value: slides,
        onRetry: () => ref.invalidate(onboardingSlidesProvider),
        // Just the tint (what shows until the artwork decodes) while loading.
        loading: const SizedBox.shrink(),
        builder: _buildSlides,
      ),
    );
  }

  Widget _buildSlides(List<OnboardingSlide> slides) {
    if (slides.isEmpty) return const SizedBox.shrink();
    final page = _page.clamp(0, slides.length - 1);
    final OnboardingSlide(:title, :subtitle) = slides[page];
    final copyLift = _copyLift(page);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final isLast = page == slides.length - 1;
    void next() => _next(slides.length);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen images
        PageView(
          controller: _controller,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            for (final OnboardingSlide(:image) in slides)
              SizedBox.expand(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) =>
                      const ColoredBox(color: AppColors.authWelcomeTint),
                ),
              ),
          ],
        ),

        // Copy, page dots and actions
        Positioned(
          left: 24,
          right: 24,
          bottom: bottom + 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Swipes on the copy and dots still page the images.
              IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Copy sits [copyLift] above the dots; taller copy
                    // (narrow screens, long translations) grows upward.
                    Container(
                      constraints: BoxConstraints(minHeight: copyLift),
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: _titleStyle),
                          const SizedBox(height: 12),
                          Text(subtitle, style: _subtitleStyle),
                        ],
                      ),
                    ),
                    Center(
                      child: _PageDots(
                        controller: _controller,
                        count: slides.length,
                        page: page,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 42),
              if (isLast)
                AuthPrimaryButton(
                  label: 'Get Started',
                  size: AuthButtonSize.compact,
                  onPressed: next,
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: AuthSecondaryButton(
                        label: 'Skip',
                        size: AuthButtonSize.compact,
                        onPressed: _skip,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AuthPrimaryButton(
                        label: 'Next',
                        size: AuthButtonSize.compact,
                        onPressed: next,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Page dots (Figma "Frame 47"): 10px dots 18 apart; the current page is a
/// 10×20 #001F6E oval, the others 10×10 #647BB4 — the Loading Bar look.
/// Follows the swipe, morphing between pages.
class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.controller,
    required this.count,
    required this.page,
  });

  final PageController controller;
  final int count;
  final int page;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${page + 1} of $count',
      child: SizedBox(
        width: 18.0 * (count - 1) + 10,
        height: 20,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final position = controller.hasClients
                ? controller.page ?? page.toDouble()
                : page.toDouble();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < count; i++)
                  _dot((1 - (position - i).abs()).clamp(0.0, 1.0)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// [t] = 1 for the current page, 0 for the others.
  Widget _dot(double t) => Container(
    width: 10,
    height: 10 + 10 * t,
    decoration: ShapeDecoration(
      color: Color.lerp(_dotIdle, AppColors.brandNavy, t),
      shape: const OvalBorder(),
    ),
  );
}
