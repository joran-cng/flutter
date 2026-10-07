import 'package:flutter/material.dart';

import '../models/event_draft.dart';
import '../storage/draft_lifecycle_observer.dart';
import '../storage/draft_repository.dart';
import '../theme/spacing.dart';

class DraftEditScreen extends StatefulWidget {
  const DraftEditScreen({super.key, this.draftId});

  final String? draftId;

  @override
  State<DraftEditScreen> createState() => _DraftEditScreenState();
}

class _DraftEditScreenState extends State<DraftEditScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();

  late String _draftId;
  DateTime? _eventDate;
  String? _loadError;
  bool _loading = true;
  late DraftLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _draftId = widget.draftId ?? EventDraft.empty().id;
    _lifecycleObserver = DraftLifecycleObserver(onPaused: _saveDraftSilently);
    _lifecycleObserver.attach();
    _load();
  }

  Future<void> _load() async {
    final result = await DraftRepository.instance.loadDraft(_draftId);
    if (!mounted) {
      return;
    }
    if (!result.isSuccess) {
      setState(() {
        _loadError = result.errorMessage;
        _loading = false;
      });
      return;
    }
    final draft = result.draft!;
    _titleController.text = draft.title;
    _locationController.text = draft.location;
    _categoryController.text = draft.category;
    setState(() {
      _eventDate = draft.eventDate;
      _loading = false;
      _loadError = null;
    });
  }

  EventDraft _currentDraft() {
    return EventDraft(
      id: _draftId,
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      eventDate: _eventDate,
      category: _categoryController.text.trim(),
      lastModified: DateTime.now(),
    );
  }

  Future<void> _saveDraftSilently() async {
    await DraftRepository.instance.saveDraft(_currentDraft());
  }

  Future<void> _saveManual() async {
    await _saveDraftSilently();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Brouillon enregistré.')),
    );
  }

  @override
  void dispose() {
    _lifecycleObserver.detach();
    _titleController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Édition brouillon')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Édition brouillon')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      );
    }

    final dateLabel = _eventDate == null
        ? 'Non définie'
        : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Édition brouillon')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
          ),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Ville / lieu'),
          ),
          const SizedBox(height: Spacing.md),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Catégorie'),
          ),
          const SizedBox(height: Spacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date de l\'événement'),
            subtitle: Text(dateLabel),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _eventDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                setState(() => _eventDate = picked);
              }
            },
          ),
          const SizedBox(height: Spacing.xl),
          FilledButton(
            onPressed: _saveManual,
            child: const Text('Enregistrer le brouillon'),
          ),
        ],
      ),
    );
  }
}
