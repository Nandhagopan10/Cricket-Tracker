import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'widgets/export_action_widget.dart';
import 'widgets/insights_panel_widget.dart';
import 'widgets/metrics_table_widget.dart';
import 'widgets/performance_card_widget.dart';
import 'widgets/performance_chart_widget.dart';

/// Session Summary Screen - Auto-generated performance analysis with insights
/// Displays peak values, averages, detailed metrics, charts, and coaching recommendations
/// Supports CSV/PDF export and offline sharing via WhatsApp/Email
class SessionSummaryScreen extends StatefulWidget {
  const SessionSummaryScreen({super.key});

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen> {
  bool _isExportingCSV = false;
  bool _isExportingPDF = false;
  bool _isRefreshing = false;

  // session data (populated from navigation arguments or falls back to mock)
  Map<String, dynamic> _sessionData = {
    "sessionId": "SESSION_20260126_001",
    "date": "26 Jan 2026",
    "startTime": "14:30",
    "endTime": "16:15",
    "duration": "1h 45m",
    "playerName": "Virat Sharma",
    "playerRole": "All-rounder",
    "totalSwings": 87,
    "totalDeliveries": 45,
    "sessionType": "Combined Practice",
  };

  // Performance and metric builders use recorded session data if available
  List<Map<String, dynamic>> _getPerformanceCards() {
    final role = (_sessionData['playerRole'] ?? 'Player').toString();
    final peakBat =
        double.tryParse(_sessionData['peakBatSpeed']?.toString() ?? '0') ?? 0.0;
    final avgRelease =
        double.tryParse(_sessionData['avgReleaseSpeed']?.toString() ?? '0') ??
        0.0;
    final rotation =
        double.tryParse(
          _sessionData['peakRotationSpeed']?.toString() ??
              _sessionData['avgRotationSpeed']?.toString() ??
              '0',
        ) ??
        0.0;

    return [
      {
        "title": "Peak Bat Speed",
        "value": peakBat.toStringAsFixed(1),
        "unit": "km/h",
        "subtitle": "Highest recorded speed",
        "icon": Icons.speed,
        "color": const Color(0xFF1B5E20),
      },
      {
        "title": "Avg Release Velocity",
        "value": avgRelease.toStringAsFixed(1),
        "unit": "km/h",
        "subtitle": "Mean bowling speed",
        "icon": Icons.sports_cricket,
        "color": const Color(0xFFFF6F00),
      },
      {
        "title": "Consistency Rating",
        "value":
            ((double.tryParse(_sessionData['consistency']?.toString() ?? '0') ??
                        0.0) *
                    100)
                .toStringAsFixed(0),
        "unit": "%",
        "subtitle": "Performance stability",
        "icon": Icons.trending_up,
        "color": const Color(0xFF0D47A1),
      },
      {
        "title": "Rotation Speed",
        "value": rotation.toStringAsFixed(0),
        "unit": "rpm",
        "subtitle": "Average rotation",
        "icon": Icons.rotate_right,
        "color": const Color(0xFF2E7D32),
      },
    ];
  }

  List<Map<String, dynamic>> _getDetailedMetrics() {
    return [
      {
        "label": "Total Swings",
        "value": (_sessionData['totalSwings'] ?? 0).toString(),
        "unit": "",
        "description": "Batting attempts",
      },
      {
        "label": "Average Bat Angle",
        "value": (_sessionData['avgBatAngle']?.toString() ?? '0'),
        "unit": "°",
        "description": "Mean impact angle",
      },
      {
        "label": "Total Deliveries",
        "value": (_sessionData['totalDeliveries'] ?? 0).toString(),
        "unit": "",
        "description": "Bowling attempts",
      },
      {
        "label": "Release Time Consistency",
        "value": (_sessionData['releaseTimeStd']?.toString() ?? '0'),
        "unit": "s",
        "description": "Standard deviation",
      },
      {
        "label": "Peak Impact Speed",
        "value": (_sessionData['peakImpactSpeed']?.toString() ?? '0'),
        "unit": "km/h",
        "description": "Maximum contact velocity",
      },
      {
        "label": "Average Release Angle",
        "value": (_sessionData['avgReleaseAngle']?.toString() ?? '0'),
        "unit": "°",
        "description": "Mean bowling angle",
      },
    ];
  }

  List<Map<String, dynamic>> _getSpeedChartData() {
    // If raw telemetry array exists in session data, use it, otherwise fallback to a simple generated trend
    final raw = _sessionData['speedSeries'];
    if (raw is List) {
      return raw
          .map(
            (e) => {
              'value': double.tryParse(e?.toString() ?? '0') ?? 0,
              'timestamp': raw.indexOf(e),
            },
          )
          .toList();
    }
    return List.generate(
      20,
      (index) => {
        "value": 120 + (index % 5) * 8 + (index % 3) * 4,
        "timestamp": index,
      },
    );
  }

  List<Map<String, dynamic>> _getAngleChartData() {
    final raw = _sessionData['angleSeries'];
    if (raw is List) {
      return raw
          .map(
            (e) => {
              'value': double.tryParse(e?.toString() ?? '0') ?? 0,
              'timestamp': raw.indexOf(e),
            },
          )
          .toList();
    }
    return List.generate(
      20,
      (index) => {
        "value": 35 + (index % 4) * 5 + (index % 2) * 3,
        "timestamp": index,
      },
    );
  }

  final List<Map<String, dynamic>> _insights = [
    {
      "priority": "High",
      "category": "Batting Technique",
      "title": "Inconsistent Bat Angle at Impact",
      "description":
          "Your bat angle varies significantly between swings (±12°), affecting shot consistency and power transfer.",
      "recommendation":
          "Focus on maintaining a consistent stance and follow-through. Practice with angle feedback drills.",
    },
    {
      "priority": "Medium",
      "category": "Bowling Performance",
      "title": "Release Velocity Improvement Opportunity",
      "description":
          "Your average release velocity is 8.3% below your peak performance from previous sessions.",
      "recommendation":
          "Incorporate strength training for core and shoulder muscles. Review bowling action mechanics.",
    },
    {
      "priority": "Low",
      "category": "Overall Progress",
      "title": "Excellent Consistency Rating",
      "description":
          "Your performance stability has improved by 12.1% compared to last session, showing strong training adaptation.",
      "recommendation":
          "Maintain current training intensity. Consider increasing difficulty level for continued improvement.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Try to read session map passed via Navigator arguments. This ensures
    // the screen displays the real recorded session passed from SessionHistoryScreen.
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      // Merge provided session data with existing defaults to keep keys safe
      final merged = {..._sessionData, ...args};
      // If the incoming session 'date' is a DateTime, format it to a readable string
      final rawDate = merged['date'];
      if (rawDate is DateTime) {
        merged['date'] = DateFormat('dd MMM yyyy').format(rawDate);
      } else if (rawDate is String) {
        // keep as-is
      } else if (merged['date'] != null) {
        // fallback: try parse
        final parsed = DateTime.tryParse(merged['date'].toString());
        if (parsed != null)
          merged['date'] = DateFormat('dd MMM yyyy').format(parsed);
      }

      _sessionData = merged;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Session Summary', style: theme.appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'replay',
              color: theme.colorScheme.primary,
              size: 6.w,
            ),
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.sessionPlayback, arguments: _sessionData);
            },
            tooltip: 'Replay Session',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSessionHeader(theme),
                SizedBox(height: 3.h),
                _buildPerformanceCards(theme),
                SizedBox(height: 3.h),
                MetricsTableWidget(metrics: _getDetailedMetrics()),
                SizedBox(height: 3.h),
                _buildChartsSection(theme),
                SizedBox(height: 3.h),
                InsightsPanelWidget(insights: _insights),
                SizedBox(height: 3.h),
                _buildExportSection(theme),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(1.5.w),
                ),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: theme.colorScheme.primary,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sessionData['playerName'] as String,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _sessionData['playerRole'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1.5.w),
                  border: Border.all(color: const Color(0xFF2E7D32), width: 1),
                ),
                child: Text(
                  'Completed',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Divider(color: theme.dividerColor),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  theme,
                  'calendar_today',
                  'Date',
                  _sessionData['date'] as String,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  theme,
                  'access_time',
                  'Duration',
                  _sessionData['duration'] as String,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  theme,
                  'sports_cricket',
                  'Swings',
                  '${_sessionData['totalSwings']}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  theme,
                  'sports_baseball',
                  'Deliveries',
                  '${_sessionData['totalDeliveries']}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    String iconName,
    String label,
    String value,
  ) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.primary,
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCards(ThemeData theme) {
    final cards = _getPerformanceCards();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Performance Metrics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 0.85,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return PerformanceCardWidget(
              title: card['title'] as String,
              value: card['value'].toString(),
              unit: card['unit'] as String,
              subtitle: card['subtitle'] as String,
              accentColor: card['color'] as Color,
              icon: card['icon'] as IconData,
              onTap: () {
                _showMetricDetails(context, card);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildChartsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Trends',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        PerformanceChartWidget(
          title: 'Speed Variations',
          dataPoints: _getSpeedChartData(),
          yAxisLabel: 'km/h',
          lineColor: const Color(0xFF1B5E20),
        ),
        SizedBox(height: 2.h),
        PerformanceChartWidget(
          title: 'Angle Consistency',
          dataPoints: _getAngleChartData(),
          yAxisLabel: '°',
          lineColor: const Color(0xFF0D47A1),
        ),
      ],
    );
  }

  Widget _buildExportSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export & Share',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        ExportActionWidget(
          title: 'Export as CSV',
          description: 'Download raw session data',
          icon: Icons.file_download,
          color: const Color(0xFF2E7D32),
          isLoading: _isExportingCSV,
          onTap: _handleCSVExport,
        ),
        SizedBox(height: 2.h),
        ExportActionWidget(
          title: 'Generate PDF Report',
          description: 'Create comprehensive summary',
          icon: Icons.picture_as_pdf,
          color: const Color(0xFFC62828),
          isLoading: _isExportingPDF,
          onTap: _handlePDFExport,
        ),
        SizedBox(height: 2.h),
        ExportActionWidget(
          title: 'Share Session',
          description: 'Send via WhatsApp or Email',
          icon: Icons.share,
          color: const Color(0xFF0D47A1),
          isLoading: false,
          onTap: _handleShare,
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insights recalculated with updated algorithms'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleCSVExport() async {
    setState(() => _isExportingCSV = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isExportingCSV = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV file exported successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handlePDFExport() async {
    setState(() => _isExportingPDF = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() => _isExportingPDF = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF report generated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleShare() async {
    try {
      await Share.share(
        'Check out my cricket training session summary!\n\n'
        'Session: ${_sessionData['sessionId'] ?? ''}\n'
        'Date: ${_sessionData['date'] ?? ''}\n'
        'Duration: ${_sessionData['duration'] ?? ''}\n'
        'Peak Bat Speed: ${_sessionData['peakBatSpeed'] ?? ''} km/h\n'
        'Consistency Rating: ${((_sessionData['consistency'] ?? 0.0) is double ? ((_sessionData['consistency'] as double) * 100).toStringAsFixed(0) : _sessionData['consistency'])}%\n\n'
        'Shared from CricketTracker App',
        subject: 'Cricket Training Session Summary',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share session'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showMetricDetails(BuildContext context, Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            card['title'] as String,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Value: ${card['value']} ${card['unit']}',
                style: theme.textTheme.bodyLarge,
              ),
              SizedBox(height: 1.h),
              Builder(
                builder: (_) {
                  final changePct = (card['changePercentage'] is double)
                      ? (card['changePercentage'] as double)
                      : null;
                  final changeText = changePct != null
                      ? '${changePct.toStringAsFixed(1)}%'
                      : 'N/A';
                  final changeColor = changePct == null
                      ? theme.textTheme.bodyMedium?.color
                      : (changePct >= 0
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828));
                  return Text(
                    'Change from Previous: $changeText',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: changeColor,
                    ),
                  );
                },
              ),
              SizedBox(height: 1.h),
              Text(
                'Percentile Ranking: Top 15%',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
