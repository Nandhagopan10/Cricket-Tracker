import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/custom_bottom_bar.dart';
import 'live_session_dashboard_initial_page.dart';

class LiveSessionDashboard extends StatefulWidget {
  const LiveSessionDashboard({super.key});

  @override
  LiveSessionDashboardState createState() => LiveSessionDashboardState();
}

class LiveSessionDashboardState extends State<LiveSessionDashboard> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int currentIndex = 0;

  final List<String> routes = [
    '/live-session-dashboard',
    '/motion-visualization-screen',
    '/session-history-screen',
    '/player-profile-screen',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: navigatorKey,
        initialRoute: '/live-session-dashboard',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/live-session-dashboard':
            case '/':
              return MaterialPageRoute(
                builder: (context) => const LiveSessionDashboardInitialPage(),
                settings: settings,
              );
            default:
              if (AppRoutes.routes.containsKey(settings.name)) {
                return MaterialPageRoute(
                  builder: AppRoutes.routes[settings.name]!,
                  settings: settings,
                );
              }
              return null;
          }
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (!AppRoutes.routes.containsKey(routes[index])) {
            return;
          }
          if (currentIndex != index) {
            setState(() => currentIndex = index);
            navigatorKey.currentState?.pushReplacementNamed(routes[index]);
          }
        },
      ),
    );
  }
}
