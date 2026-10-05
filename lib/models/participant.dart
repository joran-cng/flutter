class Participant {
  const Participant({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.imageUrl,
    required this.companyName,
    this.phone,
    this.addressLine,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String imageUrl;
  final String companyName;
  final String? phone;
  final String? addressLine;

  String get fullName => '$firstName $lastName'.trim();

  factory Participant.fromJson(Map<String, dynamic> json) {
    final company = json['company'];
    String companyName = 'Non renseigné';
    if (company is Map<String, dynamic>) {
      companyName = _asString(company['name'], fallback: 'Non renseigné');
    }

    String? addressLine;
    final address = json['address'];
    if (address is Map<String, dynamic>) {
      final street = _asString(address['address'], fallback: '');
      final city = _asString(address['city'], fallback: '');
      final combined = [street, city].where((part) => part.isNotEmpty).join(', ');
      if (combined.isNotEmpty) {
        addressLine = combined;
      }
    }

    final phoneRaw = json['phone'];
    final phone = phoneRaw == null
        ? null
        : _asString(phoneRaw, fallback: '').isEmpty
            ? null
            : _asString(phoneRaw, fallback: '');

    return Participant(
      id: _asInt(json['id']),
      firstName: _asString(json['firstName'], fallback: 'Non renseigné'),
      lastName: _asString(json['lastName'], fallback: 'Non renseigné'),
      email: _asString(json['email'], fallback: 'Non renseigné'),
      imageUrl: _asString(json['image'], fallback: ''),
      companyName: companyName,
      phone: phone,
      addressLine: addressLine,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'image': imageUrl,
      'company': {'name': companyName},
      if (phone != null) 'phone': phone,
    };
  }

  static int _asInt(Object? value, {int fallback = 0}) {
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static String _asString(Object? value, {required String fallback}) {
    if (value == null) {
      return fallback;
    }
    if (value is String) {
      return value.isEmpty ? fallback : value;
    }
    return value.toString();
  }
}
