import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/event_repository.dart';
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

  static bool goToCartTabFrom(BuildContext context) {
    final state = context.findAncestorStateOfType<MainShellState>();
    if (state == null) {
      return false;
    }
    state.goToCartTab();
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
  final _cartNavigatorKey = GlobalKey<NavigatorState>();

  int _currentIndex = 0;

  int get currentTabIndex => _currentIndex;

  void goToHomeTab() {
    setState(() => _currentIndex = 0);
    _homeNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  void goToCartTab() {
    setState(() => _currentIndex = 1);
  }

  NavigatorState? get _activeNavigator {
    return switch (_currentIndex) {
      0 => _homeNavigatorKey.currentState,
      1 => _cartNavigatorKey.currentState,
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
    final repository = context.read<EventRepository>();

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
              onGenerateRoute: (settings) =>
                  RouteGenerator.onGenerateHomeTabRoute(settings, repository),
            ),
            Navigator(
              key: _cartNavigatorKey,
              initialRoute: AppRoutes.reservations,
              onGenerateRoute: (settings) =>
                  RouteGenerator.onGenerateReservationsTabRoute(
                    settings,
                    repository,
                  ),
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
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Panier',
            ),
          ],
        ),
      ),
    );
  }
}
