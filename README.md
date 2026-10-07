# flutter_application_1

Application Flutter — Event Planner (TP 8 — Firebase organisateur).

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

## TP 6 — Formulaires et validation

Accès : accueil → icône **Inscription** (`RegistrationScreen`) ou **Créer un événement** (`EventCreationScreen` → récapitulatif → confirmation). État des formulaires **local** au `State` de l'écran (pas de `Provider` pour la saisie). Soumission création d'événement : **mémoire** via `EventRepository.addFromDraft`, sans HTTP.

### Partie A — Inscription

`Form` + `GlobalKey<FormState>`, quatre `TextFormField`, validateurs dans `lib/validation/validators.dart`, navigation clavier (`FocusNode`, `TextInputAction.next` / `done`), `reset()` après `SnackBar`.

**Regex courriel** (détail ligne par ligne, pattern dans `validators.dart`) :

| Fragment | Rôle |
| --- | --- |
| `^` | début de chaîne |
| `[a-zA-Z0-9._%+-]+` | partie locale avant `@` |
| `@` | séparateur obligatoire |
| `[a-zA-Z0-9.-]+` | nom de domaine |
| `\.` | point avant l'extension |
| `[a-zA-Z]{2,}` | extension (au moins 2 lettres) |
| `$` | fin de chaîne |

### Partie B — Création d'événement

Douze contrôles intégrés au `Form`, contraintes croisées dans `lib/validation/cross_field_rules.dart` (`inscritsExistants = 12`). Convention tarif gratuit : **0 ou champ vide** acceptés si « événement gratuit » ; sinon tarif > 0 autorisé. Récapitulatif lecture seule (`EventSummaryScreen`) → `EventDraft` immuable → `SnackBar` avec titre + date.

### Partie C — Architecture

**Couche pure** — `lib/validation/` sans import Flutter ; les widgets n'utilisent que `compose([...])`.

**`dispose()`** — libération explicite :

| Écran | Contrôleurs | FocusNode |
| --- | --- | --- |
| `RegistrationScreen` | nom, ville, places, courriel | 4 nœuds |
| `EventCreationScreen` | titre, description, capacité, adresse, tarif | — |

Protocole fuite (observation) : commenter temporairement les `dispose()` des contrôleurs, rouvrir l'écran inscription dix fois via navigation : sans libération, la saisie peut devenir erratique et la mémoire monte au fil des allers-retours ; avec `dispose()` restauré, comportement stable.

**Autovalidation** :

| Champ | Mode | Justification |
| --- | --- | --- |
| Nom / ville / places (inscription) | `disabled` puis `onUserInteraction` après 1re soumission | pas d'erreur agressive avant tentative |
| Courriel (inscription) | idem | évite « email invalide » pendant la frappe |
| Titre / description (création) | `onUserInteraction` | retour rapide sur longueur |
| Capacité / adresse / tarif | après 1re soumission globale | champs sensibles aux règles croisées |
| Période (`DateRangeFormField`) | après 1re soumission | dates choisies par pickers |

**`DateRangeFormField`** — `FormField` personnalisé (début + fin), répond à `validate` / `save` / `reset`.

**`TwoDecimalsFormatter`** — bloque une 3e décimale après `,` ou `.`.

**Sortie non sauvegardée** — `PopScope` (`canPop: !_isDirty`) + dialogue ; API vérifiée avec Flutter 3.47.x (`onPopInvokedWithResult`).

### Tableau des règles (création + croisées)

| Champ | Règle | Message affiché | Cas limites testés |
| --- | --- | --- | --- |
| Nom complet (A) | obligatoire, 2–80 car. | messages `validators.dart` | vide, 1 caractère |
| Courriel (A) | regex ci-dessus | « Saisissez une adresse au format nom@domaine.ext » | vide, sans `@`, sans point domaine |
| Titre | obligatoire | « Indiquez un titre… » | vide |
| Description | 20–500 car. | messages longueur | 19 car., compteur 500 |
| Catégorie | obligatoire | « Choisissez une catégorie. » | aucune sélection |
| Capacité | entier > 0 | « …strictement positive » | 0, texte |
| Capacité (croisée) | ≥ 12 inscrits | « …au moins 12… » | capacité 10 |
| Adresse (croisée) | obligatoire si présentiel | « Indiquez l'adresse… » | en ligne vide / présentiel vide |
| Adresse (croisée) | vide si en ligne | « Effacez l'adresse… » | en ligne + adresse remplie |
| Période (croisée) | fin > début | « …postérieure… » | fin = début |
| Tarif (croisée) | 0 si gratuit | « Mettez le tarif à 0… » | gratuit + 15 € |
| Tarif (saisie) | format décimal | « …tarif valide… » | lettres |
| Conditions | obligatoire | SnackBar acceptation | non coché |

Partie D (Stepper multi-étapes) : non réalisée (bonus).

## TP 7 — Stockage local et préférences

### Partie A — `PreferencesStore`

- Clés : `lib/storage/preference_keys.dart` (`PreferenceKeys.all`).
- Implémentation : `SharedPreferencesWithCache` + `allowList: PreferenceKeys.all` (accesseurs synchrones après `init()`).
- **Choix API** : lectures fréquentes (thème, tri) au démarrage des écrans → cache avec `get` synchrones ; écritures via `set` async. `SharedPreferencesAsync` relirait la plateforme à chaque accès.
- **Démarrage** : `await preferencesStore.init()` dans `main()` avant `runApp` (pas de flash de thème par défaut).
- Écran **Réglages** (icône engrenage) ; sync vers `DisplayPreferences` pour la liste sans dupliquer la logique métier événements.

### Partie B — Brouillons JSON

- Modèle fichier : `lib/models/event_draft.dart` (`schemaVersion`, migration v1 `city` → v2 `location` + `reminderEnabled`).
- Dépôt : `DraftRepository` dans `Documents/event_drafts/`, noms `draft_<id>.json`.
- **Auto-save** : `DraftLifecycleObserver` sur `AppLifecycleState.paused`.
- Liste / édition / suppression unitaire et globale ; taille fichier affichée (`FileSizeFormat`).

**Fichier corrompu (démo)** : enregistrer un brouillon, localiser le `.json` via l'explorateur appareil ou `adb shell run-as …`, supprimer la dernière `}` avec un éditeur, rouvrir → message « Brouillon illisible ».

### Partie C — Robustesse

- **Écriture atomique** : `.json.tmp` puis `rename` vers le fichier final.
- **Migration** : `fromJson` accepte `schemaVersion: 1` avec champ `city`.
- **Purge** : fichiers `.tmp` du répertoire temporaire > 7 jours au lancement.
- **`compute`** : parsing en lot lors du listage de tous les brouillons.

| Répertoire | Durabilité | Sauvegarde système | Effaçable utilisateur |
| --- | --- | --- | --- |
| Documents | Oui (données app) | Souvent inclus (iCloud/Android backup) | Effacement données app |
| Support | Oui | Variable | Effacement données app |
| Temporaire | Non garanti | Non | Oui (cache) |

Brouillons en **Documents** : durables, hors cache volatile.

**Préférences vs fichiers** : ne pas y mettre la liste d'événements, le panier, ni des secrets ; contrat « petite config UI » vs fichier JSON atomique pour brouillons métier.

Partie D (export/import global) : non réalisée.

## TP 8 — Firebase Auth et Firestore

### Configuration Firebase (hors Git)

`lib/firebase_options.dart` et `android/app/google-services.json` **ne sont pas versionnés** (voir `.gitignore`) : ils contiennent des identifiants liés à ton projet Firebase. La sécurité des données repose sur **Authentication** et **Firestore rules**, pas sur la confidentialité de ces fichiers — mais ils ne doivent pas rester dans l’historique public du dépôt.

**Sur une machine neuve :**

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Choisir le projet Firebase, cocher **Android** (et Web/Windows si besoin). Les fichiers réels remplacent les modèles `*.example`. Des clés déjà exposées sur GitHub peuvent être restreintes dans [Google Cloud Console](https://console.cloud.google.com/) → APIs & Services → Credentials (recommandé après retrait du dépôt).

Déploiement des règles : `firebase deploy --only firestore:rules` (après `firebase init` si besoin) ou collage dans la console Firestore.

### Parcours Auth

- Garde racine : `AuthGate` + `StreamBuilder` sur `authStateChanges()` (pas de `Provider` pour l’auth).
- Écrans : connexion, inscription (`sendEmailVerification`), réinitialisation, profil (`updateDisplayName` + `userChanges()`), déconnexion (`signOut`) avec navigateurs séparés invité / connecté pour vider la pile.
- Erreurs : `lib/utils/auth_error_translator.dart` (six codes + défaut).

### Firestore `events`

- Champs : `title`, `ownerId`, `createdAt` (horodatage serveur), `location` optionnel.
- Liste temps réel : `where('ownerId')` + `orderBy('createdAt', descending: true)` + `snapshots()`.
- Bandeau **cache** si `snapshot.metadata.isFromCache` (données locales avant confirmation serveur).
- `permission-denied` : message utilisateur, pas de crash.

### Index composite

La requête ci-dessus exige un index composite `ownerId` + `createdAt`. Au premier lancement, Firestore renvoie une erreur avec un **lien de création d’index** dans la console : Firestore ne parcourt pas toute la collection côté serveur pour trier après un filtre d’égalité ; l’index pré-calculé est obligatoire pour des performances et un coût maîtrisé.

### Hors ligne (observation)

- **Lecture** : le cache local peut afficher la dernière liste connue ; l’icône « hors ligne » signale une source non confirmée serveur.
- **Écriture** : `add` / `delete` sont mis en file d’attente et réapparaissent localement ; sans réseau, la synchronisation reste en attente jusqu’au retour de connexion (ou échec si les règles refusent).

Partie D (émulateurs Firebase) : non réalisée.

## Lancer l'application

```bash
flutter pub get
flutter run
```

## Captures

Voir le dossier `captures/`.
