import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class SessionPlaybackScreen extends StatefulWidget {
  const SessionPlaybackScreen({super.key});

  @override
  State<SessionPlaybackScreen> createState() => _SessionPlaybackScreenState();
}

class _SessionPlaybackScreenState extends State<SessionPlaybackScreen> {
  Map<String, dynamic> _session = {};

  List<double> _speed = [];
  List<double> _impact = [];
  List<double> _release = [];
  List<double> _releaseTime = [];

  int _index = 0;
  Timer? _timer;
  bool _isPlaying = false;
  int _intervalMs = 100; // default

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _session = args;
      _loadSeries();
    }
  }

  void _loadSeries() {
    _speed = _toDoubleList(_session['speedSeries']);
    _impact = _toDoubleList(_session['impactSeries']);
    _release = _toDoubleList(_session['releaseSeries']);
    _releaseTime = _toDoubleList(_session['releaseTimeSeries']);

    // compute reasonable interval from stored duration
    final rawDuration = _session['duration']?.toString() ?? '';
    final match = RegExp(r'(\d+)').firstMatch(rawDuration);
    final totalSec = match != null
        ? int.tryParse(match.group(0) ?? '0') ?? 0
        : 0;
    final maxLen = [
      _speed.length,
      _impact.length,
      _release.length,
      _releaseTime.length,
    ].where((l) => l > 0).fold<int>(0, (prev, l) => math.max(prev, l));
    if (totalSec > 0 && maxLen > 0) {
      final ms = (totalSec * 1000 / maxLen).round();
      _intervalMs = ms.clamp(30, 1000);
    }
    setState(() {});
  }

  List<double> _toDoubleList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) {
        try {
          if (e is double) return e;
          if (e is int) return e.toDouble();
          return double.tryParse(e?.toString() ?? '') ?? 0.0;
        } catch (_) {
          return 0.0;
        }
      }).toList();
    }
    return [];
  }

  void _play() {
    if (_isPlaying) return;
    _isPlaying = true;
    _timer = Timer.periodic(Duration(milliseconds: _intervalMs), (t) {
      setState(() {
        _index++;
        final max = [
          _speed.length,
          _impact.length,
          _release.length,
          _releaseTime.length,
        ].where((l) => l > 0).fold<int>(0, (prev, l) => math.max(prev, l));
        if (_index >= max) {
          _index = max - 1;
          _pause();
        }
      });
    });
    setState(() {});
  }

  void _pause() {
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
    setState(() {});
  }

  void _seek(int idx) {
    _index = idx.clamp(
      0,
      math.max(
        0,
        [
              _speed.length,
              _impact.length,
              _release.length,
              _releaseTime.length,
            ].fold<int>(0, (p, l) => math.max(p, l)) -
            1,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double _safeAt(List<double> list, int idx) {
    if (list.isEmpty) return 0.0;
    if (idx < 0) return list.first;
    if (idx >= list.length) return list.last;
    return list[idx];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxLen = [
      _speed.length,
      _impact.length,
      _release.length,
      _releaseTime.length,
    ].where((l) => l > 0).fold<int>(0, (prev, l) => math.max(prev, l));

    final currentSpeed = _safeAt(_speed, _index);
    final currentImpact = _safeAt(_impact, _index);
    final currentRelease = _safeAt(_release, _index);
    final currentReleaseTime = _safeAt(_releaseTime, _index);

    return Scaffold(
      appBar: AppBar(
        title: Text('Playback', style: theme.appBarTheme.titleTextStyle),
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _session['playerName']?.toString() ?? 'Session',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            Center(
              child: Column(
                children: [
                  Text(
                    'Speed: ${currentSpeed.toStringAsFixed(1)} km/h',
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Impact: ${currentImpact.toStringAsFixed(1)} km/h',
                    style: theme.textTheme.bodyLarge,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Release: ${currentRelease.toStringAsFixed(1)} km/h',
                    style: theme.textTheme.bodyLarge,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Release Time: ${currentReleaseTime.toStringAsFixed(1)} ms',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Slider(
              value: maxLen == 0 ? 0 : (_index / (maxLen - 1)).clamp(0.0, 1.0),
              onChanged: maxLen == 0
                  ? null
                  : (v) {
                      final idx = (v * (maxLen - 1)).round();
                      _seek(idx);
                    },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'replay',
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                  onPressed: () {
                    _seek(0);
                    _play();
                  },
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: _isPlaying ? 'pause' : 'play_arrow',
                    color: theme.colorScheme.onSurface,
                    size: 28,
                  ),
                  onPressed: maxLen == 0
                      ? null
                      : () => _isPlaying ? _pause() : _play(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'stop',
                    color: theme.colorScheme.error,
                    size: 28,
                  ),
                  onPressed: () {
                    _pause();
                    _seek(0);
                  },
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Frames: ${_index + 1} / $maxLen',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
