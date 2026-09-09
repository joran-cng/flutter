import 'session.dart';

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.city,
    required this.venue,
    required this.date,
    required this.dateLabel,
    required this.category,
    required this.capacity,
    required this.registered,
    required this.imageUrl,
    required this.sessions,
    this.isOnline = false,
  });

  final String id;
  final String title;
  final String city;
  final String venue;
  final DateTime date;
  final String dateLabel;
  final String category;
  final int capacity;
  final int registered;
  final String imageUrl;
  final List<Session> sessions;
  final bool isOnline;

  int get remainingPlaces => capacity - registered;

  bool get isSoldOut => registered >= capacity;
}
