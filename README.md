# flutter_application_1

Application Flutter — Event Planner (TP 5 — API REST).

> J'étais absent le jour du TP02 (absence justifiée). Comme convenu avec le professeur, je reprends directement au TP03 à partir de la correction du TP02, puis au TP04.

## Partie A — Callbacks vs `ChangeNotifier`

### Montage initial (callbacks, 5 incréments simulés)

| Widget | Appels à `build` |
| --- | --- |
| `EventTile` | 5 |
| `EventSection` | 5 |
| `CartBadge` | 5 |

L'état vivait dans `EventListScreen` et remontait par paramètres sur trois niveaux. Après un `push` vers un écran factice puis `pop`, le compteur était perdu car l'écran liste était reconstruit sans état global.

### Constat (A.2)

**(a) Plomberie de callbacks** — `EventSection` ne consomme pas le compteur mais doit le transmettre, ce qui couple les niveaux intermédiaires à une donnée qui ne les concerne pas.

**(b) Recompositions** — un seul incrément reconstruit la branche complète (section, tuile, badge) car le `setState` est déclenché au niveau racine.

**(c) Fragilité à la navigation** — l'état local meurt avec le widget qui le possède ; dès que la pile de navigation reconstruit l'écran liste, la valeur repart à zéro.

### Après migration Provider (5 ajouts au panier, `Selector` sur les tuiles)

| Widget | Appels à `build` |
| --- | --- |
| `EventTile` | 5 |
| `EventSection` | 0 |
| `CartBadge` | 5 |

`ChangeNotifierProvider<RegistrationCart>` est placé au-dessus du `MaterialApp`. Le compteur survit au `push`/`pop` car le notifier vit au-dessus de la navigation.

## Partie B — Panier et préférences

### Règles métier du panier

- **Doublon d'événement** : un même événement ne peut pas apparaître deux fois ; un nouvel ajout **met à jour** l'inscription existante (session + quantité).
- **Événement complet** : refus si `inscrits + places panier > capacité`.
- **Plafond utilisateur** : maximum **10 places** toutes inscriptions confondues (`RegistrationCart.maxUserPlaces`).

Chaque opération retourne un `CartOperationResult` exploitable (`success`, `updated`, `eventFull`, `quotaExceeded`, etc.).

### Badge universel

Scénario vérifié : ajout depuis l'écran détail → retour liste → le badge affiche déjà le total sans action supplémentaire.

## Partie C — Recomposition et injection

### C.1 — Consumer large vs `Selector` (3 ajouts panier + 1 changement de tri)

| Configuration | `EventTile` | `CartBadge` |
| --- | --- | --- |
| `Consumer<RegistrationCart>` sur chaque tuile | 27 | 3 |
| `Selector` (`isEventInCart` uniquement) | 3 | 3 |

Les chiffres proviennent des compteurs affichés en bas de l'écran liste (`BuildCounter`).

### C.2 — Choix `watch` / `read` / `select`

| Fichier | Donnée lue | Méthode | Justification |
| --- | --- | --- | --- |
| `event_tile.dart` — bouton +1 | panier (mutation) | `read` | Action ponctuelle, pas de rebuild |
| `event_tile.dart` — surbrillance | `isEventInCart` | `Selector` | Booléen isolé, évite rebuild sur tout le panier |
| `cart_badge.dart` | `totalPlaces` | `Selector` | Seul le total doit rafraîchir l'icône |
| `event_detail_screen.dart` | places réservées | `select` | Une seule valeur entière par événement |
| `event_list_screen.dart` | `EventListState` | `watch` | L'écran entier change selon loading/loaded/error |
| `event_list_screen.dart` | `DisplayPreferences` | `watch` | Filtres et tri impactent toute la liste |
| `cart_summary_screen.dart` | items du panier | `watch` | Liste complète à afficher |
| `main_shell.dart` | `EventRepository` | `read` | Lecture stable pour générer les routes |

### C.3 — Injection du dépôt

`EventRepository` est fourni par `Provider<EventRepository>`. `RegistrationCart` le reçoit via `ChangeNotifierProxyProvider` et **ne l'instancie jamais**. Cela permettra, en séance 5, de remplacer le dépôt en mémoire par une source réseau en changeant uniquement l'injection dans `main.dart`, sans modifier la logique du panier.

### C.4 — Machine à états liste

`EventListState` scellée : `EventListLoading`, `EventListLoaded`, `EventListError`. Chargement simulé avec `Future.delayed` (500 ms). Bouton « Simuler une erreur » pour tester le cas d'échec.

## Partie D — Frontière local / global

Panell « Aide rapide » sur l'écran liste : état ouvert/fermé via `ValueNotifier` local + `ValueListenableBuilder` (aucun `Provider`).

### Frontière état local / état global

**Critère retenu** : une donnée est globale si plusieurs écrans distants doivent la lire ou la modifier, ou si elle doit survivre à la navigation ; elle est locale si un seul sous-arbre en a besoin temporairement.

**Exemple local** — expansion du panneau d'aide : un seul widget consommateur, aucun impact sur le panier, état jetable à la destruction de l'écran.

**Exemple global** — `RegistrationCart` : badge sur tous les écrans, modifications depuis liste et détail, persistance tant que l'app tourne.

**Cas limite** — densité d'affichage (compact/confortable) : pourrait rester locale à l'écran liste, mais j'ai choisi `DisplayPreferences` global car le TP demande un second notifier indépendant et le réglage peut légitimement s'appliquer au détail ; le critère « nombre de consommateurs » aurait pu justifier un état local strict.

## TP 5 — Annuaire DummyJSON (API REST)

Accès : icône **Annuaire** sur l'écran d'accueil. L'état réseau de l'annuaire est **local** à `DirectoryScreen` (`FutureBuilder` au premier chargement, puis liste paginée), sans `Provider`, conformément au périmètre séance 5.

### Partie A — Premier appel

- Couche `lib/api/users_api.dart` : seul point d'accès HTTP (`Uri.https`, contrôle du code avant `jsonDecode`).
- `Participant.fromJson` défensif (champ absent, `null`, nombre en chaîne, `company` manquant → « Non renseigné »).
- Menu ⋮ dans l'AppBar annuaire : **Test chargement (delay 1,5 s)** et **Test erreur serveur (500)** pour les captures.

### Partie B — Annuaire complet

- Pagination 20 par 20 jusqu'à `total`, déclenchée avant le bas de liste.
- Chargement initial plein écran vs petit indicateur en pied de liste.
- Recherche (`/users/search`) + puces mots-clés ; état vide « Aucun résultat pour… » distinct de l'écran d'erreur réseau.
- Fiche détail (`/users/{id}`) avec téléphone/adresse.
- `RefreshIndicator` remet `skip` à 0.

### Partie C — Robustesse

**Client HTTP réutilisé** — `http.Client` instancié dans `DirectoryScreen` / `UsersApi`, fermé dans `dispose()`. Les appels statiques `http.get` recréent une connexion à chaque fois ; un client partagé réutilise la connexion TCP sous-jacente quand le serveur le permet.

**`compute`** — le parsing de la liste passe par un isolate (`parseUsersPageFromJson`). Sur 20 lignes le gain est négligeable ; l'intérêt apparaît quand le JSON devient volumineux (centaines d'entrées ou champs lourds), pour ne pas bloquer le fil UI pendant `jsonDecode`.

**Piège du `Future` recréé** — version fautive (observée en debug) :

```dart
FutureBuilder(
  future: _api.fetchUsers(), // recréé à chaque build → requêtes en rafale
  ...
)
```

Correction : `late Future<UsersPageResult> _initialFuture;` initialisée une seule fois dans `initState`, puis réassignée uniquement lors d'un rechargement explicite (refresh, menu test). Journal attendu : une requête au lancement ; plusieurs si le `future` est inline dans `build`.

**Nouvelles tentatives** — 3 essais max, délais 1 s / 2 s / 4 s, uniquement sur `NetworkException` ou `ServerException` 5xx. Les traces `[UsersApi …] nouvelle tentative` sont visibles en console avec le mode erreur 500.

**Timeout** — 10 s ; message utilisateur « Délai dépassé… ».

### Partie D (bonus) — POST `/users/add`

Bouton **Inscrire** : deux champs simples, envoi JSON, message de succès simulé. **Pas de nouvelle tentative automatique** sur le POST.

**Idempotence** — un `GET` peut être rejoué sans effet de bord. Rejouer un `POST` d'inscription après un timeout ambigu peut créer un doublon côté serveur réel ; d'où l'absence de retry sur `addParticipant`, contrairement aux lectures.

## Lancer l'application

```bash
flutter pub get
flutter run
```

## Captures

Voir le dossier `captures/`.
