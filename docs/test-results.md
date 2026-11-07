# Résultats de test

Date : 7 novembre 2026

Environnements : poste Windows local et org Salesforce `TFDev` vérifiée comme Developer Edition. Aucun secret n'est consigné.

| ID | Statut | Preuve observée |
|---|---|---|
| ENV-001 | Passed | Git 2.49.0, Java 21.0.11, Salesforce CLI 2.157.8 et VS Code 1.144.0 détectés |
| AUTH-001 | Passed | Requête `Organization` réussie ; `Developer Edition`, non sandbox, instance `CAN96` |
| FLOW-001 | Passed | `sf project convert source` termine avec statut 0 et sans avertissement |
| FLOW-002 | Passed | Dry-run `Succeeded` ; 1/1 composant, 0 erreur, aucun test Apex requis |
| FLOW-003 | Passed | Déploiement `Succeeded` ; 1/1 composant, 0 erreur |
| FLOW-004 | Passed | Tooling API : `TF_ConnectionProbe`, version active 1, dernière version 1 |
| FLOW-005 | Passed | Apex anonyme compilé et exécuté ; sortie `TalentFlow connection probe completed. Synthetic diagnostic output only.` |
| AGENT-ACCESS-001 | Passed | Licences actives trouvées, notamment Agentforce par défaut et Agentforce Service Agent Builder |
| AGENT-ACCESS-002 | Passed | Utilisateur connecté affecté aux licences Builder/Agentforce et au permission set `AgentforceServiceAgentBuilder` |
| AGENT-ACCESS-UI | Blocked | Ouverture automatique de Setup bloquée par le service d'approbation de l'environnement ; vérification manuelle requise |
| AGENT-001 | NotRun | Action Agentforce et conversation Preview non configurées à ce stade |

Les tests `FLOW-002` à `FLOW-005` prouvent le Flow Salesforce réel. Ils ne prouvent pas encore l'intégration Agentforce, couverte séparément par `AGENT-001`.

## Reprise des sprints — 7 novembre 2026

| ID | Environnement / exécution | Statut | Résultat réel |
|---|---|---|---|
| AUTH-002 | TFDev ; `sf data query`, OrganizationType/IsSandbox/InstanceName | Passed | Lecture réelle réussie, Developer Edition non sandbox, CAN96. Essai réseau initial EACCES ; reprise autorisée réussie. |
| GIT-IGNORE-001 | Poste Windows ; `git check-ignore` | Passed | Les sept chemins .sf, .sfdx, .env, .env.local, node_modules, coverage, test-results sont exclus. |
| AGENT-INVENTORY-001 | TFDev ; `sf org list metadata --metadata-type Bot --api-version 68.0` | Passed | Aucun composant Bot retourné. Ne prouve pas l'absence d'autres types d'agent. |
| AGENT-001-REPRISE | Builder/Preview | NotRun | Aucune conversation réelle observée pendant cette reprise. Procédure Setup §7 prête. |
| RULES-001 | Confirmation utilisateur | Passed | L'utilisateur confirme « tout est permis » pour le code préparé et l'assistance. Aucun audit du règlement ni produit supplémentaire revendiqué. |
| AGENT-ACCESS-UI-REPRISE | Captures fournies par l'utilisateur, 7 novembre 2026 | Passed | Page Agentforce Agents puis nouveau Builder accessibles ; modèles Employee, Service et Slack visibles. Ne prouve ni agent créé ni action appelée. |
| MODEL-INVENTORY-001 | TFDev ; liste Metadata API CustomObject | Passed | Aucun des six objets métier n'existait avant préparation. |
| MODEL-DRY-001 | TFDev ; deploy start --dry-run, 7 novembre 2026 | Failed | Job 0AfgK00000Z4ImzSAF : contraintes Restrict non admises sur User et ordre XML des PermissionSet incorrect. Échecs de compilation dépendants ; aucun test métier exécuté ni métadonnée enregistrée. |
| MODEL-XML-001 | Windows ; parse XML Python, après corrections | Passed | Tous les fichiers XML de force-app sont bien formés ; cela ne valide pas le schéma Salesforce. |
| MODEL-DRY-002 | TFDev ; dry-run 0AfgK00000Z4J1VSAV | Failed | Lookup Recruiter requis incompatible avec les contraintes User. Remplacé par lookup facultatif + règle obligatoire. |
| MODEL-DRY-003 | TFDev ; dry-run 0AfgK00000Z4JG1SAN | Failed | 80 composants compilent ; 2 tests réussissent, 1 échoue sur le contexte de permission du test RH. |
| MODEL-DRY-004 | TFDev ; dry-run 0AfgK00000Z4JfpSAF | Failed | 82 composants compilent ; les 3 tests modèle/RH passent, les 2 tests de démonstration échouent sur leur autorisation. Isolation par utilisateur synthétique ajoutée. |
| MODEL-DRY-005 | TFDev ; dry-run 0AfgK00000Z4KC5SAN | Failed | Syntaxe runAs corrigée : la requête doit être affectée à une variable User avant runAs. Aucun test lancé. |
| MODEL-DRY-006 | TFDev ; dry-run 0AfgK00000Z4KSDSA3 | Failed | 82 composants compilent et 5 tests passent, mais couverture TF_HiringService à 66,667 %, sous les 75 % requis par classe avec RunSpecifiedTests. Le job n'est donc pas une validation réussie. |
| MODEL-DRY-007 | TFDev ; dry-run 0AfgK00000Z3RIsSAN, 7 novembre 2026 | Passed | Succeeded : 83 composants, 9 tests réussis, zéro erreur et aucune alerte de couverture. Classes TF_ModelTest, TF_DemoDataTest et TF_AccessTest. Les tests d'accès utilisent des utilisateurs synthétiques Minimum Access - Salesforce. |
| MODEL-DEPLOY-001 | TFDev ; déploiement réel 0AfgK00000Z4L1hSAF, 7 novembre 2026 | Passed | Succeeded : 83 composants enregistrés, 9 tests réussis, zéro erreur et aucune alerte de couverture. Cible Developer Edition CAN96 recontrôlée immédiatement avant mutation. |
| DEMO-PERMISSIONS-001 | TFDev ; assignDemoPermissions.apex | Failed | Premier essai non compilé : SYSTEM_MODE interdit en exécution anonyme API 68. Aucun droit modifié par cet essai. |
| DEMO-PERMISSIONS-002 | TFDev ; script corrigé USER_MODE | Passed | Compilation et exécution réussies ; marqueur TF_DEMO_PERMISSIONS=SUCCESS. Trois rôles affectés au seul opérateur connecté. |
| DEMO-SEED-001 | TFDev ; deux exécutions seedDemo.apex puis COUNT par objet | Passed | Deux exécutions compilées/réussies ; 6 TalentProfile, 6 CandidateIdentity, 8 InterviewSlot dans TF360-DEMO-V1. Aucune identité lue dans les résultats de vérification. |
| ACTION-DRY-001 | TFDev ; dry-run 0AfgK00000Z48J0SAJ | Failed | Actions compilées ; variable de test nommée bulk (mot réservé Apex), renommée batchRequests. Aucun test exécuté. |
| ACTION-DRY-002 | TFDev ; dry-run 0AfgK00000Z4MH7SAN | Failed | Dix tests réussissent ; quatre tests modèle échouent car ils réaffectaient les permissions déjà présentes sur l'opérateur. Test modèle isolé sur un utilisateur synthétique distinct. |
| ACTION-DRY-003 | TFDev ; dry-run 0AfgK00000Z4MNZSA3, 7 novembre 2026 | Passed | Succeeded : 15 composants, 14 tests réussis, zéro erreur et aucune alerte de couverture. Cinq tests d'actions en contexte minimal, distincts d'Agentforce Preview. |
| ACTION-DEPLOY-001 | TFDev ; déploiement réel 0AfgK00000Z4HSkSAN, 7 novembre 2026 | Passed | Succeeded : 15 composants enregistrés, 14 tests réussis, zéro erreur/alerte de couverture. Cible revalidée avant mutation. |
| ACTION-SMOKE-001 | TFDev ; checkBusinessActions.apex | Passed | Compilation et exécution réelles réussies : brief incomplet et liste blanche, créneaux futurs, refus sans confirmation, lecture du parcours ; marqueur TF_ACTION_SMOKE=SUCCESS. Pas une preuve Agentforce. |
| JOURNEY-DRY-001 | TFDev ; dry-run 0AfgK00000Z45eVSAR | Failed | 111 composants compilés, deux erreurs Flow : booléen d'entrée requis et filtre Start ne pouvant référencer $Flow.CurrentDate. Aucun test lancé ; corrections locales faites. |
| ORG-TIMEZONE-001 | TFDev ; SELECT TimeZoneSidKey FROM Organization | Passed | America/Los_Angeles. Aucun changement du fuseau global effectué. |
| RESERVATION-CONCURRENCY-001 | TFDev, 7 novembre 2026 à 03:22 UTC ; scripts/powershell/test-reservation-concurrency.ps1 | Passed | Deux exécutions Apex réelles. Intervalles serveur [1794021746717,1794021748965] et [1794021747003,1794021751052] ms Unix : chevauchement observé. TF-DEMO-001 SUCCESS, TF-DEMO-002 SLOT_UNAVAILABLE ; une seule réservation finale. Maintien volontaire des verrous deux secondes, données du lot uniquement. Preuve locale expurgée : test-results/concurrency/result.json (non versionnée). Ne constitue pas un test de charge. |
| JOURNEY-DRY-002 | TFDev ; dry-run 0AfgK00000Z4Q4bSAF, 7 novembre 2026 | Passed | Rapport final Succeeded : 114 composants, 18 tests réussis, zéro erreur/alerte de couverture. La CLI avait dépassé son attente ; résultat récupéré via project deploy report. Les Flows après sauvegarde sont exercés par les tests ; les écrans et le déclenchement planifié réel restent séparés. |
| JOURNEY-DEPLOY-001 | TFDev ; déploiement réel 0AfgK00000Z4NwMSAV, 7 novembre 2026 | Passed | Succeeded : 113 composants enregistrés (sonde existante exclue), 18 tests réussis et aucune erreur/alerte de couverture. |
| FLOW-ACTIVATION-001 | TFDev ; Tooling API FlowDefinition | Passed | TF_ApproveHiring, TF_CapturePulse, TF_JourneyDaily, TF_Onboarding, TF_PulseAlert et TF_SimulateJourney actifs en version 1. Sonde conservée en version 1. |
| JOURNEY-SCHEDULE-001 | TFDev ; CronTrigger | Passed | TF_JourneyDaily-1 WAITING, America/Los_Angeles, prochain passage 2026-11-07T16:00:00Z. Vérifie la programmation ; l'exécution reste NotRun. |
| JOURNEY-SMOKE-001 | TFDev ; checkJourney.apex, 7 novembre 2026 | Passed | Exécution technique réelle sur TF-DEMO-001 : service RH, Flow après sauvegarde créant six étapes, changement de rôle/date sans doublon, simulations J+30/J+60/J+90, score 1 puis 4 et une seule alerte après répétition. Zéro invocation Apex d'email. Ni preuve d'un clic humain ni preuve Preview. |
| UI-METADATA-DRY-001 | TFDev ; dry-run 0AfgK00000Z4PbaSAF | Passed | 81 composants de présentation validés, sans tests Apex relancés (logique inchangée, 18 tests déjà réussis) : textes UTF-8, cinq listes standard, boutons et affectations de layouts ciblées. |
| UI-METADATA-DEPLOY-001 | TFDev ; déploiement 0AfgK00000Z4OVqSAN | Passed | 81 composants de présentation déployés. Sauvegarde concrète de six layouts et des six affectations Admin dans test-results/layout-assignment-backup (ignoré Git) ; affectations déjà conformes. Révision des accents corrigée en UTF-8. Clics UI non observés. |
| JOURNEY-SCHEDULE-PROBE-001 | TFDev ; déploiement 0AfgK00000Z4FkISAV puis CronTrigger et JourneyStep | Passed | Véritable Flow Once limité à une étape synthétique Day1 ; heure prévue 03:36:40 UTC, Cron déclenché à 03:37:02.219 UTC le 7 novembre 2026. TimesTriggered=1, State=DELETED, NextFireTime=null. Étape Completed, ExecutionMode=Scheduled, ExecutedAt=03:37:03 UTC. Ce n'est pas un appel manuel de l'action ni une simulation. Le passage quotidien à 08:00 org reste à observer séparément. |
| AGENT-COMPILE-001 | TFDev ; agent validate, API 68 | Failed | La sonde Agent Script retourne HTTP 422 sans diagnostic de syntaxe exploitable. Aucune publication tentée. |
| AGENT-COMPILE-CONTROL-001 | TFDev ; script Employee minimal sans action | Passed | Contrôle minimal compilé avec success=true. Le compilateur est donc accessible ; le rejet de la sonde ne peut pas être attribué à une panne générale démontrée. Source originale restaurée après contrôle. |
| AGENT-COMPILE-002 | TFDev ; bundle Employee, locale fr | Passed | Compilation réussie. HTTP 422 était déclenché par la locale fr_FR dans cette configuration ; aucune panne générale revendiquée. |
| AGENT-PREVIEW-START-001 | TFDev ; SDK installé | Failed | Démarrage refusé par replace sur defaultAgentUser absent. Marqueur technique INVALID ajouté, sans identité réelle ni modification de l'installation CLI. |
| AGENT-PROBE-LIVE-001 | TFDev ; CLI Preview --use-live-actions, 7 novembre 2026 | Passed | Métadonnées de session mockMode=Live Test. Trace FunctionStep connection_probe, entrée TF-PROBE-001, statut success, safeSummary exact du Flow réel. Preuve : docs/evidence/agent-probe.json. Ne prouve pas encore un agent publié/activé dans Lightning. |
| ACTION-MODE-DEPLOY-001 | TFDev ; déploiement 0AfgK00000Z44LqSAJ, 7 novembre 2026 | Passed | Champ executionMode ajouté à la seule sortie de suivi et en lecture seule pour TF_AgentAccess ; 5 tests d'actions réussis, zéro erreur/alerte de couverture. Les simulations restent identifiables dans la future conversation métier. |
| UI-RECETTE-001 | Application Lightning / Screen Flows | NotRun | Métadonnées actives et layouts affectés ; visite et clics humains à réaliser pendant la petite démo. |
| AGENT-BUSINESS-001 | Conversations métier et publication Lightning | NotRun | Pause demandée après la preuve de sonde, avant raccordement des quatre actions. |
| RESET-LIVE-001 | Deux resets sur le jeu réellement présenté | NotRun | Tests Apex isolés réussis, mais données courantes conservées pour la petite démo. |
| DEMO-VIEWS-001 | TFDev ; déploiement 0AfgK00000Z4Xm1SAF | Passed | Deux vues standard Tous les dossiers / Toutes les étapes déployées, sans modification de logique métier. |
| DEMO-STATE-001 | TFDev ; lecture pseudonymisée du dossier TF-DEMO-001 | Passed | État Hired, six étapes, deux réponses synthétiques et cinq tâches au moment du checkpoint. Aucun reset effectué avant la visite. |
| MANIFEST-CONVERT-001 | Windows ; project convert source --manifest manifest/package.xml | Passed | Inventaire explicite du backend converti en format Metadata API sans avertissement ; ne constitue pas un déploiement sur org neuve. |
| CHECKPOINT-LOCAL-001 | Windows ; contrôles XML, API et preuve avant publication | Passed | 123 XML bien formés, API 68.0 conservée, textes visibles sans accents corrompus ; empreinte du bundle identique à la preuve Live Test et à l'archive de sonde. Index Git contrôlé sans .sf/.sfdx/env/logs/résultats temporaires ni motif de secret détecté. |
| GIT-PUSH-001 | GitHub tareknjm/talentflow360, main, 7 novembre 2026 | Passed | Checkpoint c1a98ef poussé sans force avec le commit initial ; suivi origin/main configuré. Documentation de bilan actualisée ensuite dans un commit distinct. |
