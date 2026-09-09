import '../models/participation_package.dart';

const List<ParticipationPackage> participationPackages = [
  ParticipationPackage(
    name: 'Standard',
    price: 29,
    description: 'Accès à la conférence et au support de présentation.',
  ),
  ParticipationPackage(
    name: 'Essentiel',
    price: 49,
    description: 'Conférence, support et accès à l\'enregistrement vidéo.',
  ),
  ParticipationPackage(
    name: 'VIP',
    price: 99,
    description: 'Accès premium, networking et place réservée en première rangée.',
  ),
];
