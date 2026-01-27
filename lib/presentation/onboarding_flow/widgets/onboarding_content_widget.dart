import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Reusable content widget for onboarding screens.
/// Displays hero illustration, title, and subtitle in vertical layout.
class OnboardingContentWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String illustrationUrl;
  final String semanticLabel;

  const OnboardingContentWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustrationUrl,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero illustration (top third)
            Container(
              height: 30.h,
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 4.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: CustomImageWidget(
                  imageUrl: illustrationUrl,
                  width: double.infinity,
                  height: 30.h,
                  fit: BoxFit.cover,
                  semanticLabel: semanticLabel,
                ),
              ),
            ),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 2.h),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            SizedBox(height: 4.h),

            // Feature preview cards
            _buildFeatureCard(
              context,
              icon: 'speed',
              title: 'Live Metrics',
              description: 'Real-time bat speed and bowling velocity tracking',
            ),

            SizedBox(height: 2.h),

            _buildFeatureCard(
              context,
              icon: 'summarize',
              title: 'Session Summaries',
              description: 'Auto-generated performance analysis and insights',
            ),

            SizedBox(height: 2.h),

            _buildFeatureCard(
              context,
              icon: 'person',
              title: 'Player Profiles',
              description: 'Multi-player management with role assignment',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
