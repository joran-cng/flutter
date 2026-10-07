import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerEvent {
  const OrganizerEvent({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.createdAt,
    this.location,
    this.eventDate,
  });

  final String id;
  final String title;
  final String ownerId;
  final DateTime? createdAt;
  final String? location;
  final DateTime? eventDate;

  factory OrganizerEvent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final created = data['createdAt'];
    DateTime? createdAt;
    if (created is Timestamp) {
      createdAt = created.toDate();
    }
    final eventDateRaw = data['eventDate'];
    DateTime? eventDate;
    if (eventDateRaw is Timestamp) {
      eventDate = eventDateRaw.toDate();
    }

    return OrganizerEvent(
      id: snapshot.id,
      title: data['title'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      createdAt: createdAt,
      location: data['location'] as String?,
      eventDate: eventDate,
    );
  }

  Map<String, dynamic> toFirestoreCreate(String ownerId) {
    return {
      'title': title,
      'ownerId': ownerId,
      'location': location,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
