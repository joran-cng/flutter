import 'package:flutter/widgets.dart';

class DraftLifecycleObserver with WidgetsBindingObserver {
  DraftLifecycleObserver({required this.onPaused});

  final Future<void> Function() onPaused;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      onPaused();
    }
  }
}
