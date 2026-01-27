import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';

/// Empty State Widget - Displays when no sessions are available
///
/// Features:
/// - Illustration with motivational message
/// - Call-to-action button to start first session
/// - Responsive design with proper spacing
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onStartSession;

  const EmptyStateWidget({super.key, required this.onStartSession});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomImageWidget(
              imageUrl:
                  'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=600',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              semanticLabel:
                  'Cricket player in action pose with bat raised, representing the start of training journey',
            ),
            const SizedBox(height: 32),
            Text(
              'No Sessions Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start your cricket analytics journey by recording your first training session',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onStartSession,
              icon: CustomIconWidget(
                iconName: 'add_circle',
                color:
                    theme.elevatedButtonTheme.style?.foregroundColor?.resolve(
                      {},
                    ) ??
                    Colors.white,
                size: 24,
              ),
              label: const Text('Start Your First Session'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed('/bluetooth-connection-screen');
              },
              icon: CustomIconWidget(
                iconName: 'bluetooth',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              label: const Text('Connect Device'),
            ),
          ],
        ),
      ),
    );
  }
}
