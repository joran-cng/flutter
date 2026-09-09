import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../routes/route_generator.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static bool goToHomeTabFrom(BuildContext context) {
    final state = context.findAncestorStateOfType<MainShellState>();
    if (state == null) {
      return false;
    }
    state.goToHomeTab();
    return true;
  }

  static int? currentTabIndex(BuildContext context) {
    return context.findAncestorStateOfType<MainShellState>()?.currentTabIndex;
  }

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  final _homeNavigatorKey = GlobalKey<NavigatorState>();
  final _reservationsNavigatorKey = GlobalKey<NavigatorState>();

  int _currentIndex = 0;

  int get currentTabIndex => _currentIndex;

  void goToHomeTab() {
    setState(() => _currentIndex = 0);
    _homeNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  NavigatorState? get _activeNavigator {
    return switch (_currentIndex) {
      0 => _homeNavigatorKey.currentState,
      1 => _reservationsNavigatorKey.currentState,
      _ => null,
    };
  }

  Future<void> _handleSystemBack() async {
    final navigator = _activeNavigator;
    if (navigator == null) {
      return;
    }

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleSystemBack();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            Navigator(
              key: _homeNavigatorKey,
              initialRoute: AppRoutes.home,
              onGenerateRoute: RouteGenerator.onGenerateHomeTabRoute,
            ),
            Navigator(
              key: _reservationsNavigatorKey,
              initialRoute: AppRoutes.reservations,
              onGenerateRoute: RouteGenerator.onGenerateReservationsTabRoute,
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Mes réservations',
            ),
          ],
        ),
      ),
    );
  }
}
