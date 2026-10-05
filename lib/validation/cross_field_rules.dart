const int inscritsExistants = 12;

class EventCrossFieldErrors {
  const EventCrossFieldErrors({
    this.address,
    this.dateRange,
    this.price,
    this.capacity,
  });

  final String? address;
  final String? dateRange;
  final String? price;
  final String? capacity;

  bool get hasErrors =>
      address != null ||
      dateRange != null ||
      price != null ||
      capacity != null;
}

EventCrossFieldErrors validateEventCrossFields({
  required bool isOnline,
  required String addressText,
  required DateTime? startDate,
  required DateTime? endDate,
  required bool isFree,
  required String priceText,
  required int? capacity,
}) {
  String? addressError;
  if (isOnline && addressText.trim().isNotEmpty) {
    addressError =
        'Effacez l\'adresse ou désactivez « événement en ligne ».';
  } else if (!isOnline && addressText.trim().length < 2) {
    addressError =
        'Indiquez l\'adresse du lieu pour un événement en présentiel.';
  }

  String? dateRangeError;
  if (startDate == null || endDate == null) {
    dateRangeError = null;
  } else if (!endDate.isAfter(startDate)) {
    dateRangeError =
        'Choisissez une date de fin postérieure à la date de début.';
  }

  String? priceError;
  final normalized = priceText.trim().replaceAll(',', '.');
  final parsedPrice =
      normalized.isEmpty ? 0.0 : double.tryParse(normalized) ?? -1;
  if (isFree && parsedPrice > 0) {
    priceError =
        'Mettez le tarif à 0 ou décochez « événement gratuit ».';
  }

  String? capacityError;
  if (capacity != null && capacity < inscritsExistants) {
    capacityError =
        'La capacité doit être au moins $inscritsExistants (places déjà réservées).';
  }

  return EventCrossFieldErrors(
    address: addressError,
    dateRange: dateRangeError,
    price: priceError,
    capacity: capacityError,
  );
}
