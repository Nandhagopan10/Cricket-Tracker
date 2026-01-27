import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

class PerformanceGaugeWidget extends StatelessWidget {
  final String title;
  final double currentValue;
  final double peakValue;
  final double maxValue;
  final String unit;
  final Color color;

  const PerformanceGaugeWidget({
    super.key,
    required this.title,
    required this.currentValue,
    required this.peakValue,
    required this.maxValue,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'trending_up',
                      color: color,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Peak: ${peakValue.toStringAsFixed(1)} $unit',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 25.h,
            child: SfRadialGauge(
              axes: [
                RadialAxis(
                  minimum: 0,
                  maximum: maxValue,
                  startAngle: 180,
                  endAngle: 0,
                  showLabels: true,
                  showTicks: true,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.15,
                    cornerStyle: CornerStyle.bothCurve,
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: [
                    RangePointer(
                      value: currentValue,
                      width: 0.15,
                      sizeUnit: GaugeSizeUnit.factor,
                      cornerStyle: CornerStyle.bothCurve,
                      gradient: SweepGradient(
                        colors: [color.withValues(alpha: 0.3), color],
                        stops: const [0.25, 0.75],
                      ),
                    ),
                    NeedlePointer(
                      value: currentValue,
                      needleLength: 0.7,
                      needleStartWidth: 1,
                      needleEndWidth: 3,
                      needleColor: color,
                      knobStyle: KnobStyle(
                        knobRadius: 0.08,
                        color: color,
                        borderColor: theme.colorScheme.surface,
                        borderWidth: 0.02,
                      ),
                    ),
                  ],
                  annotations: [
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentValue.toStringAsFixed(1),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          Text(
                            unit,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      angle: 90,
                      positionFactor: 0.75,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
