import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class TelemetryData {
  final double batSpeed;
  final double swingAngle;
  final double impactSpeed;
  final double releaseAngle;
  final double releaseSpeed;
  final double releaseTime;
  final double rotationSpeed;
  final DateTime timestamp;

  TelemetryData({
    required this.batSpeed,
    required this.swingAngle,
    required this.impactSpeed,
    required this.releaseAngle,
    required this.releaseSpeed,
    required this.releaseTime,
    required this.rotationSpeed,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory TelemetryData.fromMap(Map<String, dynamic> m) {
    double _d(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0);
    return TelemetryData(
      batSpeed: _d(m['batSpeed'] ?? m['bat_speed'] ?? m['bat']),
      swingAngle: _d(m['swingAngle'] ?? m['swing_angle'] ?? m['swing']),
      impactSpeed: _d(m['impactSpeed'] ?? m['impact_speed'] ?? m['impact']),
      releaseAngle: _d(
        m['releaseAngle'] ??
            m['release_angle'] ??
            m['release_angle_deg'] ??
            m['release'],
      ),
      releaseSpeed: _d(
        m['releaseSpeed'] ??
            m['release_speed'] ??
            m['releaseVelocity'] ??
            m['release_velocity'],
      ),
      releaseTime: _d(m['releaseTime'] ?? m['release_time'] ?? m['time']),
      rotationSpeed: _d(
        m['rotationSpeed'] ?? m['rotation_speed'] ?? m['rotation'],
      ),
    );
  }

  /// Try parse JSON payload or comma-separated values in the known order:
  /// batSpeed,swingAngle,impactSpeed,releaseAngle,releaseSpeed,releaseTime,rotationSpeed
  static TelemetryData? tryParse(Uint8List payload) {
    try {
      final s = utf8.decode(payload);
      // Try JSON first
      final dynamic decoded = json.decode(s);
      if (decoded is Map<String, dynamic>) {
        return TelemetryData.fromMap(decoded);
      }
    } catch (_) {}

    try {
      final s = utf8.decode(payload).trim();
      // Key=Value pairs e.g. "BatSpeed=110,BatAngle=55,..."
      if (s.contains('=') && s.isNotEmpty) {
        final parts = s.split(RegExp('[,;\n]+'));
        final Map<String, double> kv = {};
        for (var p in parts) {
          var part = p.trim();
          if (part.isEmpty) continue;
          // remove trailing punctuation like '.'
          part = part.replaceAll(RegExp(r'[\.]$'), '');
          final idx = part.indexOf('=');
          if (idx <= 0) continue;
          final rawKey = part.substring(0, idx).trim().toLowerCase();
          final rawVal = part.substring(idx + 1).trim();
          // normalize key: remove non-alphanumeric
          final key = rawKey.replaceAll(RegExp(r'[^a-z0-9]'), '');
          final value = double.tryParse(rawVal) ?? 0.0;
          kv[key] = value;
        }

        if (kv.isNotEmpty) {
          double getVal(List<String> keys) {
            for (final k in keys) {
              final normalized = k.replaceAll(RegExp(r'[^a-z0-9]'), '');
              if (kv.containsKey(normalized)) return kv[normalized]!;
            }
            return 0.0;
          }

          return TelemetryData(
            batSpeed: getVal(['batspeed', 'bat_speed', 'bat']),
            swingAngle: getVal(['swingangle', 'swing_angle', 'swing']),
            impactSpeed: getVal(['impactspeed', 'impact_speed', 'impact']),
            releaseAngle: getVal([
              'releaseangle',
              'release_angle',
              'release_angle_deg',
              'release',
            ]),
            releaseSpeed: getVal([
              'releasespeed',
              'release_speed',
              'releasevelocity',
              'release_velocity',
            ]),
            releaseTime: getVal(['releasetime', 'release_time', 'time']),
            rotationSpeed: getVal([
              'rotationspeed',
              'rotation_speed',
              'rotation',
            ]),
          );
        }
      }
    } catch (_) {}

    return null;
  }
}

/// Singleton service that subscribes to a BLE characteristic notification
/// and emits parsed `TelemetryData`.
class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  final StreamController<TelemetryData> _controller =
      StreamController<TelemetryData>.broadcast();
  Stream<TelemetryData> get stream => _controller.stream;

  StreamSubscription<List<int>>? _charSub;
  BluetoothCharacteristic? _subscribedChar;

  /// Start listening on the first characteristic that supports notify
  /// under the device's services. If you have a specific characteristic
  /// UUID, you can modify this to select it explicitly.
  Future<void> startForDevice(BluetoothDevice device) async {
    await stop();
    try {
      final services = await device.discoverServices();
      BluetoothCharacteristic? target;
      for (final s in services) {
        for (final c in s.characteristics) {
          if (c.properties.notify == true) {
            target = c;
            break;
          }
        }
        if (target != null) break;
      }
      if (target == null) return;
      _subscribedChar = target;
      await target.setNotifyValue(true);
      _charSub = target.value.listen((bytes) {
        final parsed = TelemetryData.tryParse(Uint8List.fromList(bytes));
        if (parsed != null) {
          _controller.add(parsed);
        }
      });
    } catch (_) {
      // ignore errors; caller may retry
    }
  }

  Future<void> stop() async {
    try {
      await _charSub?.cancel();
      _charSub = null;
    } catch (_) {}
    try {
      if (_subscribedChar != null) {
        await _subscribedChar!.setNotifyValue(false);
      }
    } catch (_) {}
    _subscribedChar = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
