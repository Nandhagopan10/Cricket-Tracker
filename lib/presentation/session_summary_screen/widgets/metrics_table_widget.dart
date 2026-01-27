import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Detailed metrics table widget showing comprehensive statistics
/// Displays comparison with previous sessions using trend indicators
class MetricsTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> metrics;

  const MetricsTableWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(2.w),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Detailed Statistics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final metric = metrics[index];
              final bool hasComparison = metric['comparison'] != null;
              final bool isPositive =
                  hasComparison && (metric['comparison'] as double) >= 0;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric['label'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (metric['description'] != null)
                            Text(
                              metric['description'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${metric['value']} ${metric['unit']}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (hasComparison)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomIconWidget(
                                  iconName: isPositive
                                      ? 'arrow_upward'
                                      : 'arrow_downward',
                                  color: isPositive
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                  size: 3.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${(metric['comparison'] as double).abs().toStringAsFixed(1)}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isPositive
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFC62828),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
