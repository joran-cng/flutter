# USAGE-IA — TP 3 — CAUNEGRE Joran

Outil(s) utilisé(s) : ChatGPT (GPT-4o) / Cursor (autocomplétion)
Déclaration : [ ] je n'ai utilisé aucune IA sur ce TP  /  [x] entrées ci-dessous

## Entrée 1
- Date et heure : 09/03/2026, 09h15
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
