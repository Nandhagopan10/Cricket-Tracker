import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/custom_icon_widget.dart';

/// Session Filter Widget - Bottom sheet for filtering sessions by date range
///
/// Features:
/// - Date range picker with calendar interface
/// - Quick filter presets (Today, Last 7 days, Last 30 days)
/// - Clear filters option
/// - Responsive design with proper spacing
class SessionFilterWidget extends StatefulWidget {
  final DateTimeRange? selectedDateRange;
  final Function(DateTimeRange?) onDateRangeSelected;
  final VoidCallback onClearFilters;

  const SessionFilterWidget({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeSelected,
    required this.onClearFilters,
  });

  @override
  State<SessionFilterWidget> createState() => _SessionFilterWidgetState();
}

class _SessionFilterWidgetState extends State<SessionFilterWidget> {
  DateTimeRange? _tempDateRange;

  @override
  void initState() {
    super.initState();
    _tempDateRange = widget.selectedDateRange;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _tempDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _tempDateRange = picked);
    }
  }

  void _selectQuickFilter(String filter) {
    final now = DateTime.now();
    DateTimeRange range;

    switch (filter) {
      case 'today':
        range = DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
        break;
      case 'last7days':
        range = DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
        break;
      case 'last30days':
        range = DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
        break;
      default:
        return;
    }

    setState(() => _tempDateRange = range);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter Sessions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Quick Filters',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickFilterChip(theme, 'Today', 'today'),
                    _buildQuickFilterChip(theme, 'Last 7 Days', 'last7days'),
                    _buildQuickFilterChip(theme, 'Last 30 Days', 'last30days'),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Custom Date Range',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: CustomIconWidget(
                    iconName: 'calendar_today',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    _tempDateRange != null
                        ? '${DateFormat('dd MMM yyyy').format(_tempDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_tempDateRange!.end)}'
                        : 'Select Date Range',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _tempDateRange = null);
                          widget.onClearFilters();
                        },
                        child: const Text('Clear Filters'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            widget.onDateRangeSelected(_tempDateRange),
                        child: const Text('Apply'),
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
  }

  Widget _buildQuickFilterChip(ThemeData theme, String label, String filter) {
    return FilterChip(
      label: Text(label),
      selected: false,
      onSelected: (_) => _selectQuickFilter(filter),
      labelStyle: theme.textTheme.labelMedium,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
    );
  }
}
