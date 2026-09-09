import 'package:flutter/foundation.dart';

enum EventSortCriterion { title, date, remainingPlaces }

enum DisplayDensity { comfortable, compact }

class DisplayPreferences extends ChangeNotifier {
  EventSortCriterion _sortCriterion = EventSortCriterion.title;
  String? _categoryFilter;
  DisplayDensity _density = DisplayDensity.comfortable;

  EventSortCriterion get sortCriterion => _sortCriterion;
  String? get categoryFilter => _categoryFilter;
  DisplayDensity get density => _density;

  void setSortCriterion(EventSortCriterion criterion) {
    if (_sortCriterion == criterion) {
      return;
    }
    _sortCriterion = criterion;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    if (_categoryFilter == category) {
      return;
    }
    _categoryFilter = category;
    notifyListeners();
  }

  void setDensity(DisplayDensity density) {
    if (_density == density) {
      return;
    }
    _density = density;
    notifyListeners();
  }
}
