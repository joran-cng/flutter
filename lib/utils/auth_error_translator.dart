import 'package:firebase_auth/firebase_auth.dart';

String translateAuthError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'email-already-in-use' =>
        'Cette adresse est déjà associée à un compte. Connectez-vous ou réinitialisez le mot de passe.',
      'invalid-email' => 'L\'adresse courriel n\'est pas valide.',
      'weak-password' =>
        'Le mot de passe est trop faible (au moins 6 caractères recommandés).',
      'invalid-credential' || 'wrong-password' =>
        'Courriel ou mot de passe incorrect.',
      'too-many-requests' =>
        'Trop de tentatives. Réessayez dans quelques minutes.',
      'operation-not-allowed' =>
        'La connexion par courriel n\'est pas activée sur ce projet.',
      _ =>
        'Une erreur d\'authentification est survenue. Réessayez plus tard.',
    };
  }
  return 'Une erreur inattendue est survenue. Réessayez plus tard.';
}
