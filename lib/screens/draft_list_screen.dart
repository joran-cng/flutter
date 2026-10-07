import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../storage/draft_repository.dart';
import '../theme/spacing.dart';
import '../utils/file_size_format.dart';

class DraftListScreen extends StatefulWidget {
  const DraftListScreen({super.key});

  @override
  State<DraftListScreen> createState() => _DraftListScreenState();
}

class _DraftListScreenState extends State<DraftListScreen> {
  late Future<List<DraftFileInfo>> _future;

  @override
  void initState() {
    super.initState();
    _future = DraftRepository.instance.listDrafts();
  }

  void _reload() {
    setState(() {
      _future = DraftRepository.instance.listDrafts();
    });
  }

  Future<void> _deleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tout supprimer ?'),
        content: const Text('Tous les brouillons seront effacés du disque.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true) {
      return;
    }
    await DraftRepository.instance.deleteAllDrafts();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brouillons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _deleteAll,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.draftEdit);
          _reload();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<DraftFileInfo>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Aucun brouillon enregistré.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(Spacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final dateLabel = _formatDateTime(item.lastModified);
              return ListTile(
                title: Text(item.displayTitle),
                subtitle: Text(
                  '$dateLabel — ${FileSizeFormat.formatBytes(item.fileSizeBytes)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await DraftRepository.instance.deleteDraft(item.draftId);
                    _reload();
                  },
                ),
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    AppRoutes.draftEdit,
                    arguments: item.draftId,
                  );
                  _reload();
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/${date.year} $h:$min';
  }
}
