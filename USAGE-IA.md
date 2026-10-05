# USAGE-IA — TP 3 — CAUNEGRE Joran

Outil(s) utilisé(s) : Cursor (composer)

## Entrée 1
- Date et heure : 09/03/2026, 09h40
- Partie du TP concernée : Partie A.2 — migration vers routes nommées
- Pourquoi j'ai sollicité l'IA : je ne comprenais pas pourquoi la table `routes:` du `MaterialApp` ne suffisait pas pour passer un événement au détail
- Ce que j'ai demandé : une explication simple de la différence entre `routes:` et `onGenerateRoute`, avec un petit exemple
- Ce que j'ai obtenu : explication sur `RouteSettings.arguments` et proposition d'un fichier `app_routes.dart` avec des constantes
- Décision : acceptée après correction
- Si refusée ou corrigée, pourquoi : j'ai adapté l'exemple à mon projet (passage par `String id` plutôt que par l'objet `Event`)
- Correction apportée et vérification faite : navigation testée depuis trois cartes différentes du mur d'événements

## Entrée 2
- Date et heure : 09/03/2026, 10h40
- Partie du TP concernée : Partie B — valeur de retour de `pop`
- Pourquoi j'ai sollicité l'IA : hésitation sur le typage du `Future` retourné par `pushNamed` vers l'écran de sélection
- Ce que j'ai demandé : comment typer correctement le retour quand l'utilisateur annule avec le bouton retour
- Ce que j'ai obtenu : suggestion `Future<ParticipationPackage?>` et test `if (chosen == null) return;`
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : parcours complet testé (choix, annulation, puis nouvelle sélection jusqu'à la confirmation)

## Entrée 3
- Date et heure : 09/03/2026, 11h05
- Partie du TP concernée : Partie C.4 — `PopScope` et dialogue d'abandon
- Pourquoi j'ai sollicité l'IA : le dialogue s'affichait bien mais la navigation partait quand même au retour matériel
- Ce que j'ai demandé : un exemple minimal de `PopScope` avec `canPop: false` et confirmation avant de quitter
- Ce que j'ai obtenu : structure avec `onPopInvokedWithResult` et `showDialog`
- Décision : acceptée après correction
- Si refusée ou corrigée, pourquoi : j'ai aussi géré le bouton retour de l'`AppBar` manuellement pour le même comportement
- Correction apportée et vérification faite : retour matériel et retour `AppBar` testés sur l'écran de sélection

## Entrée 4
- Date et heure : 09/03/2026, 11h25
- Partie du TP concernée : Partie D — navigateurs imbriqués
- Pourquoi j'ai sollicité l'IA : une flèche de retour apparaissait sur l'onglet « Mes réservations » et menait à une page 404
- Ce que j'ai demandé : pourquoi une flèche s'affiche à la racine d'un onglet et comment l'éviter proprement
- Ce que j'ai obtenu : piste sur `automaticallyImplyLeading: false` et gestion de la route `/` dans le `Navigator` imbriqué
- Décision : acceptée après correction
- Si refusée ou corrigée, pourquoi : j'ai complété avec un retour à l'accueil qui bascule bien vers le bon onglet
- Correction apportée et vérification faite : plus de flèche parasite sur l'onglet réservations ; bouton « Retour à l'accueil » de la 404 fonctionnel

## Bilan
- Sur quoi l'IA m'a réellement fait gagner du temps : clarification des notions de routes nommées, typage du `Future` de retour et comportement de `PopScope`
- Sur quoi elle m'a coûté du temps : première proposition pour les onglets imbriqués incomplète, à ajuster après tests sur téléphone
- Ce que je saurais refaire sans elle à l'issue de ce TP : enchaîner `pushNamed`, récupérer un retour nullable, valider des arguments dans `onGenerateRoute`, et corriger une pile de navigation imbriquée

---

# USAGE-IA — TP 4 — CAUNEGRE Joran

Outil(s) utilisé(s) : Cursor (composer)

## Entrée 1
- Date et heure : 09/03/2026, 14h30
- Partie du TP concernée : Partie A.1 — callbacks sur trois niveaux
- Pourquoi j'ai sollicité l'IA : je ne voyais pas comment faire remonter un compteur de `EventTile` jusqu'à `CartBadge` sans tout passer en paramètres
- Ce que j'ai demandé : un schéma simple Parent → Section → Tile avec un callback `VoidCallback`
- Ce que j'ai obtenu : exemple avec `StatefulWidget` racine et props `count` / `onIncrement`
- Décision : acceptée après correction
- Si refusée ou corrigée, pourquoi : j'ai renommé les widgets pour coller au projet (`EventListScreen`, etc.)
- Correction apportée et vérification faite : compteur affiché dans l'AppBar et perte constatée après navigation

## Entrée 2
- Date et heure : 09/03/2026, 14h45
- Partie du TP concernée : Partie A.3 — premier `ChangeNotifier`
- Pourquoi j'ai sollicité l'IA : confusion sur l'emplacement exact du `ChangeNotifierProvider` par rapport au `MaterialApp`
- Ce que j'ai demandé : où placer le provider pour que le panier survive à la navigation
- Ce que j'ai obtenu : `MultiProvider` au-dessus de `MaterialApp`, consommation via `context.read` dans le bouton
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : compteur conservé après `push`/`pop` sur l'écran factice

## Entrée 3
- Date et heure : 09/03/2026, 15h05
- Partie du TP concernée : Partie B.2 — contraintes métier du panier
- Pourquoi j'ai sollicité l'IA : hésitation sur la politique « même événement ajouté deux fois »
- Ce que j'ai demandé : fusionner l'inscription ou refuser — quelle option est la plus cohérente
- Ce que j'ai obtenu : suggestion de mettre à jour quantité/session et retourner un enum `updated`
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : trois cas testés (double ajout, événement complet, plafond 10 places)

## Entrée 4
- Date et heure : 09/03/2026, 15h40
- Partie du TP concernée : Partie B — découplage `lib/state/`
- Pourquoi j'ai sollicité l'IA : erreur d'analyse car j'avais importé `material.dart` dans `registration_cart.dart`
- Ce que j'ai demandé : quels imports Flutter sont autorisés dans un `ChangeNotifier` métier
- Ce que j'ai obtenu : uniquement `foundation.dart` pour `ChangeNotifier`
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : `flutter analyze` sans import interdit dans `lib/state/`

## Entrée 5
- Date et heure : 09/03/2026, 16h00
- Partie du TP concernée : Partie B.5 — badge panier universel
- Pourquoi j'ai sollicité l'IA : le badge ne se mettait pas à jour depuis l'écran détail
- Ce que j'ai demandé : différence entre `Consumer` et `Selector` pour un simple entier dans l'AppBar
- Ce que j'ai obtenu : `Selector<RegistrationCart, int>` sur `totalPlaces`
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : ajout depuis le détail visible immédiatement sur la liste

## Entrée 6
- Date et heure : 09/03/2026, 16h25
- Partie du TP concernée : Partie C.1 — recompositions
- Pourquoi j'ai sollicité l'IA : trop de rebuilds quand j'utilisais `context.watch` sur toute la tuile
- Ce que j'ai demandé : exemple de `Selector` pour ne reconstruire que si l'événement est dans le panier
- Ce que j'ai obtenu : `Selector<RegistrationCart, bool>` avec `cart.isEventInCart(id)`
- Décision : acceptée après correction
- Si refusée ou corrigée, pourquoi : j'ai ajouté un compteur statique `BuildCounter` pour mesurer les `build`
- Correction apportée et vérification faite : tableau comparatif consigné dans le README

## Entrée 7
- Date et heure : 09/03/2026, 16h35
- Partie du TP concernée : Partie C.3 — `ChangeNotifierProxyProvider`
- Pourquoi j'ai sollicité l'IA : je ne comprenais pas le rôle du paramètre `update` dans le proxy
- Ce que j'ai demandé : à quoi sert `previousCart!..updateRepository(repository)`
- Ce que j'ai obtenu : réutiliser l'instance existante tout en rafraîchissant la dépendance injectée
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : `RegistrationCart` ne contient plus de `EventRepository()` en dur

## Entrée 8
- Date et heure : 09/03/2026, 16h40
- Partie du TP concernée : Partie C.4 — machine à états scellée
- Pourquoi j'ai sollicité l'IA : hésitation entre enum + booléens et `sealed class`
- Ce que j'ai demandé : exemple minimal de `sealed class EventListState` en Dart 3
- Ce que j'ai obtenu : trois sous-classes `Loading`, `Loaded`, `Error` et un `switch` exhaustif
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : chargement simulé avec `Future.delayed`, bouton d'erreur de test

## Entrée 9
- Date et heure : 09/03/2026, 16h40
- Partie du TP concernée : Partie D — `ValueNotifier` local
- Pourquoi j'ai sollicité l'IA : savoir si un panneau d'aide pliable doit aller dans un Provider
- Ce que j'ai demandé : critère simple pour trancher local vs global
- Ce que j'ai obtenu : `ValueNotifier` + `ValueListenableBuilder` si un seul widget consomme l'état
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : panneau « Aide rapide » sans aucun accès Provider

## Entrée 10
- Date et heure : 09/03/2026, 16h40
- Partie du TP concernée : Partie B.3 — `DisplayPreferences`
- Pourquoi j'ai sollicité l'IA : tri par places restantes — calcul côté écran ou notifier ?
- Ce que j'ai demandé : où appliquer le tri sans mettre de logique Flutter dans `display_preferences.dart`
- Ce que j'ai obtenu : le notifier stocke le critère, l'écran liste applique le tri sur la liste chargée
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : changement de tri visible sans redémarrer l'app

## Bilan
- Sur quoi l'IA m'a réellement fait gagner du temps : placement des providers, enum de retour panier, `Selector` vs `watch`, syntaxe `sealed class`
- Sur quoi elle m'a coûté du temps : première explication du proxy provider un peu abstraite, à recouper avec la doc officielle
- Ce que je saurais refaire sans elle à l'issue de ce TP : structurer un panier avec `ChangeNotifier`, exposer des préférences séparées, choisir `read`/`select` selon le rebuild voulu, injecter un dépôt avec `ChangeNotifierProxyProvider`

---

# USAGE-IA — TP 5 — CAUNEGRE Joran

Outil(s) utilisé(s) : ChatGPT (GPT-4o) / Cursor (autocomplétion)
Déclaration : [ ] je n'ai utilisé aucune IA sur ce TP  /  [x] entrées ci-dessous

## Entrée 1
- Date et heure : 05/10/2026, 08h35
- Partie du TP concernée : Partie A.2 — couche `UsersApi`
- Pourquoi j'ai sollicité l'IA : je ne savais pas où placer la vérification du `statusCode` par rapport au `jsonDecode`
- Ce que j'ai demandé : ordre des opérations pour un `http.get` avec DummyJSON
- Ce que j'ai obtenu : exemple avec branche `!= 200` avant tout décodage
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : erreur 500 affichée sans crash, test via le menu de l'annuaire

## Entrée 2
- Date et heure : 05/10/2026, 08h55
- Partie du TP concernée : Partie A.5 — `Participant.fromJson`
- Pourquoi j'ai sollicité l'IA : vérifier ma conversion quand `id` arrive en chaîne
- Ce que j'ai demandé : pattern Dart pour caster int ou String vers int avec repli
- Ce que j'ai obtenu : helper `_asInt` avec `int.tryParse`
- Décision : acceptée après correction
- Si refusée ou corrigée, pourquoi : j'ai aussi géré `company` absent séparément, pas seulement `name`
- Correction apportée et vérification faite : JSON local modifié à la main dans un test rapide, pas d'exception

## Entrée 3
- Date et heure : 05/10/2026, 09h15
- Partie du TP concernée : Partie B.1 — pagination
- Pourquoi j'ai sollicité l'IA : blocage sur le moment exact pour charger la page suivante
- Ce que j'ai demandé : exemple de `ScrollController` avec seuil avant la fin
- Ce que j'ai obtenu : comparaison `pixels >= maxScrollExtent - 200`
- Décision : acceptée après correction
- Si refusée ou corrigée, pourquoi : j'ai ajouté un garde-fou `_participants.length >= _total` pour ne plus appeler l'API
- Correction apportée et vérification faite : défilement jusqu'à la fin, plus de requête après 208 entrées (logs console)

## Entrée 4
- Date et heure : 05/10/2026, 09h40
- Partie du TP concernée : Partie C.4 — nouvelles tentatives
- Ce que j'ai demandé : boucle de retry avec délai croissant sur erreur 5xx
- Ce que j'ai obtenu : boucle `for` avec `Future.delayed` et liste de durées
- Décision : refusée en partie
- Si refusée ou corrigée, pourquoi : la première version relançait aussi les 404 ; j'ai limité aux `NetworkException` et 5xx seulement
- Correction apportée et vérification faite : mode erreur 500 → trois lignes horodatées dans la console espacées d'environ 1 s, 2 s, 4 s

## Entrée 5
- Date et heure : 05/10/2026, 10h00
- Partie du TP concernée : Partie C.6 — `FutureBuilder` recréé
- Pourquoi j'ai sollicité l'IA : je voyais plusieurs requêtes identiques au scroll du clavier
- Ce que j'ai demandé : pourquoi le `future:` se relance à chaque `build`
- Ce que j'ai obtenu : explication + pattern `late Future` dans `initState`
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : une seule requête au démarrage normal ; explication reprise dans le README

## Entrée 6
- Date et heure : 05/10/2026, 10h15
- Partie du TP concernée : Partie B.4 — état vide vs erreur
- Pourquoi j'ai sollicité l'IA : tentation d'afficher le même widget pour recherche vide et panne réseau
- Ce que j'ai demandé : idée de libellé pour « aucun résultat »
- Ce que j'ai obtenu : phrase avec le mot-clé entre guillemets
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : recherche « zzzzzz » → message gris neutre ; mode 500 → icône rouge + bouton Réessayer

## Bilan
- Sur quoi l'IA m'a réellement fait gagner du temps : squelette `Uri.https`, idée du seuil de scroll, rappel sur le `Future` mémorisé
- Sur quoi elle m'a coûté du temps : proposition de retry trop générique ; j'ai dû relire la consigne sur les 404
- Ce que je saurais refaire sans elle à l'issue de ce TP : enchaîner get → statut → decode, paginer avec `skip`/`total`, afficher trois états sans stack trace, fermer un `http.Client` dans `dispose`

---

# USAGE-IA — TP 6 — CAUNEGRE Joran

Outil(s) utilisé(s) : ChatGPT (GPT-4o) / Cursor (autocomplétion)
Déclaration : [ ] je n'ai utilisé aucune IA sur ce TP  /  [x] entrées ci-dessous

## Entrée 1
- Date et heure : 05/10/2026, 12h22
- Partie du TP concernée : Partie A — navigation clavier
- Pourquoi j'ai sollicité l'IA : je mélangeais `onSubmitted` du `TextField` et `onFieldSubmitted` du `TextFormField`
- Ce que j'ai demandé : enchaîner quatre champs avec `FocusNode` sans bouton « suivant »
- Ce que j'ai obtenu : `TextInputAction.next` + `FocusScope.of(context).requestFocus`
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : parcours complet au clavier jusqu'au `done` qui soumet

## Entrée 2
- Date et heure : 05/10/2026, 12h28
- Partie du TP concernée : Partie C.1 — `compose` de validateurs
- Pourquoi j'ai sollicité l'IA : éviter de dupliquer le test « non vide » sur chaque champ
- Ce que j'ai demandé : typedef `Validator` et fonction `compose`
- Ce que j'ai obtenu : boucle qui retourne la première erreur non nulle
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : aucun import Flutter dans `lib/validation/`

## Entrée 3
- Date et heure : 05/10/2026, 12h35
- Partie du TP concernée : Partie B — adresse vs « en ligne »
- Ce que j'ai demandé : où valider une règle qui dépend de deux champs
- Ce que j'ai obtenu : validation globale au clic, pas dans un seul `validator`
- Décision : acceptée après correction
- Si refusée ou corrigée, pourquoi : j'ai extrait la logique dans `cross_field_rules.dart` sans widget
- Correction apportée et vérification faite : en ligne + adresse remplie refusé au récapitulatif

## Entrée 4
- Date et heure : 05/10/2026, 12h42
- Partie du TP concernée : Partie C.4 — `DateRangeFormField`
- Pourquoi j'ai sollicité l'IA : synchroniser deux `showDatePicker` avec `FormFieldState.didChange`
- Ce que j'ai obtenu : squelette `FormField` avec `builder` et `onSaved`
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : `reset()` du formulaire parent remet la période

## Entrée 5
- Date et heure : 05/10/2026, 12h52
- Partie du TP concernée : Partie C.5 — `TwoDecimalsFormatter`
- Ce que j'ai demandé : bloquer une troisième décimale sans regex sur tout le champ
- Ce que j'ai obtenu : retourner `oldValue` si trop de chiffres après le séparateur
- Décision : acceptée telle quelle
- Correction apportée et vérification faite : saisie « 12,999 » reste « 12,99 »

## Entrée 6
- Date et heure : 05/10/2026, 13h00
- Partie du TP concernée : Partie C.6 — sortie non soumise
- Pourquoi j'ai sollicité l'IA : savoir quelle API Flutter utiliser pour intercepter le retour
- Ce que j'ai demandé : pattern avec `PopScope` sur Flutter 3.47
- Ce que j'ai obtenu : `canPop: false` + `onPopInvokedWithResult` + dialogue
- Décision : acceptée après correction
- Si refusée ou corrigée, pourquoi : j'ai branché le flag `_isDirty` sur les `TextEditingController` seulement
- Correction apportée et vérification faite : retour arrière après saisie titre → dialogue ; après confirmation création, pas de dialogue

## Bilan
- Sur quoi l'IA m'a réellement fait gagner du temps : enchaînement focus, squelette `FormField`, rappel `PopScope`
- Sur quoi elle m'a coûté du temps : première idée de règles croisées dans les `validator` individuels, à refactoriser
- Ce que je saurais refaire sans elle à l'issue de ce TP : structurer un `Form`, composer des validateurs purs, gérer `dispose` des contrôleurs, produire un modèle typé après `save()`
