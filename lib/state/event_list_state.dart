import 'package:flutter/foundation.dart';

import '../data/event_repository.dart';
import '../models/event.dart';

sealed class EventListState {}

class EventListLoading extends EventListState {}

class EventListLoaded extends EventListState {
  EventListLoaded(this.events);

  final List<Event> events;
}

class EventListError extends EventListState {
  EventListError(this.message);

  final String message;
}

class EventListNotifier extends ChangeNotifier {
  EventListNotifier({required EventRepository repository})
      : _repository = repository;

  EventRepository _repository;
  EventListState _state = EventListLoading();

  EventListState get state => _state;

  void updateRepository(EventRepository repository) {
    _repository = repository;
  }

  Future<void> load({bool simulateError = false}) async {
    _state = EventListLoading();
    notifyListeners();

    try {
      final events = await _repository.loadEvents(simulateError: simulateError);
      _state = EventListLoaded(events);
    } catch (error) {
      _state = EventListError(error.toString());
    }
    notifyListeners();
  }
}
