import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/telemetry_service.dart';
import '../../../core/data/profiles_repository.dart';
import '../../../core/data/sessions_repository.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'widgets/metric_card_widget.dart';
import 'widgets/performance_gauge_widget.dart';
import 'widgets/session_timer_widget.dart';
import 'widgets/swing_summary_widget.dart';

class LiveSessionDashboardInitialPage extends StatefulWidget {
  const LiveSessionDashboardInitialPage({super.key});

  @override
  State<LiveSessionDashboardInitialPage> createState() =>
      _LiveSessionDashboardInitialPageState();
}

class _LiveSessionDashboardInitialPageState
    extends State<LiveSessionDashboardInitialPage> {
  bool isConnected = true;
  bool isSessionActive = false;
  int sessionDuration = 0;
  Timer? sessionTimer;
  DateTime? _sessionStartTime;
  double packetUpdateRate = 58.5;

  // Real-time performance metrics
  double currentBatSpeed = 0.0;
  double peakBatSpeed = 0.0;
  double currentImpactSpeed = 0.0;
  double peakImpactSpeed = 0.0;
  double currentReleaseVelocity = 0.0;
  double peakReleaseVelocity = 0.0;
  double releaseAngle = 0.0;
  double swingAngle = 0.0;
  double rotationSpeed = 0.0;
  double releaseTime = 0.0;

  List<double> batSpeedTrend = [];
  List<double> impactSpeedTrend = [];
  List<double> releaseVelocityTrend = [];
  List<double> releaseTimeTrend = [];

  Timer? metricsUpdateTimer;
  StreamSubscription<TelemetryData>? _telemetrySub;

  @override
  void initState() {
    super.initState();
    _startMetricsSimulation();
  }

  @override
  void dispose() {
    sessionTimer?.cancel();
    metricsUpdateTimer?.cancel();
    super.dispose();
  }

  void _startMetricsSimulation() {
    metricsUpdateTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) {
      if (isSessionActive && mounted && _telemetrySub == null) {
        setState(() {
          currentBatSpeed =
              45.0 + (DateTime.now().millisecondsSinceEpoch % 100) / 10;
          currentImpactSpeed =
              85.0 + (DateTime.now().millisecondsSinceEpoch % 150) / 10;
          currentReleaseVelocity =
              120.0 + (DateTime.now().millisecondsSinceEpoch % 200) / 10;

          if (currentBatSpeed > peakBatSpeed) peakBatSpeed = currentBatSpeed;
          if (currentImpactSpeed > peakImpactSpeed) {
            peakImpactSpeed = currentImpactSpeed;
          }
          if (currentReleaseVelocity > peakReleaseVelocity) {
            peakReleaseVelocity = currentReleaseVelocity;
          }

          releaseAngle =
              35.0 + (DateTime.now().millisecondsSinceEpoch % 50) / 10;
          swingAngle = 42.0 + (DateTime.now().millisecondsSinceEpoch % 60) / 10;
          rotationSpeed =
              2800.0 + (DateTime.now().millisecondsSinceEpoch % 400);
          releaseTime = 10.0 + (DateTime.now().millisecondsSinceEpoch % 50) / 2;

          batSpeedTrend.add(currentBatSpeed);
          impactSpeedTrend.add(currentImpactSpeed);
          releaseVelocityTrend.add(currentReleaseVelocity);

          if (batSpeedTrend.length > 20) batSpeedTrend.removeAt(0);
          if (impactSpeedTrend.length > 20) impactSpeedTrend.removeAt(0);
          if (releaseVelocityTrend.length > 20) {
            releaseVelocityTrend.removeAt(0);
          }
          releaseTimeTrend.add(releaseTime);
          if (releaseTimeTrend.length > 20) releaseTimeTrend.removeAt(0);

          packetUpdateRate =
              55.0 + (DateTime.now().millisecondsSinceEpoch % 80) / 10;
        });
      }
    });
  }

  void _toggleSession() {
    setState(() {
      isSessionActive = !isSessionActive;
      if (isSessionActive) {
        _sessionStartTime = DateTime.now();
        // Subscribe to telemetry stream when session starts
        _telemetrySub = TelemetryService().stream.listen((t) {
          if (!mounted) return;
          setState(() {
            currentBatSpeed = t.batSpeed;
            if (t.batSpeed > peakBatSpeed) peakBatSpeed = t.batSpeed;
            currentImpactSpeed = t.impactSpeed;
            if (t.impactSpeed > peakImpactSpeed)
              peakImpactSpeed = t.impactSpeed;
            currentReleaseVelocity = t.releaseSpeed;
            if (t.releaseSpeed > peakReleaseVelocity)
              peakReleaseVelocity = t.releaseSpeed;
            releaseAngle = t.releaseAngle;
            swingAngle = t.swingAngle;
            rotationSpeed = t.rotationSpeed;

            // releaseTime is not provided by telemetry currently; keep simulated value

            batSpeedTrend.add(currentBatSpeed);
            impactSpeedTrend.add(currentImpactSpeed);
            releaseVelocityTrend.add(currentReleaseVelocity);

            if (batSpeedTrend.length > 20) batSpeedTrend.removeAt(0);
            if (impactSpeedTrend.length > 20) impactSpeedTrend.removeAt(0);
            if (releaseVelocityTrend.length > 20)
              releaseVelocityTrend.removeAt(0);
            if (releaseTimeTrend.length > 20) releaseTimeTrend.removeAt(0);
          });
        });

        sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() => sessionDuration++);
          }
        });
      } else {
        sessionTimer?.cancel();
        // Unsubscribe from telemetry when session stops
        _telemetrySub?.cancel();
        _telemetrySub = null;
      }
    });
  }

  void _stopSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Stop Session',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to stop the current session?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isSessionActive = false;
                sessionTimer?.cancel();
                final endTime = DateTime.now();
                final startTime =
                    _sessionStartTime ??
                    endTime.subtract(Duration(seconds: sessionDuration));

                // Build session map including raw trend series so playback shows real values
                double _avg(List<double> arr) => arr.isEmpty
                    ? 0.0
                    : arr.reduce((a, b) => a + b) / arr.length;

                double _std(List<double> arr) {
                  if (arr.isEmpty) return 0.0;
                  final mean = _avg(arr);
                  final sumsq = arr
                      .map((v) => (v - mean) * (v - mean))
                      .reduce((a, b) => a + b);
                  return math.sqrt(sumsq / arr.length);
                }

                final avgBat = _avg(batSpeedTrend);
                final avgImpact = _avg(impactSpeedTrend);
                final avgRelease = _avg(releaseVelocityTrend);

                final session = {
                  'date': startTime,
                  'endDate': endTime,
                  'duration': '${sessionDuration} sec',
                  'playerName':
                      ProfilesRepository().getDefaultProfile()?.name ??
                      'Player',
                  'playerRole':
                      ProfilesRepository().getDefaultProfile()?.role ??
                      'Unknown',
                  'totalSwings': isSessionActive
                      ? (sessionDuration ~/ 5)
                      : (sessionDuration ~/ 5),
                  'peakBatSpeed': peakBatSpeed,
                  'peakImpactSpeed': peakImpactSpeed,
                  'peakReleaseSpeed': peakReleaseVelocity,
                  'avgBatSpeed': avgBat,
                  'avgImpactSpeed': avgImpact,
                  'avgReleaseSpeed': avgRelease,
                  'consistency': batSpeedTrend.isEmpty
                      ? 0.0
                      : (_std(batSpeedTrend) / (avgBat == 0 ? 1 : avgBat)),
                  // include raw series for charts/playback
                  'speedSeries': List<double>.from(batSpeedTrend),
                  'impactSeries': List<double>.from(impactSpeedTrend),
                  'releaseSeries': List<double>.from(releaseVelocityTrend),
                  'releaseTimeSeries': List<double>.from(releaseTimeTrend),
                  'thumbnail': ProfilesRepository()
                      .getDefaultProfile()
                      ?.avatarUrl,
                  'sessionType': 'Live Recording',
                  'insights': '',
                  'isViewed': false,
                };

                SessionsRepository().saveSession(session);

                sessionDuration = 0;
                currentBatSpeed = 0.0;
                currentImpactSpeed = 0.0;
                currentReleaseVelocity = 0.0;
                peakBatSpeed = 0.0;
                peakImpactSpeed = 0.0;
                peakReleaseVelocity = 0.0;
                batSpeedTrend.clear();
                impactSpeedTrend.clear();
                releaseVelocityTrend.clear();
                _telemetrySub?.cancel();
                _telemetrySub = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Stop'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        packetUpdateRate = 58.5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CustomAppBar(
          title: 'Live Session',
          showConnectionStatus: true,
          isConnected: isConnected,
          onConnectionTap: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed('/bluetooth-connection-screen');
          },
          actions: [
            IconButton(
              icon: CustomIconWidget(
                iconName: 'timeline',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              onPressed: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed('/motion-visualization-screen');
              },
              tooltip: '2D Visualization',
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SessionTimerWidget(
                      duration: sessionDuration,
                      packetRate: packetUpdateRate,
                      isActive: isSessionActive,
                    ),
                    SizedBox(height: 3.h),

                    // Start / Stop Session button
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 1.6.h,
                          ),
                          backgroundColor: isSessionActive
                              ? Colors.red
                              : Colors.green,
                        ),
                        icon: Icon(
                          isSessionActive ? Icons.stop : Icons.play_arrow,
                          size: 18,
                        ),
                        label: Text(
                          isSessionActive ? 'Stop Session' : 'Start Session',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        onPressed: () {
                          if (isSessionActive) {
                            _stopSession();
                          } else {
                            _toggleSession();
                          }
                        },
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      'Performance Metrics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    PerformanceGaugeWidget(
                      title: 'Bat Speed',
                      currentValue: currentBatSpeed,
                      peakValue: peakBatSpeed,
                      maxValue: 120.0,
                      unit: 'km/h',
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(height: 2.h),

                    PerformanceGaugeWidget(
                      title: 'Impact Speed',
                      currentValue: currentImpactSpeed,
                      peakValue: peakImpactSpeed,
                      maxValue: 100.0,
                      unit: 'km/h',
                      color: theme.colorScheme.secondary,
                    ),
                    SizedBox(height: 2.h),

                    PerformanceGaugeWidget(
                      title: 'Release Velocity',
                      currentValue: currentReleaseVelocity,
                      peakValue: peakReleaseVelocity,
                      maxValue: 140.0,
                      unit: 'km/h',
                      color: theme.colorScheme.tertiary,
                    ),
                    SizedBox(height: 3.h),

                    Text(
                      'Additional Metrics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    Row(
                      children: [
                        Expanded(
                          child: MetricCardWidget(
                            title: 'Release Angle',
                            value: releaseAngle,
                            unit: '°',
                            trendData: releaseVelocityTrend,
                            color: const Color(0xFF0D47A1),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: MetricCardWidget(
                            title: 'Swing Angle',
                            value: swingAngle,
                            unit: '°',
                            trendData: batSpeedTrend,
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    Row(
                      children: [
                        Expanded(
                          child: MetricCardWidget(
                            title: 'Rotation Speed',
                            value: rotationSpeed,
                            unit: 'RPM',
                            trendData: impactSpeedTrend,
                            color: const Color(0xFFFF6F00),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: MetricCardWidget(
                            title: 'Release Time',
                            value: releaseTime,
                            unit: 'ms',
                            trendData: releaseTimeTrend,
                            color: const Color(0xFF6A1B9A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),

                    SwingSummaryWidget(
                      totalSwings: isSessionActive ? (sessionDuration ~/ 5) : 0,
                      consistencyScore: 87.5,
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
