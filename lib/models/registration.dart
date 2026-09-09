class Registration {
  const Registration({
    required this.eventId,
    required this.sessionId,
    required this.quantity,
  });

  final String eventId;
  final String sessionId;
  final int quantity;

  Registration copyWith({
    String? eventId,
    String? sessionId,
    int? quantity,
  }) {
    return Registration(
      eventId: eventId ?? this.eventId,
      sessionId: sessionId ?? this.sessionId,
      quantity: quantity ?? this.quantity,
    );
  }
}
