class Event {
  const Event({
    required this.id,
    required this.title,
    required this.city,
    required this.venue,
    required this.date,
    required this.category,
    required this.capacity,
    required this.registered,
    required this.imageUrl,
    this.isSoldOut = false,
    this.isOnline = false,
  });

  final String id;
  final String title;
  final String city;
  final String venue;
  final DateTime date;
  final String category;
  final int capacity;
  final int registered;
  final String imageUrl;
  final bool isSoldOut;
  final bool isOnline;
}
