import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';
import '../bluetooth_connection_screen.dart';

/// Widget displaying current Bluetooth connection status with visual feedback.
/// Optimized for outdoor visibility with high-contrast color coding.
class ConnectionStatusCardWidget extends StatelessWidget {
  final ConnectionStatus status;
  final String? deviceName;
  final bool isReceivingData;

  const ConnectionStatusCardWidget({
    super.key,
    required this.status,
    this.deviceName,
    this.isReceivingData = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine status properties
    final statusConfig = _getStatusConfig(theme);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: statusConfig['backgroundColor'] as Color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusConfig['borderColor'] as Color,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Status icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (statusConfig['iconColor'] as Color).withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: status == ConnectionStatus.connecting
                  ? SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          statusConfig['iconColor'] as Color,
                        ),
                      ),
                    )
                  : CustomIconWidget(
                      iconName: statusConfig['icon'] as String,
                      color: statusConfig['iconColor'] as Color,
                      size: 32,
                    ),
            ),
          ),

          SizedBox(height: 2.h),

          // Status text
          Text(
            statusConfig['title'] as String,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: statusConfig['textColor'] as Color,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 0.5.h),

          // Device name or status message
          Text(
            deviceName ?? (statusConfig['subtitle'] as String),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (statusConfig['textColor'] as Color).withValues(
                alpha: 0.7,
              ),
            ),
            textAlign: TextAlign.center,
          ),

          // Data reception indicator (only when connected)
          if (status == ConnectionStatus.connected) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isReceivingData
                    ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                    : const Color(0xFFF57C00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isReceivingData
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFF57C00),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isReceivingData
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFF57C00),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    isReceivingData ? 'Receiving Data' : 'No Data',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isReceivingData
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFF57C00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get status configuration based on connection state
  Map<String, dynamic> _getStatusConfig(ThemeData theme) {
    switch (status) {
      case ConnectionStatus.connected:
        return {
          'title': 'Connected',
          'subtitle': 'Ready to receive data',
          'icon': 'bluetooth_connected',
          'iconColor': const Color(0xFF2E7D32),
          'textColor': const Color(0xFF2E7D32),
          'backgroundColor': const Color(0xFF2E7D32).withValues(alpha: 0.05),
          'borderColor': const Color(0xFF2E7D32),
        };
      case ConnectionStatus.connecting:
        return {
          'title': 'Connecting',
          'subtitle': 'Establishing connection...',
          'icon': 'bluetooth_searching',
          'iconColor': const Color(0xFF0D47A1),
          'textColor': const Color(0xFF0D47A1),
          'backgroundColor': const Color(0xFF0D47A1).withValues(alpha: 0.05),
          'borderColor': const Color(0xFF0D47A1),
        };
      case ConnectionStatus.disconnected:
        return {
          'title': 'Disconnected',
          'subtitle': 'Scan to find devices',
          'icon': 'bluetooth_disabled',
          'iconColor': const Color(0xFFC62828),
          'textColor': const Color(0xFFC62828),
          'backgroundColor': const Color(0xFFC62828).withValues(alpha: 0.05),
          'borderColor': const Color(0xFFC62828),
        };
    }
  }
}
