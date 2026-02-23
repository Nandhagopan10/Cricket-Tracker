import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';

/// Session Card Widget - Displays individual session information with swipe actions
///
/// Features:
/// - Session thumbnail with player info
/// - Key metrics preview with visual indicators
/// - Swipe right for quick actions (replay, export, delete)
/// - Swipe left for sharing options
/// - Multi-select mode support
/// - Unviewed session indicator
class SessionCardWidget extends StatelessWidget {
  final Map<String, dynamic> session;
  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onReplay;
  final VoidCallback onExport;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const SessionCardWidget({
    super.key,
    required this.session,
    required this.isMultiSelectMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onReplay,
    required this.onExport,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    T _safe<T>(dynamic v, T fallback) {
      try {
        if (v is T) return v;
        if (T == String) return v?.toString() as T? ?? fallback;
        if (T == int)
          return int.tryParse(v?.toString() ?? '') as T? ?? fallback;
        if (T == double)
          return double.tryParse(v?.toString() ?? '') as T? ?? fallback;
        if (T == bool) return (v == true) as T? ?? fallback;
      } catch (_) {}
      return fallback;
    }

    final isViewed = _safe<bool>(session['isViewed'], false);
    final date = _safe<DateTime>(session['date'], DateTime.now());
    final playerRole = _safe<String>(session['playerRole'], 'Player');

    return Slidable(
      enabled: !isMultiSelectMode,
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onReplay(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.replay,
            label: 'Replay',
          ),
          SlidableAction(
            onPressed: (_) => onExport(),
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            icon: Icons.file_download,
            label: 'Export',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onShare(),
            backgroundColor: const Color(0xFFFF6F00),
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: isSelected ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: theme.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMultiSelectMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onTap(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImageWidget(
                        imageUrl:
                            (session["thumbnail"] ??
                                    'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=600')
                                .toString(),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        semanticLabel:
                            (session["semanticLabel"] ?? 'Session thumbnail')
                                .toString(),
                      ),
                    ),
                    if (!isViewed)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (session["playerName"] ?? 'Player').toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(
                                playerRole,
                                theme,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getRoleColor(playerRole, theme),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              playerRole,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getRoleColor(playerRole, theme),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'calendar_today',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          CustomIconWidget(
                            iconName: 'timer',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (session["duration"] ?? '').toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (session["sessionType"] ?? 'Recorded Session')
                            .toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMetricsRow(theme),
                      const SizedBox(height: 8),
                      _buildProgressBar(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRow(ThemeData theme) {
    final role = (session["playerRole"] ?? 'Player').toString();

    if (role == "Batsman" || role == "All-rounder") {
      return Row(
        children: [
          Expanded(
            child: _buildMetricItem(
              theme,
              'Swings',
              (session["totalSwings"] ?? 0).toString(),
              Icons.sports_cricket,
            ),
          ),
          Expanded(
            child: _buildMetricItem(
              theme,
              'Peak Speed',
              '${(double.tryParse(session["peakBatSpeed"]?.toString() ?? '0') ?? 0).toStringAsFixed(1)} km/h',
              Icons.speed,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _buildMetricItem(
              theme,
              'Deliveries',
              (session["totalSwings"] ?? 0).toString(),
              Icons.sports_cricket,
            ),
          ),
          Expanded(
            child: _buildMetricItem(
              theme,
              'Peak Speed',
              '${(double.tryParse(session["peakReleaseSpeed"]?.toString() ?? '0') ?? 0).toStringAsFixed(1)} km/h',
              Icons.speed,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMetricItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: icon
              .toString()
              .split('.')
              .last
              .replaceAll('IconData(U+', '')
              .replaceAll(')', ''),
          color: theme.colorScheme.primary,
          size: 16,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    final consistency =
        double.tryParse(session["consistency"]?.toString() ?? '0') ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Consistency',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(consistency * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: consistency,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getConsistencyColor(consistency, theme),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role, ThemeData theme) {
    switch (role) {
      case 'Batsman':
        return theme.colorScheme.primary;
      case 'Bowler':
        return const Color(0xFF0D47A1);
      case 'All-rounder':
        return const Color(0xFFFF6F00);
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  Color _getConsistencyColor(double consistency, ThemeData theme) {
    if (consistency >= 0.85) {
      return const Color(0xFF2E7D32);
    } else if (consistency >= 0.70) {
      return const Color(0xFFF57C00);
    } else {
      return theme.colorScheme.error;
    }
  }
}
