import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Widget representing a single Bluetooth device in the list.
/// Displays device information with signal strength and pairing status.
class DeviceListItemWidget extends StatelessWidget {
  final String deviceName;
  final String deviceMac;
  final int signalStrength;
  final bool isPaired;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const DeviceListItemWidget({
    super.key,
    required this.deviceName,
    required this.deviceMac,
    required this.signalStrength,
    required this.isPaired,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signalConfig = _getSignalConfig();

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            // Bluetooth icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: isPaired ? 'bluetooth_connected' : 'bluetooth',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Device info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          deviceName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPaired) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.3.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PAIRED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    deviceMac,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 2.w),

            // Signal strength indicator
            Column(
              children: [
                CustomIconWidget(
                  iconName: signalConfig['icon'] as String,
                  color: signalConfig['color'] as Color,
                  size: 24,
                ),
                SizedBox(height: 0.3.h),
                Text(
                  '${signalStrength.abs()} dBm',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: signalConfig['color'] as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get signal strength configuration
  Map<String, dynamic> _getSignalConfig() {
    if (signalStrength >= -50) {
      return {'icon': 'signal_cellular_alt', 'color': const Color(0xFF2E7D32)};
    } else if (signalStrength >= -70) {
      return {
        'icon': 'signal_cellular_alt_2_bar',
        'color': const Color(0xFFF57C00),
      };
    } else {
      return {
        'icon': 'signal_cellular_alt_1_bar',
        'color': const Color(0xFFC62828),
      };
    }
  }
}
