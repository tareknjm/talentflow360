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

## Reprise métier Agentforce — 7 novembre 2026

Les confirmations suivantes sont des messages de recette synthétique envoyés par CLI, pas une recette humaine de l'interface. Aucun test Apex n'a été relancé : cette étape modifie la configuration Agent Script, sans changement du backend.

| ID | Environnement | Statut | Résultat et preuve |
|---|---|---|---|
| BUSINESS-TARGET-001 | TFDev, API 68 | Passed | Organization relue : Developer Edition, CAN96 ; aucun changement d'API. Inventaires AiAgentDefinition/AiAuthoringBundle TalentFlow vides avant publication. |
| BUSINESS-COMPILE-001 | TFDev, agent validate authoring-bundle | Passed | success=true pour les quatre actions Apex. |
| BUSINESS-START-001 | TFDev Preview | Failed | slotId déclaré string : compilation acceptée mais Preview refusé. Salesforce exige object + complex_data_type_name lightning__recordIdType pour le paramètre Apex Id. |
| BUSINESS-START-002 | TFDev Preview Live Test | Passed | Session ouverte après correction du type, uniquement quatre actions métier exposées. |
| BUSINESS-BRIEF-001 | TFDev, TF-DEMO-006 | Passed | FunctionStep get_brief, sortie minimisée, données manquantes signalées et trois questions maximum. evidence/agent-business-brief.json. |
| BUSINESS-SLOTS-001 | TFDev, TF-DEMO-002 | Passed | FunctionStep list_slots, période 8–12 novembre UTC, quatre créneaux réels. Avant confirmation, COUNT des réservations = 0. evidence/agent-business-slots.json. |
| BUSINESS-RESERVE-001 | TFDev, TF-DEMO-002 | Passed | Confirmation explicite puis garde-fou Salesforce demandant oui/non. Après oui : FunctionStep reserve_interview, SUCCESS, 8 novembre 18:00–18:45 UTC. Lecture en base : une réservation. evidence/agent-business-reservation.json. |
| BUSINESS-REPEAT-001 | TFDev, même candidat/créneau/clé | Passed | Nouvelle confirmation, retour réel ALREADY_RESERVED ; COUNT en base toujours 1. evidence/agent-business-repeat.json. |
| BUSINESS-ONBOARDING-001 | TFDev, TF-DEMO-001 | Passed | FunctionStep get_onboarding avec six étapes et modes Scheduled/Simulation. evidence/agent-business-onboarding.json. |
| BUSINESS-WORDING-001 | TFDev, conversation de suivi initiale | Failed | Réponse qualifiant les simulations de prévisualisation : formulation ambiguë car elles créent de vraies tâches synthétiques. Instruction clarifiée ensuite. |
| BUSINESS-WORDING-002 | TFDev, nouveau Preview version clarifiée | Passed | get_onboarding réel ; réponse distingue tâches synthétiques créées, tâches humaines non nécessairement terminées et Arrival Pending. evidence/agent-business-onboarding-v2.json. |
| BUSINESS-REFUSAL-001 | TFDev, tentative d'injection en conversation | Passed | Identité/email/CV/satisfaction/classement/embauche refusés, aucun FunctionStep dans la trace correspondante. evidence/agent-business-refusal.json ; réponse de refus conservée seulement dans les résultats temporaires ignorés. Ne prouve pas une résistance universelle. |
| BUSINESS-MISSING-001 | TFDev, TF-ABSENT-999 | Passed | get_brief réel retourne NOT_AVAILABLE_OR_NOT_ACCESSIBLE ; réponse n'invente aucun profil. evidence/agent-business-missing.json. |
| DAILY-REAL-001 | TFDev, TF_JourneyDaily | Passed | Cron WAITING, TimesTriggered=1, PreviousFireTime 2026-11-07T16:00:11.162Z, prochain passage 8 novembre 16:00Z. PreArrival TF-DEMO-001 Completed/Scheduled, ExecutedAt=16:00:15Z. Six tâches sur ce dossier après ce passage, contre cinq au checkpoint. |
| BUSINESS-RESTRICTED-001 | Conversation Employee avec compte restreint | NotRun | Les essais ci-dessus utilisent l'opérateur Admin/RH. Les tests Apex restreints antérieurs ne prouvent pas le comportement conversationnel sous un autre compte. |
| BUSINESS-CANCEL-001 | Runtime publié, TF-DEMO-003 | Passed | list_slots réel puis message de type Confirm pour reserve_interview ; réponse « Non, annule ». Aucun FunctionStep de réservation exécuté dans la trace finale ; COUNT des réservations = 0. evidence/agent-published-cancel.json ; ce fichier contient zéro invocation, sans prétendre prouver seul le COUNT en base. Session fermée. |
| BUSINESS-FAILURE-001 | Panne technique injectée dans une conversation | NotRun | Dossier absent testé ; panne technique distincte non provoquée. |
| BUSINESS-PUBLISH-001 | TFDev, TalentFlow_Assistant | Passed | Publication success=true, 16 éléments récupérés et 3 déployés. AiAgentDefinitionVersion version 1 récupérée. Aucune version TalentFlow préexistante dans l'inventaire. |
| BUSINESS-ACTIVATE-001 | TFDev, version 1 | Passed | Activation CLI success=true ; récupération Metadata API Succeeded, status Active et version 1 relus. surfacesEnabled=false constaté sans déduire de visibilité UI. |
| BUSINESS-PUBLISHED-BRIEF-001 | Runtime publié, TF-DEMO-003 | Passed | FunctionStep get_brief réel, résultat SUCCESS et sortie minimisée. evidence/agent-published-brief.json. Métadonnées de cette session sans champ mockMode ; preuve étiquetée Published Runtime, distincte de Live Test du brouillon. Session fermée. |
| BUSINESS-ACCESS-001 | TFDev, déploiement 0AfgK00000Z8uGzSAJ | Passed | TF_AssistantAccess déployé Succeeded puis affecté au seul opérateur courant : 1 succès, 0 échec. N'ajoute ni droits objet ni permission RH. |
| BUSINESS-LIGHTNING-001 | Navigateur Salesforce | NotRun | Version active et droit affecté ; affichage dans le sélecteur et conversation Lightning à vérifier par l'utilisateur. |
| BUSINESS-SOURCE-CHECK-001 | Poste local après publication | Passed | XML bien formés, syntaxe Python valide ; empreintes des configurations de preuves appariées à leurs archives, exactement quatre actions dans le runtime récupéré, confirmation requise pour réserve seulement, version 1 Active et logPrivateConversationData=false. Aucun email ni motif de credential détecté dans les 11 fichiers de métadonnées agent générées. Aucun changement fonctionnel Apex dans cette reprise. |
| BUSINESS-GIT-PUSH-001 | GitHub tareknjm/talentflow360, main | Passed | Checkpoint métier 364a96a poussé sans force depuis b1f0b1a ; exclusions et motifs de credentials contrôlés avant commit. Bilan documentaire ajouté ensuite. |

## Retours de la démonstration guidée — 7 novembre 2026

| ID | Environnement | Statut | Résultat et source |
|---|---|---|---|
| UI-PULSE-001 | Interface Salesforce, dossier demandé TF-DEMO-002 | Passed | L'utilisateur répond « c bon » après le guidage de saisie unique 1/5. Confirmation déclarative ; aucune relecture distante effectuée ici. |
| UI-PULSE-ALERT-001 | Interface Salesforce, Tâches | Passed | L'utilisateur répond « c bon » après la demande de vérifier l'alerte RH liée au dossier. Confirmation déclarative, sans capture ou identifiant de tâche. |
| UI-SIMULATION-001 | Interface Salesforce, J+30 du dossier demandé TF-DEMO-002 | NotRun | Retour « c bon » après un guidage se terminant par l'ouverture de l'étape : ne permet pas à lui seul de distinguer ouverture et exécution complète. État final et tâche Simulation à confirmer. |

## Conception UI/UX locale — 7 novembre 2026

| ID | Environnement | Statut | Résultat et source |
|---|---|---|---|
| UX-PROTOTYPE-STRUCTURE-001 | Windows, Python HTMLParser et Node --check | Passed | prototype.html parsé ; IDs uniques, cibles de navigation/ARIA existantes, syntaxe JS valide ; aucun script externe, aucune ressource distante ni appel réseau dans le prototype. Contrôle répété après ajout des liens directs. |
| UX-PROTOTYPE-RENDER-001 | Chrome headless dans le bac restreint | Failed | Processus graphique inutilisable dans le bac ; aucune capture produite par ce premier essai. Ce n'est pas un échec Salesforce. |
| UX-PROTOTYPE-RENDER-002 | Chrome headless autorisé, profils locaux isolés, 1440 × 1100 | Passed | Captures accueil et dossier générées puis inspectées visuellement ; bandeau, navigation, cartes, onglets et aperçu assistant lisibles. docs/ui-ux/apercu-accueil.png et apercu-dossier.png. Aucun accès Salesforce. |
| UX-PROTOTYPE-NARROW-001 | Capture headless demandée 390 × 1000 | NotRun | Captures générées mais tronquées ; largeur effective du viewport non instrumentée, pas de conclusion de recette responsive. Ajustements de contraintes CSS effectués ; contrôle réel avec émulation encore à faire. |
| UX-PROTOTYPE-INTERACTION-001 | Navigateur, clavier et rôles | NotRun | Comportements écrits, mais bascule des rôles, dialogues, navigation clavier et zoom non exercés complètement dans un navigateur. La capture dossier prouve seulement le chargement du lien direct. |
| UX-SALESFORCE-DEPLOY-001 | TFDev | NotRun | Aucun composant UI/UX de cette proposition déployé ou activé. La maquette et les chiffres sont fictifs ; ils ne prouvent pas l'état réel de l'org. |

## Premier incrément UI natif — 7 novembre 2026

Les lignes de conception ci-dessus décrivent l'état avant la demande « go ». Les nouvelles preuves concernent les vrais composants Salesforce ; elles ne valident pas encore le rendu du navigateur.

| ID | Environnement | Statut | Résultat et source |
|---|---|---|---|
| UX-NATIVE-TARGET-001 | TFDev, API 68.0 | Passed | Organization relue avant mutations : Developer Edition CAN96. App/layout/objet récupérés dans ui-baseline puis ui-predeploy ; comparaison identique avant le déploiement réel, aucune modification concurrente détectée. Aucune FlexiPage TalentFlow préexistante. |
| UX-NATIVE-COMPARE-001 | Poste local, comparaison stricte des champs | Failed | Comparaison source/récupération signale des valeurs par défaut explicites (trackTrending=false, caseSensitive=false, deleteConstraint=SetNull). Ce n'est pas une preuve de changement du binôme. Déploiement réel ensuite limité à un staging UI sans ces champs ; seule la validation à blanc avait été lancée avec l'inventaire plus large. |
| UX-NATIVE-DRY-001 | TFDev, 0AfgK00000Z8t5jSAB | Failed | Première validation refuse parentFieldApiName manquant dans les listes associées. Correction au parent TalentProfile__c.Id ; aucune mutation réelle par ce dry-run. |
| UX-NATIVE-DRY-002 | TFDev, 0AfgK00000Z9DBZSA3 | Passed | Staging borné : 5 composants, Succeeded, NoTestRun ; aucun champ métier ni permission inclus. |
| UX-NATIVE-DEPLOY-001 | TFDev, 0AfgK00000Z99kgSAB | Passed | 5 composants déployés, Succeeded. App, page, layout, objet et compact layout. Aucune logique Apex/Flow changée, pas de test Apex relancé. |
| UX-NATIVE-ASSIGNMENT-001 | Métadonnées récupérées après déploiement | Passed | TalentFlow360 : override Large pour TalentProfile__c vers TF_TalentWorkspace ; compactLayoutAssignment TF_TalentSummary. Navigation Dossiers/Créneaux/Étapes/Tâches. Champs et validations TalentProfile identiques à la sauvegarde ; boutons existants préservés. docs/evidence/ui-workspace.json. |
| UX-NATIVE-DISPLAY-DRY-001 | TFDev, 0AfgK00000Z8iPWSAZ | Passed | 8 composants, Succeeded : libellés de relations et colonne Dossier talent ajoutés. Accent du libellé corrigé localement avant envoi réel ; aucun changement de contrat. |
| UX-NATIVE-DISPLAY-DEPLOY-001 | TFDev, 0AfgK00000Z9EQzSAN | Passed | Déploiement final 8 composants Succeeded, NoTestRun. Récupération après envoi : les deux lookup diffèrent de la sauvegarde uniquement par relationshipLabel ; colonne TalentProfile__c présente dans TF_ReservedSlots. |
| UX-NATIVE-UIAPI-001 | UI API v68, opérateur connecté | Passed | related-list-info/TalentProfile__c/InterviewSlots__r et JourneySteps__r : HTTP 200, titres Entretiens et Étapes de parcours ; colonnes dates/états et ExecutionMode du parcours reconnues. Ne prouve pas la restriction sous un autre compte. |
| UX-NATIVE-STRUCTURE-001 | Poste local | Passed | XML bien formés, scripts Python syntaxiquement valides, compact layout et sept champs de page contrôlés. Identité/approbation/satisfaction absentes des fieldItem de la FlexiPage. Aucun appel réel Agentforce relancé, contexte effectif du panneau non validé par ce contrôle statique. |
| UX-NATIVE-BROWSER-001 | Navigateur Salesforce | NotRun | Vérifier les quatre onglets et listes réelles, l'état vide, le bandeau, le fuseau et les actions existantes sur TF-DEMO-003/001. |
| UX-NATIVE-RESTRICTED-001 | Compte recruteur réellement restreint | NotRun | FLS/partage, absence de contexte privé dans le chat, refus RH et visibilité des composants à recetter dans le navigateur. |
| UX-NATIVE-ACCESSIBILITY-001 | Navigateur Salesforce | NotRun | Navigation clavier, zoom 200 %, largeurs 390/768/1440 et messages de chargement/erreur non vérifiés. |
