# Progression

Dernière mise à jour : 7 novembre 2026

## Phase courante

**Phase 1 — preuve Agentforce minimale**

## Réalisé et vérifié

- Dossier de travail confirmé : `C:\Users\Dell\talentflow360`.
- Projet Salesforce DX présent avec `sfdx-project.json`, package par défaut `force-app` et API source `68.0`.
- Aucun `AGENTS.md` n'existait avant cette séance ; les règles durables du projet sont maintenant définies à la racine.
- Git fonctionne : version `2.49.0.windows.1`.
- Le dépôt n'a encore aucun commit et aucun dépôt distant n'est configuré.
- Java fonctionne : Temurin OpenJDK `21.0.11` LTS.
- Salesforce CLI est installée dans `C:\Program Files\sf\bin\sf.cmd`, version `2.157.8`.
- La CLI fonctionne après définition temporaire de `SHELL`. Sans ce contournement, son Node embarqué échoue dans `uv_os_get_passwd` avec `ENOMEM`.
- VS Code `1.144.0` est installé. Les extensions Salesforce principales, Agentforce et l'extension officielle Codex sont présentes.
- La structure issue du modèle Salesforce existe, mais `force-app` ne contient encore aucune métadonnée métier.
- `.gitignore` protège `.sf/`, `.sfdx/`, `.env`, `.env.*`, `node_modules/`, `coverage/` et `test-results/`.
- Le Flow technique `TF_ConnectionProbe` et son contrat sont préparés localement.
- `manifest/package.xml` cible uniquement cette sonde pour le premier déploiement.
- Le XML du Flow et du manifeste est bien formé, et `sf project convert source` les convertit localement sans avertissement. Cela ne prouve pas encore leur déploiement dans l'org.
- La validation à blanc du déploiement a réussi : 1 composant, 0 erreur.
- Le déploiement réel a réussi : 1 composant, 0 erreur.
- La Tooling API confirme `TF_ConnectionProbe`, version active 1 et dernière version 1.
- Une exécution directe par Apex anonyme a compilé et réussi ; `safeSummary` a renvoyé la valeur synthétique attendue.
- L'org expose des licences Agentforce actives. L'utilisateur connecté possède les licences `AgentforceServiceAgentBuilderPsl`, `EinsteinGPTCopilotPsl` et `EinsteinGPTPromptTemplatesPsl`.
- L'utilisateur connecté possède aussi les permission sets `AgentforceServiceAgentBuilder` et `EinsteinGPTPromptTemplateManager`.

## État Salesforce

- L'alias `TFDev` existe, est défini comme org par défaut et a été reconnecté avec succès.
- Une requête de lecture réelle sur `Organization` réussit.
- Type vérifié : `Developer Edition`, `IsSandbox = false`, instance `CAN96`.
- Les premiers `fetch failed` provenaient de la restriction réseau du bac d'exécution. La vérification autorisée hors bac confirme que l'authentification est valide.
- Le Flow technique est déployé et les licences/affectations Agentforce ont été vérifiées. Le test dans Agentforce Preview n'a pas encore été réalisé.

## Bloqué

- L'accès effectif à Agentforce Builder et l'état d'activation de l'agent restent à vérifier dans l'interface.
- L'appel de la sonde depuis une conversation Preview reste `NotRun`.
- L'ouverture automatique de Salesforce Setup depuis l'environnement Codex a été empêchée par le service d'approbation local ; ce n'est pas une erreur Salesforce.

## Prochaine action exacte

Ouvrir manuellement `TFDev`, aller dans Setup et rechercher `Agentforce Agents` ou `Agents`. Confirmer que la page Builder est accessible avant de créer une action fondée sur `TF_ConnectionProbe`.

## Reprise de l'implémentation par sprints — 7 novembre 2026

### Réalisé

- Calendrier accepté enregistré dans `docs/sprints.md` : 128 heures prévues et 32 de réserve.
- Procédure de collaboration et modèles locaux de tâche/PR ajoutés.

### Vérifié

- Lecture réelle de `Organization` réussie dans TFDev : Developer Edition, non sandbox, instance CAN96 ; API 68.0 conservée.
- Le premier essai dans le bac réseau a échoué avec EACCES/fetch failed ; la lecture autorisée hors bac réussit. Aucun besoin de reconnecter l'utilisateur constaté.
- `git check-ignore` confirme les exclusions .sf, .sfdx, .env, .env.local, node_modules, coverage et test-results.
- Le dépôt ne possède toujours pas de commit ni de distant.

### Bloqué

- Preuve de l'appel Agentforce : NotRun. L'utilisateur a montré la page Agentforce Agents puis l'écran du nouveau Builder avec les modèles Employee/Service/Slack : accès interface constaté, mais aucune invocation encore observée.
- Règlement : l'utilisateur indique « tout est permis » ; code préparé et assistance acceptés sur sa confirmation. Aucun produit supplémentaire ajouté au périmètre.

### Prochaine action

- Inspecter les agents existants sans modification, préciser la procédure Preview et préparer le modèle local sans exposer de nouvelle action avant validation des droits.

### Guidage Builder

- Le modèle recommandé est Agentforce Employee Agent pour le recruteur interne connecté. Son contexte exact sera relevé dans la configuration et testé, sans supposer un utilisateur technique distinct.
- Aucune carte Service Agent n'a été choisie par Codex et aucun agent n'a été créé par la CLI.

## Préparation du socle S1 — 7 novembre 2026

### Réalisé

- Modèle figé avant génération : six objets privés, rôles JavaBackendDeveloper/QAEngineer, activités sur les dossiers et marqueurs de lot synthétique.
- Sources des objets, validations, onglets, application Lightning, layouts et quatre permission sets créées ; matrice d'accès ajoutée.
- Protection serveur d'approbation préparée dès la création du modèle pour éviter une transition Hired falsifiée. Service RH dédié non exposé à l'agent ; Screen Flow non encore créé.
- Tests Apex du modèle et de la garde préparés.

### Vérifié

- Inventaire Metadata API : zéro objet existant parmi les six noms métier ; aucun objet du binôme remplacé.
- Premier dry-run Failed : relations User avec contrainte Restrict et ordre des éléments PermissionSet invalides. Corrections locales faites et XML bien formé ; nouvelle validation en cours.

### Bloqué

- Aucun déploiement métier annoncé tant que le dry-run et les tests ne réussissent pas.
- La configuration d'agent et sa preuve Preview restent indépendantes de ces tests Apex.

### Prochaine action

- Lire le résultat du second dry-run, corriger les éventuels échecs puis déployer le seul socle validé.

### Point de vérification du socle

- Réalisé : seed/reset bornés et tests ajoutés ; utilisateurs synthétiques de test séparés, dont des acteurs sur profil Minimum Access - Salesforce.
- Vérifié : tous les composants compilent et les cinq premiers tests passent ; le job de validation reste Failed à cause de la couverture du service RH (66,667 %). Ce n'est pas une réussite de déploiement.
- Bloqué : aucune preuve Preview ; affectation réelle des layouts et droits humains à tester ultérieurement.
- Prochaine action : terminer les tests des refus avec utilisateurs minimaux et de l'interdiction d'une approbation en lot, puis contrôler couverture et résultat final du job.

### Socle validé à blanc

- Réalisé : modèle, garde RH, application/navigation standard, permissions et seed/reset sont prêts.
- Vérifié : dry-run 0AfgK00000Z3RIsSAN Succeeded, 83 composants et 9 tests réussis, zéro erreur et aucune alerte de couverture. Les droits minimaux et la préservation du témoin hors lot sont couverts en contexte de test.
- Bloqué : appel Agentforce Preview et recette des écrans/layouts restent NotRun.
- Prochaine action : déploiement réel ciblé du socle après nouvelle vérification de TFDev ; aucun déploiement réussi n'est annoncé au seul lancement du job.

### Socle déployé et testé

- Réalisé : déploiement réel 0AfgK00000Z4L1hSAF dans TFDev, après vérification de la Developer Edition CAN96.
- Vérifié : Succeeded, 83 composants et 9 tests réussis, aucune erreur ni alerte de couverture. Les objets, permissions, application, onglets, layouts et protections serveur existent désormais dans l'org.
- Bloqué : consultation UI et affectation des layouts non observées ; appel réel Agentforce encore NotRun.
- Prochaine action : affecter au seul opérateur de démonstration les rôles prévus, initialiser deux fois le jeu synthétique et vérifier ses effectifs. Puis développer/tester les actions métier sans les exposer à l'agent avant recette directe.

### Données initialisées et actions en préparation

- Réalisé : rôles Recruteur/RH/Démonstration affectés au seul compte opérateur dans TFDev ; seed exécuté deux fois. Les quatre actions et leurs contrats sont préparés localement.
- Vérifié : six profils, six identités et huit créneaux dans TF360-DEMO-V1, effectifs inchangés au second seed. Modèle/permissions testés avec utilisateurs minimaux dans les transactions isolées ; pas de compte de test humain créé hors de ces tests.
- Bloqué : preuve Preview, recette UI et concurrence réelle restent à réaliser.
- Prochaine action : valider les actions Apex ; les journaux sont minimisés et transactionnels, les sorties JSON sont construites par liste blanche. Aucune nouvelle action Agentforce n'est encore configurée.

### Actions métier déployées et appelées directement

- Réalisé : déploiement réel 0AfgK00000Z4HSkSAN des actions/permissions ; script de contrôle sur données synthétiques ajouté.
- Vérifié : 14 tests réussis, zéro erreur/alerte de couverture. checkBusinessActions.apex compile et s'exécute réellement : brief incomplet, sorties autorisées, liste des créneaux, refus sans confirmation et lecture du parcours.
- Bloqué : configuration/invocation de l'assistant dans Preview, concurrence réelle et recette UI restent NotRun.
- Prochaine action : test concurrent réel borné aux profils de démonstration, puis écrans RH et automatisation du parcours ; ne pas présenter les appels Apex directs comme une intégration Agentforce.
