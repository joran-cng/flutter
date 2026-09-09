import 'package:flutter/material.dart';

import '../screens/main_shell.dart';
import 'app_routes.dart';

void popToTabRoot(BuildContext context) {
  final navigator = Navigator.of(context);
  navigator.popUntil((route) => route.isFirst);

  final routeName = ModalRoute.of(context)?.settings.name;
  if (routeName == AppRoutes.home || routeName == AppRoutes.reservations) {
    return;
  }

  navigator.pushReplacementNamed(_tabRootRouteFor(context));
}

void navigateToHomeRoot(BuildContext context) {
  if (MainShell.goToHomeTabFrom(context)) {
    return;
  }

  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
    AppRoutes.home,
    (route) => false,
  );
}

String _tabRootRouteFor(BuildContext context) {
  if (MainShell.currentTabIndex(context) == 1) {
    return AppRoutes.reservations;
  }
  return AppRoutes.home;
}
