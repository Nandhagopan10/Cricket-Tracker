import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'widgets/onboarding_content_widget.dart';

/// Onboarding Flow screen for cricket analytics application.
/// Implements minimal 1-2 screen introduction optimized for engineering students and coaches.
///
/// Features:
/// - Stack navigation with page indicator dots
/// - Skip option in top-right corner
/// - Animated cricket bat illustrations
/// - Swipe gestures for horizontal navigation
/// - Full-width action buttons in thumb zone
/// - Local storage flag for completion tracking
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skipOnboarding() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/bluetooth-connection-screen');
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/bluetooth-connection-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Page view content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    OnboardingContentWidget(
                      title: 'Real-time Cricket Analytics',
                      subtitle:
                          'Track your performance with wearable sensor integration. Get instant feedback on bat speed, swing angles, and bowling metrics during training sessions.',
                      illustrationUrl:
                          'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800&q=80',
                      semanticLabel:
                          'Cricket player in white uniform mid-swing with bat, demonstrating batting technique on outdoor cricket field',
                    ),
                    OnboardingContentWidget(
                      title: 'Comprehensive Performance Tracking',
                      subtitle:
                          'Access live metrics, detailed session summaries, and player profiles. Export data as CSV or PDF for coaching analysis and academic evaluation.',
                      illustrationUrl:
                          'https://images.unsplash.com/photo-1624526267942-ab0ff8a3e972?w=800&q=80',
                      semanticLabel:
                          'Cricket scoreboard and analytics dashboard showing performance metrics and statistics on digital display',
                    ),
                  ],
                ),
              ),

              // Page indicator
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 2,
                  effect: ExpandingDotsEffect(
                    activeDotColor: theme.colorScheme.primary,
                    dotColor: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    dotHeight: 1.h,
                    dotWidth: 2.w,
                    expansionFactor: 3,
                    spacing: 1.w,
                  ),
                ),
              ),

              // Navigation button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      _currentPage == 1 ? 'Get Started' : 'Next',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.25,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
