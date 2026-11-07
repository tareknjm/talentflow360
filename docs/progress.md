# Progression

Dernière mise à jour : 7 novembre 2026

## Phase courante

**Reprise demandée le 7 novembre 2026 — quatre actions vérifiées dans Preview Live Test ; TalentFlow_Assistant version 1 publié et activé dans TFDev. Le checkpoint GitHub de la pause reste disponible ; les changements de reprise sont locaux.**

### Réalisé

- Socle Salesforce et quatre actions métier déployés ; six profils, six identités fictives et huit créneaux.
- Six Flows actifs : validation RH, satisfaction, synchronisation, alerte, simulation et échéances quotidiennes.
- Sonde conservée dans scripts/agentforce/connection-probe.agent ; bundle Employee courant raccordé aux quatre actions Apex métier, sans outil générique ni validation RH.
- Confirmation conversationnelle puis garde-fou Salesforce require_user_confirmation pour la réservation. Configuration métier initiale archivée dans scripts/agentforce/business-preview-v1.agent ; clarification du sens de Simulation dans la version courante.
- Publication réussie (16 éléments récupérés, 3 déployés), version 1 Active relue depuis l'org. Métadonnées générées aiAgents/aiAgentDefinitionVersions conservées. Le droit TF_AssistantAccess, sans droits objet supplémentaires, est déployé et affecté au seul opérateur connecté.
- Guide de visite dans `docs/mini-demo.md`. Commit initial `63f70d9` puis checkpoint `c1a98ef` poussés vers `https://github.com/tareknjm/talentflow360`, branche main.

### Vérifié

- Dernière suite complète : 18 tests Apex réussis. Dernière modification de sortie (Scheduled/Simulation) : déploiement 0AfgK00000Z44LqSAJ réussi et 5 tests d'actions réussis.
- Réservation concurrente réelle : une seule réservation ; parcours et alerte exercés dans l'org ; Flow Once réellement déclenché, distinct des simulations.
- Mode Live Test et FunctionStep connection_probe avec sa sortie réelle ; preuve expurgée dans `docs/evidence/agent-probe.json`.
- Quatre FunctionStep métier réels : brief de TF-DEMO-006, liste des créneaux de TF-DEMO-002, réservation SUCCESS après confirmation et suivi de TF-DEMO-001. Preuves agent-business-*.json dans docs/evidence, avec empreintes de configuration.
- Zéro réservation pour TF-DEMO-002 avant confirmation ; une après SUCCESS et toujours une après répétition ALREADY_RESERVED. Injection/données privées/classement/embauche refusés ; dossier absent signalé sans profil inventé. Sur le runtime publié, une demande Confirm pour TF-DEMO-003 a été annulée par « Non » : aucune action de réservation exécutée dans la trace et zéro réservation en base.
- Passage quotidien définitif observé : TF_JourneyDaily TimesTriggered=1, PreviousFireTime=2026-11-07T16:00:11.162Z ; PreArrival exécuté en Scheduled à 16:00:15Z. Le test Once J+1 reste une preuve distincte.
- Formulation initiale du suivi trop vague (« prévisualisation ») corrigée puis retestée : les simulations créent de vraies tâches synthétiques ; Pending ne signifie pas exécuté. Les deux sessions de cette reprise sont fermées.
- Brief TF-DEMO-003 également appelé réellement depuis le runtime publié, distinct du Preview de brouillon. Preuve agent-published-brief.json ; ce runtime n'inscrit pas mockMode dans ses métadonnées, contrairement au Preview Live Test. Sa session est fermée également.

### Bloqué ou non encore vérifié

- Publication et activation technique effectuées ; visibilité et conversation dans le panneau Lightning non encore vérifiées. surfacesEnabled=false a été relu, sans en déduire seul une indisponibilité : les accès utilisateur sont également déterminants. Le droit d'accès à l'agent a été ajouté ; aucun réglage global de l'org modifié.
- Contexte Employee toujours celui de l'opérateur connecté avec droits Admin/RH : seules les quatre actions minimisées sont exposées. Les conversations en compte réellement restreint restent NotRun ; les tests Apex restreints déjà réussis ne les remplacent pas.
- Clics humains des Screen Flows, resets du jeu réel, mesures et vidéo non exécutés. Refus d'une panne technique injectée dans une conversation non encore exercé. Toutes les sessions de cette reprise sont fermées.

### Prochaine action

Dans Lightning, vérifier TalentFlow Assistant dans le panneau Agentforce puis demander le brief de TF-DEMO-003. Recetter ensuite le bouton Valider l'embauche de TF-DEMO-002 avec l'utilisateur, puis satisfaction et simulation. Préparer séparément la conversation en compte restreint. Conserver le dossier TF-DEMO-001 pour le parcours (six tâches désormais) ; TF-DEMO-002 est InterviewScheduled après la vraie réservation Agentforce du 8 novembre 18:00–18:45 UTC. Aucun reset effectué.

### Préparation GitHub et démo

- Réalisé : guide de cinq minutes, deux vues Tous les dossiers/Toutes les étapes et manifeste complet du backend ; session Preview de test fermée proprement après export de la preuve.
- Vérifié : les deux vues sont déployées ; TF-DEMO-001 est Hired avec six étapes, deux réponses synthétiques et cinq tâches. Conversion locale du manifeste réussie sans avertissement. Dépôt GitHub tareknjm/talentflow360 vide, branche par défaut main et accès push confirmés.
- Vérifié après envoi : checkpoint c1a98ef poussé sans force sur main ; contenu local conservé, dépôt distant initialement vide. Les fichiers d'authentification, sessions et logs sont exclus ; contrôle local des XML/API 68 et empreinte de la preuve de sonde réussi.
- Bloqué : aucune nouvelle fonction métier engagée pendant la pause ; les éléments non vérifiés listés plus haut restent ouverts.
- Prochaine action : visite guidée de cinq minutes ; le commit documentaire de bilan accompagne le checkpoint sur main.

## Historique de séance

Les états ci-dessous décrivent leur instant d'observation et peuvent être dépassés par le bilan courant ci-dessus.

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

## Écrans RH et parcours — préparation

- Réalisé : sources de trois Screen Flows (validation RH, satisfaction et simulation), deux Flows après sauvegarde et un Flow quotidien, services de parcours et alerte, boutons d'action standard.
- Vérifié : premier dry-run 0AfgK00000Z45eVSAR compile les services, mais refuse deux métadonnées Flow : case booléenne obligatoire et filtre Start référençant CurrentDate. Corrigés par case requise et formule IsDue__c. Le fuseau de l'org a été lu : America/Los_Angeles ; il n'a pas été modifié.
- Bloqué : ces nouvelles fonctions ne sont pas encore déployées/testées ; écrans non observés. La planification réelle reste NotRun.
- Prochaine action : lire la nouvelle validation complète. Le test de concurrence des réservations déployées est lancé séparément sur le seul lot synthétique.

### Concurrence réellement testée

- Réalisé : deux appels Apex concurrents à TF_ReserveInterview sur les dossiers synthétiques 001/002 et SLOT-1.
- Vérifié : chevauchement des intervalles serveur, un SUCCESS et un SLOT_UNAVAILABLE, une seule réservation finale. Données hors lot non utilisées. Voir RESERVATION-CONCURRENCY-001.
- Bloqué : la CLI a dépassé son attente sur la validation des Flows ; le job continue et son résultat n'est pas encore conclu.
- Prochaine action : récupérer le rapport final avant toute annonce de réussite des automatismes ou déploiement.

### Validation complète avant déploiement du parcours

- Réalisé : Screen Flows avec confirmation, gestion des erreurs et boutons standard ; automatismes de génération, replanification et satisfaction.
- Vérifié : rapport final 0AfgK00000Z4Q4bSAF Succeeded, 114 composants et 18 tests réussis. Les Flows après sauvegarde sont réellement sollicités par les tests de création/replanification du parcours et d'alerte unique.
- Bloqué : clics UI, preuve Agentforce et planification réellement déclenchée restent NotRun.
- Prochaine action : déploiement réel du parcours, en excluant la sonde existante pour préserver sa configuration pendant le guidage Builder ; contrôler ensuite activation et prochain déclenchement.

### Parcours et écrans déployés

- Réalisé : déploiement réel 0AfgK00000Z4NwMSAV de 113 composants, sonde préservée ; 18 tests réussis.
- Vérifié : les six nouveaux Flows sont actifs en version 1. TF_JourneyDaily-1 est WAITING, prochain passage le 7 novembre 2026 à 16:00 UTC, fuseau America/Los_Angeles. Ceci prouve la programmation, pas son exécution.
- Bloqué : preuve Preview et clics Screen Flow restent NotRun. Certaines traductions ont été altérées par l'encodage d'une commande PowerShell ; les sources UTF-8 sont corrigées et doivent être resynchronisées.
- Prochaine action : appliquer les listes standard, traductions et layouts du seul opérateur de démonstration ; exécuter le smoke technique du parcours réel sur données fictives, distinct du clic humain.

### Preuve réelle du parcours et de la planification

- Réalisé : smoke du parcours dans l'org réelle, trois simulations identifiées, satisfaction et alerte ; cinq listes standard et libellés UTF-8 déployés.
- Vérifié : six étapes après approbation technique ; replanification rôle/date ; une seule alerte après répétition. Le Flow de test planifié Once a réellement tourné : Cron TimesTriggered=1 à 03:37:02 UTC, étape Day1 exécutée à 03:37:03 UTC en mode Scheduled. Le job unique n'a plus de prochain passage. Le Flow quotidien demeure programmé indépendamment.
- Bloqué : clics UI humains et conversations Agentforce restent non prouvés. La première compilation du bundle de sonde retourne HTTP 422, mais un contrôle Employee minimal sans action compile : diagnostic de configuration en cours, pas une panne générale annoncée.
- Prochaine action : corriger la configuration de sonde, obtenir une compilation puis un Preview réel avant toute intégration métier ; terminer les preuves de reset et les documents de transfert.

## Preuve Agentforce obtenue — clôture technique S0

- Réalisé : bundle Employee minimal configuré avec la seule sonde et Preview démarré avec --use-live-actions.
- Vérifié : compilation réussie après locale fr ; trace FunctionStep connection_probe avec TF-PROBE-001, statut success et safeSummary exact. Mode Live Test confirmé dans les métadonnées de session. Preuve sans prompts ni identité dans docs/evidence/agent-probe.json.
- Bloqué : publication/activation du canal Lightning et intégration des quatre actions métier restent à réaliser. Les clics humains des Screen Flows, mesures et vidéo ne sont pas encore prouvés.
- Prochaine action : raccorder les seules quatre actions métier, tester les conversations réelles et leurs refus, puis publier une configuration relue. La sonde est une preuve technique, pas une fonction RH.
