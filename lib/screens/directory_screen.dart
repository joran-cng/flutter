import 'package:flutter/material.dart';

import '../api/exceptions.dart';
import '../api/users_api.dart';
import '../models/participant.dart';
import '../routes/app_routes.dart';
import '../theme/spacing.dart';
import '../widgets/participant_tile.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  late UsersApi _api;
  late Future<UsersPageResult> _initialFuture;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<Participant> _participants = [];
  int _total = 0;
  bool _hasBootstrapped = false;
  bool _loadingMore = false;
  bool _isSearchMode = false;
  String _activeQuery = '';
  bool _simulateDelay = false;
  bool _forceServerError = false;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _api = UsersApi(
      simulateDelay: _simulateDelay,
      forceServerError: _forceServerError,
    );
    _initialFuture = _api.fetchUsers(limit: _pageSize, skip: 0);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _api.close();
    super.dispose();
  }

  void _onScroll() {
    if (_isSearchMode || _loadingMore) {
      return;
    }
    if (_participants.length >= _total) {
      return;
    }
    final position = _scrollController.position;
    if (!position.hasPixels || !position.hasContentDimensions) {
      return;
    }
    final threshold = position.maxScrollExtent - 240;
    if (position.pixels >= threshold) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingMore || _participants.length >= _total) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final page = await _api.fetchUsers(
        limit: _pageSize,
        skip: _participants.length,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _participants.addAll(page.users);
        _total = page.total;
        _loadingMore = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingMore = false);
      _showSnackBar(error.message);
    }
  }

  Future<void> _refreshList() async {
    setState(() {
      _participants.clear();
      _total = 0;
      _isSearchMode = false;
      _activeQuery = '';
      _searchError = null;
      _searchController.clear();
      _hasBootstrapped = false;
      _initialFuture = _api.fetchUsers(limit: _pageSize, skip: 0);
    });
    try {
      final page = await _initialFuture;
      if (!mounted) {
        return;
      }
      setState(() {
        _hasBootstrapped = true;
        _participants.addAll(page.users);
        _total = page.total;
      });
    } on ApiException {
      if (!mounted) {
        return;
      }
      rethrow;
    }
  }

  Future<void> _runSearch(String query) async {
    final trimmed = query.trim();
    setState(() {
      _isSearchMode = trimmed.isNotEmpty;
      _activeQuery = trimmed;
      _participants.clear();
      _total = 0;
      _loadingMore = false;
      _hasBootstrapped = true;
    });

    try {
      final page = trimmed.isEmpty
          ? await _api.fetchUsers(limit: _pageSize, skip: 0)
          : await _api.searchUsers(trimmed);
      if (!mounted) {
        return;
      }
      setState(() {
        _participants.addAll(page.users);
        _total = page.total;
        if (trimmed.isEmpty) {
          _isSearchMode = false;
        }
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _participants.clear();
        _searchError = error.message;
      });
    }
  }

  String? _searchError;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openDetail(Participant participant) {
    Navigator.pushNamed(
      context,
      AppRoutes.participantDetail,
      arguments: participant.id,
    );
  }

  void _recreateApi({required bool delay, required bool error500}) {
    _api.close();
    setState(() {
      _simulateDelay = delay;
      _forceServerError = error500;
      _participants.clear();
      _total = 0;
      _searchError = null;
      _isSearchMode = false;
      _activeQuery = '';
      _hasBootstrapped = false;
      _api = UsersApi(
        simulateDelay: delay,
        forceServerError: error500,
      );
      _initialFuture = _api.fetchUsers(limit: _pageSize, skip: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasBootstrapped) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: FutureBuilder<UsersPageResult>(
          future: _initialFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorBody(
                message: _messageFor(snapshot.error!),
                onRetry: () => _recreateApi(
                  delay: _simulateDelay,
                  error500: _forceServerError,
                ),
              );
            }
            if (snapshot.hasData) {
              final page = snapshot.data!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _hasBootstrapped) {
                  return;
                }
                setState(() {
                  _hasBootstrapped = true;
                  _participants.addAll(page.users);
                  _total = page.total;
                });
              });
              if (page.users.isEmpty) {
                return const _EmptySearchBody(query: '');
              }
              return ListView.builder(
                itemCount: page.users.length,
                itemBuilder: (context, index) {
                  final participant = page.users[index];
                  return ParticipantTile(
                    participant: participant,
                    onTap: () => _openDetail(participant),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: _buildListBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRegistrationSheet(context),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Inscrire'),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Annuaire participants'),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delay':
                _recreateApi(delay: true, error500: false);
              case 'error500':
                _recreateApi(delay: false, error500: true);
              case 'normal':
                _recreateApi(delay: false, error500: false);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'delay',
              child: Text('Test chargement (delay 1,5 s)'),
            ),
            PopupMenuItem(
              value: 'error500',
              child: Text('Test erreur serveur (500)'),
            ),
            PopupMenuItem(
              value: 'normal',
              child: Text('Mode normal'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListBody() {
    if (_searchError != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: _ErrorBody(
              message: _searchError!,
              onRetry: () {
                setState(() => _searchError = null);
                _runSearch(_activeQuery);
              },
            ),
          ),
        ],
      );
    }

    if (_participants.isEmpty && _isSearchMode) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        children: [
          _SearchHeader(
            controller: _searchController,
            onSearch: _runSearch,
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: _EmptySearchBody(query: _activeQuery),
          ),
        ],
      );
    }

    if (_participants.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _SearchHeader(
            controller: _searchController,
            onSearch: _runSearch,
          ),
          const SizedBox(height: Spacing.xl),
          const Center(child: Text('Aucun participant à afficher.')),
        ],
      );
    }

    final showFooter =
        _loadingMore && !_isSearchMode && _participants.length < _total;

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _participants.length + 1 + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _SearchHeader(
            controller: _searchController,
            onSearch: _runSearch,
          );
        }

        final dataIndex = index - 1;
        if (dataIndex >= _participants.length) {
          return const Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final participant = _participants[dataIndex];
        return ParticipantTile(
          participant: participant,
          onTap: () => _openDetail(participant),
        );
      },
    );
  }

  Future<void> _showRegistrationSheet(BuildContext context) async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: Spacing.lg,
            right: Spacing.lg,
            top: Spacing.lg,
            bottom: MediaQuery.viewInsetsOf(context).bottom + Spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Inscription rapide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              const SizedBox(height: Spacing.sm),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Envoyer'),
              ),
            ],
          ),
        );
      },
    );

    if (submitted != true || !mounted) {
      firstNameController.dispose();
      lastNameController.dispose();
      return;
    }

    try {
      final created = await _api.addParticipant(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      _showSnackBar('Inscription simulée : ${created.fullName} (#${created.id})');
    } on ApiException catch (error) {
      if (mounted) {
        _showSnackBar(error.message);
      }
    } finally {
      firstNameController.dispose();
      lastNameController.dispose();
    }
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Le service est momentanément indisponible, veuillez réessayer.';
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Rechercher',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => onSearch(controller.text),
              ),
            ),
            onSubmitted: onSearch,
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            children: [
              for (final keyword in ['Emily', 'Michael', 'Sarah'])
                ActionChip(
                  label: Text(keyword),
                  onPressed: () {
                    controller.text = keyword;
                    onSearch(keyword);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchBody extends StatelessWidget {
  const _EmptySearchBody({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              query.isEmpty
                  ? 'Aucun participant.'
                  : 'Aucun résultat pour « $query ».',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
