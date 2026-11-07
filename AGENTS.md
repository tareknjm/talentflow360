# Instructions de travail — TalentFlow 360

## Communication

- Répondre en français et expliquer les manipulations pour un débutant Salesforce connaissant Java/Spring Boot.
- À chaque bilan, distinguer clairement : réalisé, vérifié, bloqué et prochaine action.
- Mettre `docs/progress.md` à jour après chaque étape significative.

## Méthode

- Lire les fichiers existants avant toute modification et préserver les changements du binôme.
- Avancer dans l'ordre des phases, une fonctionnalité testable à la fois.
- Ne jamais confondre fichier local, métadonnée déployée, composant activé et fonctionnalité testée.
- Utiliser les pages et composants Lightning standard avant d'ajouter un LWC.
- Conserver l'API version définie par `sfdx-project.json`, sauf décision documentée.
- Ne pas créer un second projet dans un sous-dossier `talentflow360`.

## Salesforce et sécurité

- Vérifier la cible avant toute mutation distante. La cible de développement attendue est l'alias `TFDev`, mais son existence ou sa validité ne doit jamais être supposée.
- Ne jamais déployer vers une org de production inconnue.
- Ne jamais demander, afficher ou committer un mot de passe, jeton, fichier d'authentification ou donnée personnelle réelle.
- Utiliser uniquement des données synthétiques et ne déclencher aucun message externe pendant le seed ou les tests par défaut.
- L'agent ne doit recevoir ni identité, ni email, ni CV brut, ni champ d'approbation, ni note RH privée.
- L'agent ne classe pas les candidats et ne peut ni embaucher ni rejeter. La validation humaine reste dans un parcours séparé et non exposé à l'agent.
- Une preuve Agentforce exige un véritable appel d'action observable ; aucune réponse statique ne compte comme intégration.

## Validation

- Exécuter les tests accessibles et consigner date, environnement et résultat réel dans `docs/test-results.md` lorsque ce fichier sera créé.
- Employer les statuts `Passed`, `Failed`, `Blocked` et `NotRun`. Un test écrit mais non exécuté reste `NotRun`.
- Les opérations manuelles dans Setup doivent être numérotées dans `docs/setup.md`, avec le résultat attendu.
- Ne pas annoncer de conformité, d'absence universelle de biais, de gain métier ou de reproductibilité qui n'a pas été mesuré ou testé.
