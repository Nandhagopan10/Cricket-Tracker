import 'package:flutter/material.dart';

/// Custom app bar widget for cricket analytics application.
/// Implements connection status visibility and clean technical interface.
///
/// Features:
/// - Persistent Bluetooth connection status indicator
/// - Clean, data-forward design without visual noise
/// - Optimized for outdoor visibility with high-contrast elements
/// - Flexible action buttons for context-specific controls
///
/// Usage:
/// ```dart
/// CustomAppBar(
///   title: 'Live Session',
///   showConnectionStatus: true,
///   isConnected: true,
///   actions: [
///     IconButton(
///       icon: Icon(Icons.settings),
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String title;

  /// Whether to show the connection status indicator
  final bool showConnectionStatus;

  /// Current Bluetooth connection state
  final bool isConnected;

  /// Optional leading widget (typically back button or menu)
  final Widget? leading;

  /// Optional action buttons displayed on the right
  final List<Widget>? actions;

  /// Callback when connection status is tapped
  final VoidCallback? onConnectionTap;

  /// Whether to center the title
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showConnectionStatus = false,
    this.isConnected = false,
    this.leading,
    this.actions,
    this.onConnectionTap,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: leading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Connection status indicator (if enabled)
          if (showConnectionStatus) ...[
            GestureDetector(
              onTap: onConnectionTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected
                      ? const Color(0xFF2E7D32).withValues(
                          alpha: 0.1,
                        ) // Success color
                      : const Color(
                          0xFFC62828,
                        ).withValues(alpha: 0.1), // Error color
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bluetooth,
                      size: 16,
                      color: isConnected
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isConnected
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Title
          Flexible(
            child: Text(
              title,
              style: theme.appBarTheme.titleTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: centerTitle,
      actions: actions,
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: theme.appBarTheme.elevation,
      iconTheme: theme.appBarTheme.iconTheme,
    );
  }
}

/// Variant of CustomAppBar specifically for connection management screen
class CustomConnectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String title;

  /// Current connection state for visual feedback
  final ConnectionState connectionState;

  /// Optional leading widget
  final Widget? leading;

  /// Optional action buttons
  final List<Widget>? actions;

  const CustomConnectionAppBar({
    super.key,
    required this.title,
    required this.connectionState,
    this.leading,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine status color and text based on connection state
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (connectionState) {
      case ConnectionState.connected:
        statusColor = const Color(0xFF2E7D32); // Success
        statusText = 'Connected';
        statusIcon = Icons.bluetooth_connected;
        break;
      case ConnectionState.connecting:
        statusColor = const Color(0xFFF57C00); // Warning
        statusText = 'Connecting...';
        statusIcon = Icons.bluetooth_searching;
        break;
      case ConnectionState.disconnected:
        statusColor = const Color(0xFFC62828); // Error
        statusText = 'Disconnected';
        statusIcon = Icons.bluetooth_disabled;
        break;
      case ConnectionState.scanning:
        statusColor = const Color(0xFF0D47A1); // Accent
        statusText = 'Scanning...';
        statusIcon = Icons.bluetooth_searching;
        break;
    }

    return AppBar(
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.appBarTheme.titleTextStyle),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: actions,
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: theme.appBarTheme.elevation,
      iconTheme: theme.appBarTheme.iconTheme,
    );
  }
}

/// Enum representing different connection states for the app bar
enum ConnectionState { connected, connecting, disconnected, scanning }
