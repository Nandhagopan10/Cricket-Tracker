import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Widget displaying connected device information with disconnect option.
/// Shows device details and real-time data reception status.
class ConnectedDeviceCardWidget extends StatelessWidget {
  final String deviceName;
  final String deviceMac;
  final bool isReceivingData;
  final VoidCallback onDisconnect;

  const ConnectedDeviceCardWidget({
    super.key,
    required this.deviceName,
    required this.deviceMac,
    required this.isReceivingData,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'bluetooth_connected',
                    color: const Color(0xFF2E7D32),
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
                      'Connected Device',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      deviceName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Device details
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                _buildDetailRow(context, 'MAC Address', deviceMac, 'router'),
                SizedBox(height: 1.h),
                Divider(height: 1, color: theme.colorScheme.outline),
                SizedBox(height: 1.h),
                _buildDetailRow(
                  context,
                  'Data Status',
                  isReceivingData ? 'Receiving' : 'No Data',
                  isReceivingData ? 'check_circle' : 'error',
                  valueColor: isReceivingData
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFF57C00),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Disconnect button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: OutlinedButton(
              onPressed: onDisconnect,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFC62828)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'bluetooth_disabled',
                    color: const Color(0xFFC62828),
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Disconnect',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build detail row widget
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    String iconName, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.2.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
