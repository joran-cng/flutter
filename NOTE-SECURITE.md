# Note de sécurité — TP 8

## Pourquoi une règle serveur ne se remplace pas par du code client

Firestore expose une API REST et des SDKs ouverts. Un utilisateur peut installer une application modifiée, utiliser `curl` ou Postman avec un jeton d'authentification volé ou légitime, et envoyer des requêtes **sans passer par l'interface Flutter**.

### Scénario concret

Alice et Bob sont organisateurs authentifiés. Chaque événement dans la collection `events` porte un champ `ownerId` égal à l'UID du créateur.

Côté application, on masque le bouton « Supprimer » sur les événements dont `ownerId` n'est pas celui de l'utilisateur connecté, et on filtre la liste pour n'afficher que « ses » documents. Bob ouvre tout de même l'identifiant d'un document créé par Alice (par exemple en lisant le trafic réseau ou en devinant un ID), puis envoie une requête `PATCH` ou `DELETE` via l'API Firestore avec **son** jeton Firebase Auth.

- **Sans règles serveur** (ou avec des règles trop permissives), le serveur accepte la modification : les données d'Alice sont altérées ou supprimées.
- **Avec les règles du TP** (`resource.data.ownerId == request.auth.uid` pour lecture/écriture), le serveur **refuse** l'opération avec `permission-denied`, quel que soit le contenu de l'APK ou les boutons affichés.

Le client ne fait qu'améliorer l'expérience et réduire les erreurs involontaires ; il ne constitue **jamais** une barrière de sécurité. Seules les règles évaluées sur les serveurs Google (et, dans une moindre mesure, la validité du jeton Auth) définissent qui peut lire ou écrire quoi.
