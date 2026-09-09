# flutter_application_1

Application Flutter — Event Planner (TP 2 + TP 3).

> J'étais absent le jour du TP02 (absence justifiée). Comme convenu avec le professeur, je reprends directement au TP03 à partir de la correction du TP02.

## TP 3 — Navigation et routes

### Flèche de retour automatique de l'AppBar (Partie A.1)

Lorsqu'un écran est empilé via `Navigator.push` ou `pushNamed`, Flutter insère automatiquement une `AppBar` avec un bouton retour dès que la pile contient plus d'une route. Ce comportement est géré par le `Navigator` et le widget `AppBar` (`automaticallyImplyLeading: true` par défaut) : aucun code supplémentaire n'est nécessaire.

### Pourquoi `routes:` seule est insuffisante pour le détail (Partie A.2)

La table statique `routes:` du `MaterialApp` ne permet de déclarer que des constructeurs sans arguments dynamiques connus à la compilation. Or la route de détail reçoit un identifiant (`String id`) choisi au moment du tap sur une carte. On emploie donc `onGenerateRoute`, qui lit `RouteSettings.arguments` au moment de la navigation et construit l'écran approprié (ou un écran d'erreur).

### `pushReplacement` sur la confirmation (Partie B)

L'écran de confirmation remplace l'écran de détail dans la pile (`pushReplacement` / `pushReplacementNamed`). Ainsi, le bouton retour matériel depuis la confirmation ne ramène ni sur la sélection de formule ni sur le détail (déjà retirés ou jamais empilés après le remplacement), mais directement sur le mur d'événements qui se trouvait sous le détail.

### Retour à l'accueil : `popUntil` plutôt que `pushAndRemoveUntil` (Partie B)

Le bouton « Retour à l'accueil » appelle `Navigator.popUntil((route) => route.isFirst)`. Ce choix préserve l'instance existante du mur d'événements (position de défilement incluse), alors que `pushAndRemoveUntil` recréerait un nouvel écran d'accueil en poussant une route fraîche.

### Erreurs d'arguments vs route 404 (Partie C)

Deux écrans distincts sont volontairement séparés :

- **`RouteErrorScreen`** : arguments absents, type inattendu ou identifiant valide mais inexistant dans le jeu de données — erreurs sur une route *connue* (`/event-detail`).
- **`NotFoundScreen`** : nom de route non enregistré (`onUnknownRoute`) — erreur d'adressage, pas de données.

Cette séparation clarifie le diagnostic pour l'utilisateur et le relecteur.

### Table des routes

| Nom de route | Constante | Arguments attendus | Type de retour |
| --- | --- | --- | --- |
| Accueil (coque à onglets) | `AppRoutes.home` | aucun | aucun (`void`) |
| Détail d'un événement | `AppRoutes.eventDetail` | `String id` | aucun (`void`) |
| Sélection de formule | `AppRoutes.packageSelection` | `String id` (événement) | `ParticipationPackage?` |
| Confirmation | `AppRoutes.confirmation` | `ConfirmationRouteArgs` | aucun (`void`) |
| Mes réservations | `AppRoutes.reservations` | aucun | aucun (`void`) |
| Route inconnue | *(aucune constante)* | libre | aucun (`void`) → `NotFoundScreen` |

### Réflexion : identifiant vs objet complet dans les arguments

Passer un identifiant plutôt qu'un objet `Event` complet dans les arguments de route transforme la route en contrat stable et sérialisable. Un identifiant est une primitive légère, comparable à un segment d'URL, facile à transmettre, à logger et à valider indépendamment de la taille ou de la structure de l'objet métier. En revanche, cela impose une résolution explicite (recherche dans le jeu de données local) et oblige à gérer les cas où l'identifiant est absent, mal typé ou inconnu — ce que centralise `RouteGenerator.resolveEventDetailArgs`.

Pour un **deep link** ouvrant directement l'écran de détail sans passer par l'accueil, l'identifiant est l'information minimale suffisante : une URL du type `/event-detail/evt-004` peut être mappée vers `AppRoutes.eventDetail` avec `arguments: 'evt-004'`, puis résolue côté application. Transporter l'objet complet sérialisé dans l'URL serait lourd, fragile et couplé à la structure interne du modèle.

Pour la **restauration d'état après redémarrage**, seul un identifiant (ou une pile de routes nommées + arguments sérialisables) peut être persisté de façon fiable : on sauvegarderait par exemple la route courante et son `String id`, puis au relancement on régénérerait l'écran via `onGenerateRoute` et `findEventById`. Un objet `Event` complet en mémoire ne survit pas au process kill ; il faudrait de toute façon le reconstruire depuis une source, ce qui revient conceptuellement à repasser par l'identifiant.

Enfin, l'identifiant découple la navigation de la provenance des données : aujourd'hui le jeu est codé en dur, demain il pourrait venir d'un cache ou d'un réseau, sans changer le contrat de la route. C'est cette stabilité du contrat qui justifie le choix imposé en Partie C, même si, dans ce TP, la résolution reste locale et synchrone.

## Partie D — Navigateurs imbriqués

Deux onglets (« Accueil », « Mes réservations ») disposent chacun d'un `Navigator` avec sa propre pile (`IndexedStack` + `GlobalKey<NavigatorState>`). Changer d'onglet ne réinitialise pas la pile quittée. Le bouton retour matériel dépile d'abord l'onglet actif ; lorsque sa pile est à la racine, il ramène au premier onglet.

## Lancer l'application

```bash
flutter pub get
flutter run
```

## Captures d'écran

Les captures du parcours complet se trouvent dans le dossier `captures/`.
