import 'package:flutter/material.dart';
import '../presentation/export_and_share_screen/export_and_share_screen.dart';
import '../presentation/bluetooth_connection_screen/bluetooth_connection_screen.dart';
import '../presentation/session_summary_screen/session_summary_screen.dart';
import '../presentation/session_history_screen/session_history_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/live_session_dashboard/live_session_dashboard.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String exportAndShare = '/export-and-share-screen';
  static const String bluetoothConnection = '/bluetooth-connection-screen';
  static const String sessionSummary = '/session-summary-screen';
  static const String sessionHistory = '/session-history-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String liveSessionDashboard = '/live-session-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const OnboardingFlow(),
    exportAndShare: (context) => const ExportAndShareScreen(),
    bluetoothConnection: (context) => const BluetoothConnectionScreen(),
    sessionSummary: (context) => const SessionSummaryScreen(),
    sessionHistory: (context) => const SessionHistoryScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    liveSessionDashboard: (context) => const LiveSessionDashboard(),
    // TODO: Add your other routes here
  };
}
