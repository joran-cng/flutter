import '../models/event.dart';

final List<Event> sampleEvents = [
  Event(
    id: 'evt-001',
    title:
        'Conférence annuelle sur l\'ingénierie des systèmes distribués et la résilience logicielle',
    city: 'Lyon',
    venue: 'Centre des congrès',
    date: DateTime(2026, 9, 5, 9, 0),
    category: 'Conférence',
    capacity: 300,
    registered: 180,
    imageUrl: 'https://picsum.photos/seed/event-distribues/400/400',
  ),
  Event(
    id: 'evt-002',
    title: 'Atelier Flutter avancé',
    city: 'Nantes',
    venue: 'Le Hangar',
    date: DateTime(2026, 9, 10, 9, 30),
    category: 'Atelier',
    capacity: 40,
    registered: 40,
    imageUrl: 'https://picsum.photos/seed/event-flutter/400/400',
    isSoldOut: true,
  ),
  Event(
    id: 'evt-003',
    title: 'Meetup en ligne : observabilité et traces distribuées',
    city: '',
    venue: 'Diffusion en direct',
    date: DateTime(2026, 9, 15, 18, 0),
    category: 'Meetup',
    capacity: 500,
    registered: 210,
    imageUrl: 'https://picsum.photos/seed/event-online/400/400',
    isOnline: true,
  ),
  Event(
    id: 'evt-004',
    title: 'Table ronde : éthique et intelligence artificielle',
    city: 'Paris',
    venue: 'Maison de la Recherche',
    date: DateTime(2026, 9, 20, 19, 0),
    category: 'Table ronde',
    capacity: 80,
    registered: 97,
    imageUrl: 'https://picsum.photos/seed/event-ethique/400/400',
  ),
  Event(
    id: 'evt-005',
    title: 'Meetup mobile Kotlin & Flutter',
    city: 'Toulouse',
    venue:
        'Espace de coworking La Cordée — bâtiment B, troisième étage, salle Ariane',
    date: DateTime(2026, 9, 22, 18, 30),
    category: 'Meetup',
    capacity: 60,
    registered: 25,
    imageUrl: 'https://picsum.photos/seed/event-mobile/400/400',
  ),
  Event(
    id: 'evt-006',
    title: 'Atelier découverte du Dart',
    city: 'Bordeaux',
    venue: 'Campus numérique',
    date: DateTime(2026, 9, 25, 14, 0),
    category: 'Atelier',
    capacity: 30,
    registered: 12,
    imageUrl: 'https://picsum.photos/seed/event-dart/400/400',
  ),
  Event(
    id: 'evt-007',
    title: 'Conférence : architectures hexagonales en pratique',
    city: 'Lille',
    venue: 'Auditorium Euratechnologies',
    date: DateTime(2026, 10, 1, 9, 0),
    category: 'Conférence',
    capacity: 250,
    registered: 140,
    imageUrl: 'https://picsum.photos/seed/event-hexagonale/400/400',
  ),
  Event(
    id: 'evt-008',
    title: 'Table ronde : carrières dans la tech',
    city: 'Marseille',
    venue: 'La Coque',
    date: DateTime(2026, 10, 4, 17, 30),
    category: 'Table ronde',
    capacity: 120,
    registered: 45,
    imageUrl: 'https://picsum.photos/seed/event-carrieres/400/400',
  ),
];

Event? findEventById(String id) {
  for (final event in sampleEvents) {
    if (event.id == id) {
      return event;
    }
  }
  return null;
}
