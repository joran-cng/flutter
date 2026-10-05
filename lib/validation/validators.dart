typedef Validator = String? Function(String? value);

Validator requiredField({String message = 'Ce champ est obligatoire.'}) {
  return (value) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  };
}

Validator minLength(
  int min, {
  String Function(int min)? message,
}) {
  return (value) {
    if (value == null || value.trim().length < min) {
      return message?.call(min) ??
          'Saisissez au moins $min caractères.';
    }
    return null;
  };
}

Validator maxLength(
  int max, {
  String Function(int max)? message,
}) {
  return (value) {
    if (value != null && value.length > max) {
      return message?.call(max) ??
          'Ne dépassez pas $max caractères.';
    }
    return null;
  };
}

Validator matchesPattern(
  RegExp pattern, {
  required String message,
}) {
  return (value) {
    if (value == null || !pattern.hasMatch(value.trim())) {
      return message;
    }
    return null;
  };
}

Validator compose(List<Validator> validators) {
  return (value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  };
}

final RegExp emailPattern = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

Validator get emailValidator => compose([
      requiredField(message: 'Indiquez votre courriel de contact.'),
      matchesPattern(
        emailPattern,
        message: 'Saisissez une adresse au format nom@domaine.ext',
      ),
    ]);

Validator get fullNameValidator => compose([
      requiredField(message: 'Indiquez votre nom complet.'),
      minLength(2, message: (_) => 'Le nom doit contenir au moins 2 caractères.'),
      maxLength(80, message: (_) => 'Le nom ne peut pas dépasser 80 caractères.'),
    ]);

Validator get cityValidator => compose([
      requiredField(message: 'Indiquez votre ville de résidence.'),
      minLength(2, message: (_) => 'La ville doit contenir au moins 2 caractères.'),
    ]);

Validator get positiveIntValidator => compose([
      requiredField(message: 'Indiquez le nombre de places souhaité.'),
      (value) {
        final parsed = int.tryParse(value?.trim() ?? '');
        if (parsed == null || parsed <= 0) {
          return 'Saisissez un entier strictement positif.';
        }
        return null;
      },
    ]);

Validator get eventTitleValidator => compose([
      requiredField(message: 'Indiquez un titre pour l\'événement.'),
      minLength(2),
    ]);

Validator get eventDescriptionValidator => compose([
      requiredField(message: 'Rédigez une description.'),
      minLength(
        20,
        message: (_) =>
            'La description doit contenir au moins 20 caractères.',
      ),
      maxLength(
        500,
        message: (_) => 'La description ne peut pas dépasser 500 caractères.',
      ),
    ]);

Validator get eventCapacityValidator => compose([
      requiredField(message: 'Indiquez la capacité maximale.'),
      (value) {
        final parsed = int.tryParse(value?.trim() ?? '');
        if (parsed == null || parsed <= 0) {
          return 'Saisissez une capacité entière strictement positive.';
        }
        return null;
      },
    ]);

Validator get eventPriceValidator => (value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final normalized = value.trim().replaceAll(',', '.');
  final parsed = double.tryParse(normalized);
  if (parsed == null || parsed < 0) {
    return 'Saisissez un tarif valide (ex. 12,50).';
  }
  return null;
};
