import '../models/event.dart';
import '../models/event_creation_draft.dart';
import '../models/session.dart';

class EventRepository {
  const EventRepository();

  static const Duration loadDelay = Duration(milliseconds: 500);

  static final List<Event> _events = [
    Event(
      id: 'evt-001',
      title:
          'Conférence annuelle sur l\'ingénierie des systèmes distribués et la résilience logicielle',
      city: 'Lyon',
      venue: 'Centre des congrès',
      date: DateTime(2026, 9, 5, 9, 0),
      dateLabel: 'ven. 5 septembre, 09h00',
      category: 'Conférence',
      capacity: 300,
      registered: 180,
      imageUrl: 'https://picsum.photos/seed/event-distribues/400/400',
      sessions: const [
        Session(id: 's1-am', label: 'Matinée', schedule: '09h00 – 12h30'),
        Session(id: 's1-pm', label: 'Après-midi', schedule: '14h00 – 17h30'),
      ],
    ),
    Event(
      id: 'evt-002',
      title: 'Atelier Flutter avancé',
      city: 'Nantes',
      venue: 'Le Hangar',
      date: DateTime(2026, 9, 10, 9, 30),
      dateLabel: 'mer. 10 septembre, 09h30',
      category: 'Atelier',
      capacity: 40,
      registered: 40,
      imageUrl: 'https://picsum.photos/seed/event-flutter/400/400',
      sessions: const [
        Session(id: 's2-full', label: 'Journée complète', schedule: '09h30 – 17h00'),
      ],
    ),
    Event(
      id: 'evt-003',
      title: 'Meetup en ligne : observabilité et traces distribuées',
      city: '',
      venue: 'Diffusion en direct',
      date: DateTime(2026, 9, 15, 18, 0),
      dateLabel: 'lun. 15 septembre, 18h00',
      category: 'Meetup',
      capacity: 500,
      registered: 210,
      imageUrl: 'https://picsum.photos/seed/event-online/400/400',
      isOnline: true,
      sessions: const [
        Session(id: 's3-live', label: 'Session live', schedule: '18h00 – 20h00'),
      ],
    ),
    Event(
      id: 'evt-004',
      title: 'Table ronde : éthique et intelligence artificielle',
      city: 'Paris',
      venue: 'Maison de la Recherche',
      date: DateTime(2026, 9, 20, 19, 0),
      dateLabel: 'sam. 20 septembre, 19h00',
      category: 'Table ronde',
      capacity: 80,
      registered: 97,
      imageUrl: 'https://picsum.photos/seed/event-ethique/400/400',
      sessions: const [
        Session(id: 's4-evening', label: 'Soirée', schedule: '19h00 – 21h30'),
      ],
    ),
    Event(
      id: 'evt-005',
      title: 'Meetup mobile Kotlin & Flutter',
      city: 'Toulouse',
      venue: 'Espace de coworking La Cordée',
      date: DateTime(2026, 9, 22, 18, 30),
      dateLabel: 'lun. 22 septembre, 18h30',
      category: 'Meetup',
      capacity: 60,
      registered: 25,
      imageUrl: 'https://picsum.photos/seed/event-mobile/400/400',
      sessions: const [
        Session(id: 's5-a', label: 'Session A', schedule: '18h30 – 20h00'),
        Session(id: 's5-b', label: 'Session B', schedule: '20h15 – 21h45'),
      ],
    ),
    Event(
      id: 'evt-006',
      title: 'Atelier découverte du Dart',
      city: 'Bordeaux',
      venue: 'Campus numérique',
      date: DateTime(2026, 9, 25, 14, 0),
      dateLabel: 'jeu. 25 septembre, 14h00',
      category: 'Atelier',
      capacity: 30,
      registered: 12,
      imageUrl: 'https://picsum.photos/seed/event-dart/400/400',
      sessions: const [
        Session(id: 's6-workshop', label: 'Atelier pratique', schedule: '14h00 – 17h00'),
      ],
    ),
    Event(
      id: 'evt-007',
      title: 'Conférence : architectures hexagonales en pratique',
      city: 'Lille',
      venue: 'Auditorium Euratechnologies',
      date: DateTime(2026, 10, 1, 9, 0),
      dateLabel: 'mer. 1 octobre, 09h00',
      category: 'Conférence',
      capacity: 250,
      registered: 140,
      imageUrl: 'https://picsum.photos/seed/event-hexagonale/400/400',
      sessions: const [
        Session(id: 's7-am', label: 'Keynotes', schedule: '09h00 – 12h00'),
        Session(id: 's7-pm', label: 'Ateliers', schedule: '14h00 – 17h00'),
      ],
    ),
    Event(
      id: 'evt-008',
      title: 'Table ronde : carrières dans la tech',
      city: 'Marseille',
      venue: 'La Coque',
      date: DateTime(2026, 10, 4, 17, 30),
      dateLabel: 'sam. 4 octobre, 17h30',
      category: 'Table ronde',
      capacity: 120,
      registered: 45,
      imageUrl: 'https://picsum.photos/seed/event-carrieres/400/400',
      sessions: const [
        Session(id: 's8-panel', label: 'Panel', schedule: '17h30 – 19h30'),
      ],
    ),
  ];

  Future<List<Event>> loadEvents({bool simulateError = false}) async {
    await Future.delayed(loadDelay);
    if (simulateError) {
      throw Exception('Échec simulé du chargement des événements.');
    }
    return List.unmodifiable(_events);
  }

  Event? findById(String id) {
    for (final event in _events) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  void addFromDraft(EventCreationDraft draft) {
    final id = 'evt-new-${_events.length + 1}';
    final date = DateTime(
      draft.startDate.year,
      draft.startDate.month,
      draft.startDate.day,
      draft.startTime.hour,
      draft.startTime.minute,
    );
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final dateLabel =
        '$d/$m/${date.year} — ${draft.startTime.hour.toString().padLeft(2, '0')}h${draft.startTime.minute.toString().padLeft(2, '0')}';

    _events.add(
      Event(
        id: id,
        title: draft.title,
        city: draft.isOnline ? '' : _cityFromAddress(draft.address),
        venue: draft.isOnline
            ? 'Diffusion en direct'
            : (draft.address ?? 'Lieu à confirmer'),
        date: date,
        dateLabel: dateLabel,
        category: draft.category,
        capacity: draft.capacity,
        registered: 0,
        imageUrl: 'https://picsum.photos/seed/${id.hashCode}/400/400',
        isOnline: draft.isOnline,
        sessions: const [
          Session(
            id: 's-default',
            label: 'Session principale',
            schedule: 'Voir fiche',
          ),
        ],
      ),
    );
  }

  static String _cityFromAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return 'À préciser';
    }
    final parts = address.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }
    return address.trim();
  }

  List<Event> get allEvents => List.unmodifiable(_events);
}
