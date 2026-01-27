import 'package:flutter/material.dart';

/// Custom bottom navigation bar widget for cricket analytics application.
/// Implements Bottom-Heavy Thumb Zone Strategy for one-handed operation during training.
///
/// Features:
/// - Fixed type navigation for consistent layout
/// - High-contrast icons optimized for outdoor visibility
/// - Touch targets sized for comfortable interaction (48dp minimum)
/// - Parameterized design for reusability across different implementations
///
/// Usage:
/// ```dart
/// CustomBottomBar(
///   currentIndex: _currentIndex,
///   onTap: (index) {
///     setState(() => _currentIndex = index);
///   },
/// )
/// ```
class CustomBottomBar extends StatelessWidget {
  /// Current selected index of the navigation bar
  final int currentIndex;

  /// Callback function when a navigation item is tapped
  /// Receives the index of the tapped item
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
      selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
      unselectedLabelStyle: theme.bottomNavigationBarTheme.unselectedLabelStyle,
      elevation: 8.0,
      items: [
        // Dashboard - Live Session Dashboard for real-time metrics
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined, size: 24),
          activeIcon: Icon(Icons.dashboard, size: 24),
          label: 'Dashboard',
          tooltip: 'Live Session Dashboard',
        ),

        // Visualization - 2D Motion Visualization for coaching analysis
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline_outlined, size: 24),
          activeIcon: Icon(Icons.timeline, size: 24),
          label: 'Visualize',
          tooltip: '2D Motion Visualization',
        ),

        // History - Session History for performance review
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined, size: 24),
          activeIcon: Icon(Icons.history, size: 24),
          label: 'History',
          tooltip: 'Session History',
        ),

        // Profile - Player Profile Management for multi-player scenarios
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline, size: 24),
          activeIcon: Icon(Icons.person, size: 24),
          label: 'Profile',
          tooltip: 'Player Profile',
        ),
      ],
    );
  }
}
