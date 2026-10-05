import 'package:flutter/material.dart';

import '../formatters/two_decimals_formatter.dart';
import '../fields/date_range_form_field.dart';
import '../models/event_draft.dart';
import '../routes/app_routes.dart';
import '../theme/spacing.dart';
import '../validation/cross_field_rules.dart';
import '../validation/date_range_value.dart';
import '../validation/validators.dart';

class EventCreationScreen extends StatefulWidget {
  const EventCreationScreen({super.key});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isOnline = false;
  bool _isFree = false;
  bool _acceptedTerms = false;
  bool _showAutoValidation = false;
  bool _isDirty = false;

  String? _category;
  TimeOfDay? _startTime;
  DateRangeValue? _dateRange;

  String? _addressCrossError;
  String? _dateCrossError;
  String? _priceCrossError;
  String? _capacityCrossError;

  static const _categories = [
    'Conférence',
    'Atelier',
    'Meetup',
    'Table ronde',
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _titleController,
      _descriptionController,
      _capacityController,
      _addressController,
      _priceController,
    ]) {
      controller.addListener(_markDirty);
    }
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) {
      return true;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonner la saisie ?'),
        content: const Text(
          'Des modifications n\'ont pas été enregistrées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuer'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _tryGoToSummary() {
    setState(() {
      _showAutoValidation = true;
      _addressCrossError = null;
      _dateCrossError = null;
      _priceCrossError = null;
      _capacityCrossError = null;
    });

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Acceptez les conditions d\'organisation pour continuer.',
          ),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final capacity = int.tryParse(_capacityController.text.trim());
    final cross = validateEventCrossFields(
      isOnline: _isOnline,
      addressText: _addressController.text,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
      isFree: _isFree,
      priceText: _priceController.text,
      capacity: capacity,
    );

    if (cross.hasErrors) {
      setState(() {
        _addressCrossError = cross.address;
        _dateCrossError = cross.dateRange;
        _priceCrossError = cross.price;
        _capacityCrossError = cross.capacity;
      });
      _formKey.currentState!.validate();
      return;
    }

    final priceText = _priceController.text.trim().replaceAll(',', '.');
    final price = _isFree
        ? 0.0
        : (priceText.isEmpty ? 0.0 : double.parse(priceText));

    final draft = EventDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category!,
      capacity: capacity!,
      isOnline: _isOnline,
      address: _isOnline ? null : _addressController.text.trim(),
      startDate: _dateRange!.start,
      endDate: _dateRange!.end,
      startTime: _startTime!,
      price: price,
      isFree: _isFree,
    );

    setState(() => _isDirty = false);
    Navigator.pushNamed(
      context,
      AppRoutes.eventSummary,
      arguments: draft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final leave = await _confirmDiscard();
        if (leave && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Créer un événement')),
        body: Form(
          key: _formKey,
          autovalidateMode: _showAutoValidation
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: eventTitleValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  counterText:
                      '${_descriptionController.text.length}/500',
                ),
                onChanged: (_) => setState(() {}),
                validator: eventDescriptionValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: Spacing.md),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                items: [
                  for (final cat in _categories)
                    DropdownMenuItem(value: cat, child: Text(cat)),
                ],
                onChanged: (value) {
                  setState(() => _category = value);
                  _markDirty();
                },
                validator: (value) =>
                    value == null ? 'Choisissez une catégorie.' : null,
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Capacité maximale',
                  errorText: _capacityCrossError,
                ),
                validator: eventCapacityValidator,
              ),
              SwitchListTile(
                title: const Text('Événement en ligne'),
                value: _isOnline,
                onChanged: (value) {
                  setState(() {
                    _isOnline = value;
                    _addressCrossError = null;
                  });
                  _markDirty();
                },
              ),
              TextFormField(
                controller: _addressController,
                enabled: !_isOnline,
                decoration: InputDecoration(
                  labelText: 'Adresse du lieu',
                  errorText: _addressCrossError,
                ),
                validator: (value) {
                  if (_isOnline) {
                    return null;
                  }
                  return requiredField(
                    message: 'Indiquez l\'adresse du lieu.',
                  )(value);
                },
              ),
              const SizedBox(height: Spacing.md),
              DateRangeFormField(
                initialValue: _dateRange,
                autovalidateMode: _showAutoValidation
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                validator: (value) {
                  if (value == null) {
                    return 'Choisissez les dates de début et de fin.';
                  }
                  if (_dateCrossError != null) {
                    return _dateCrossError;
                  }
                  return null;
                },
                onSaved: (value) => _dateRange = value,
              ),
              if (_dateCrossError != null)
                Text(
                  _dateCrossError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: Spacing.md),
              FormField<TimeOfDay>(
                validator: (value) =>
                    value == null ? 'Choisissez une heure de début.' : null,
                onSaved: (value) => _startTime = value,
                builder: (state) {
                  final label = state.value == null
                      ? 'Non renseignée'
                      : state.value!.format(context);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Heure de début'),
                        subtitle: Text(label),
                        trailing: const Icon(Icons.schedule),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: state.value ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            state.didChange(picked);
                            _markDirty();
                          }
                        },
                      ),
                      if (state.hasError)
                        Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [TwoDecimalsFormatter()],
                decoration: InputDecoration(
                  labelText: 'Tarif',
                  errorText: _priceCrossError,
                  helperText: _isFree
                      ? 'Tarif attendu : 0 si gratuit est coché.'
                      : null,
                ),
                validator: eventPriceValidator,
              ),
              CheckboxListTile(
                title: const Text('Événement gratuit'),
                value: _isFree,
                onChanged: (value) {
                  setState(() {
                    _isFree = value ?? false;
                    _priceCrossError = null;
                  });
                  _markDirty();
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('J\'accepte les conditions d\'organisation'),
                value: _acceptedTerms,
                onChanged: (value) {
                  setState(() => _acceptedTerms = value ?? false);
                  _markDirty();
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: Spacing.xl),
              FilledButton(
                onPressed: _tryGoToSummary,
                child: const Text('Voir le récapitulatif'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
