import 'package:flutter/foundation.dart';

import '../data/event_repository.dart';
import '../models/registration.dart';

enum CartOperationResult {
  success,
  updated,
  eventFull,
  quotaExceeded,
  notFound,
  invalidQuantity,
}

class RegistrationCart extends ChangeNotifier {
  RegistrationCart({required EventRepository repository})
      : _repository = repository;

  static const int maxUserPlaces = 10;

  EventRepository _repository;
  final List<Registration> _items = [];

  List<Registration> get items => List.unmodifiable(_items);

  int get totalPlaces =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  int get distinctEventCount =>
      _items.map((item) => item.eventId).toSet().length;

  int get count => totalPlaces;

  void updateRepository(EventRepository repository) {
    _repository = repository;
  }

  Registration? findByEventId(String eventId) {
    for (final item in _items) {
      if (item.eventId == eventId) {
        return item;
      }
    }
    return null;
  }

  bool isEventInCart(String eventId) => findByEventId(eventId) != null;

  int reservedPlacesForEvent(String eventId) {
    return findByEventId(eventId)?.quantity ?? 0;
  }

  CartOperationResult addRegistration({
    required String eventId,
    required String sessionId,
    int quantity = 1,
  }) {
    if (quantity <= 0) {
      return CartOperationResult.invalidQuantity;
    }

    final event = _repository.findById(eventId);
    if (event == null) {
      return CartOperationResult.notFound;
    }

    final existing = findByEventId(eventId);
    final previousQuantity = existing?.quantity ?? 0;
    final newQuantity = existing == null ? quantity : previousQuantity + quantity;
    final delta = newQuantity - previousQuantity;
    final projectedTotal = totalPlaces + delta;

    if (projectedTotal > maxUserPlaces) {
      return CartOperationResult.quotaExceeded;
    }

    final projectedEventTaken = event.registered + newQuantity;
    if (projectedEventTaken > event.capacity) {
      return CartOperationResult.eventFull;
    }

    if (existing == null) {
      _items.add(
        Registration(
          eventId: eventId,
          sessionId: sessionId,
          quantity: quantity,
        ),
      );
      notifyListeners();
      return CartOperationResult.success;
    }

    final index = _items.indexOf(existing);
    _items[index] = existing.copyWith(
      sessionId: sessionId,
      quantity: newQuantity,
    );
    notifyListeners();
    return CartOperationResult.updated;
  }

  CartOperationResult removeRegistration(String eventId) {
    final removed = _items.where((item) => item.eventId == eventId).length;
    if (removed == 0) {
      return CartOperationResult.notFound;
    }
    _items.removeWhere((item) => item.eventId == eventId);
    notifyListeners();
    return CartOperationResult.success;
  }

  CartOperationResult updateQuantity(String eventId, int quantity) {
    if (quantity <= 0) {
      return removeRegistration(eventId);
    }

    final existing = findByEventId(eventId);
    if (existing == null) {
      return CartOperationResult.notFound;
    }

    final event = _repository.findById(eventId);
    if (event == null) {
      return CartOperationResult.notFound;
    }

    final delta = quantity - existing.quantity;
    final projectedTotal = totalPlaces + delta;
    if (projectedTotal > maxUserPlaces) {
      return CartOperationResult.quotaExceeded;
    }

    if (event.registered + quantity > event.capacity) {
      return CartOperationResult.eventFull;
    }

    final index = _items.indexOf(existing);
    _items[index] = existing.copyWith(quantity: quantity);
    notifyListeners();
    return CartOperationResult.success;
  }
}
