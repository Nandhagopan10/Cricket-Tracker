import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Lightweight BLE service wrapper using flutter_blue_plus.
/// Exposes `devicesStream` which emits lists of `ScanResult`.
class BleService {
  StreamSubscription<List<ScanResult>>? _scanResultsSub;
  final StreamController<List<ScanResult>> _resultsController =
      StreamController<List<ScanResult>>.broadcast();

  /// Stream of current discovered devices
  Stream<List<ScanResult>> get devicesStream => _resultsController.stream;

  /// Start scanning and emit scanResults from the plugin.
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await stopScan();

    // Debug
    try {
      // ignore: avoid_print
      print('[BleService] startScan requested');
    } catch (_) {}

    // Subscribe to the plugin's scanResults stream first so we receive events
    _scanResultsSub = FlutterBluePlus.scanResults.listen(
      (results) {
        _resultsController.add(List.unmodifiable(results));
        try {
          // ignore: avoid_print
          print('[BleService] scanResults: ${results.length} items');
        } catch (_) {}
      },
      onError: (_) {
        _resultsController.add(const []);
      },
    );

    // Request plugin to start scanning
    try {
      await FlutterBluePlus.startScan(timeout: timeout);
    } catch (_) {
      // ignore start errors
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    try {
      // Debug
      try {
        // ignore: avoid_print
        print('[BleService] stopScan called');
      } catch (_) {}
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    await _scanResultsSub?.cancel();
    _scanResultsSub = null;
  }

  /// Dispose internal streams
  Future<void> dispose() async {
    await stopScan();
    await _resultsController.close();
  }
}
