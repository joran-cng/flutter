import 'package:flutter/material.dart';

import 'preferences_store.dart';

class AppPreferencesScope extends InheritedWidget {
  const AppPreferencesScope({
    super.key,
    required this.store,
    required this.onPreferencesChanged,
    required super.child,
  });

  final PreferencesStore store;
  final VoidCallback onPreferencesChanged;

  static AppPreferencesScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppPreferencesScope>();
    assert(scope != null, 'AppPreferencesScope missing');
    return scope!;
  }

  static PreferencesStore readStore(BuildContext context) {
    return of(context).store;
  }

  @override
  bool updateShouldNotify(AppPreferencesScope oldWidget) {
    return store != oldWidget.store;
  }
}
