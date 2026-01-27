import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Performance metric card widget displaying key statistics with visual indicators
/// Used in Session Summary Screen to show peak values and averages
class PerformanceCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final double? changePercentage;
  final VoidCallback? onTap;

  const PerformanceCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    this.changePercentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPositiveChange =
        changePercentage != null && changePercentage! >= 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Detailed breakdown: $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(1.5.w),
                  ),
                  child: CustomIconWidget(
                    iconName: _getIconName(icon),
                    color: accentColor,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (changePercentage != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: isPositiveChange
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.1)
                          : const Color(0xFFC62828).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: isPositiveChange
                              ? 'arrow_upward'
                              : 'arrow_downward',
                          color: isPositiveChange
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${changePercentage!.abs().toStringAsFixed(1)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isPositiveChange
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  unit,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.speed) return 'speed';
    if (icon == Icons.sports_cricket) return 'sports_cricket';
    if (icon == Icons.rotate_right) return 'rotate_right';
    if (icon == Icons.trending_up) return 'trending_up';
    return 'analytics';
  }
}
