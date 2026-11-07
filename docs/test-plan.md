# Plan de test

## Phase 0 et sonde de phase 1

| ID | Scénario | Résultat attendu |
|---|---|---|
| ENV-001 | Vérifier Git, Java, Salesforce CLI et VS Code | Les outils requis sont trouvés avec leurs versions |
| AUTH-001 | Lire `Organization` avec l'alias `TFDev` | Une seule Developer Edition répond sans afficher de secret |
| FLOW-001 | Convertir localement `TF_ConnectionProbe` au format Metadata API | Conversion réussie sans avertissement |
| FLOW-002 | Valider le manifeste en dry-run | 1 composant valide, 0 erreur |
| FLOW-003 | Déployer le manifeste ciblé | 1 composant déployé, 0 erreur |
| FLOW-004 | Vérifier la définition du Flow par Tooling API | Version active et dernière version égales à 1 |
| FLOW-005 | Exécuter le Flow directement avec `TF-PROBE-001` | Compilation et exécution réussies, sortie synthétique exacte |
| AGENT-ACCESS-001 | Lire les licences Agentforce/Einstein de l'org | Licences nécessaires actives et disponibles |
| AGENT-ACCESS-002 | Lire les affectations de l'utilisateur connecté | Licence Builder et permission set Builder présents |
| AGENT-001 | Appeler le Flow via une action depuis Agentforce Preview | Appel observable et `safeSummary` reçu depuis le Flow réel |

## S1 — Modèle et outils synthétiques

| ID / classe | Scénario | Résultat attendu |
|---|---|---|
| TF_ModelTest.rejectsInvalidData | Fin avant début, score 0/6/1,5, code en double, réservation incomplète | Tous refusés ; satisfaction 4 acceptée |
| TF_ModelTest.blocksForgedApprovalEvenForApprover | Écriture directe ou insertion d'approbation | Refus même pour un acteur ayant le rôle RH |
| TF_ModelTest.approvalRequiresConfirmationAndValidTransition | Sans confirmation puis validation réelle puis répétition | Sans effet, puis Hired avec acteur/date/cycle, puis aucune nouvelle validation |
| TF_DemoDataTest.seedTwiceAndResetTwicePreservesForeignData | Deux seeds et deux resets en transaction de test | Six profils, six identités, huit créneaux ; témoin hors lot conservé, zéro invocation email |
| TF_DemoDataTest.resetRefusesForeignDependency | Étape sans marqueur liée à un profil de démonstration | Reset refusé avant suppression |

Les tests Apex isolés ne prouvent pas le contexte Agentforce, le clic humain du Screen Flow, l'affectation des layouts ni les droits d'un utilisateur réel. Ils n'attestent pas à eux seuls la capacité à reconstruire une org neuve.

## S2 — Actions directes

- TF_AgentActionsTest : liste blanche du brief et informations manquantes ; code invalide ; même réponse pour absent/inaccessible ; limite de 20 créneaux futurs sur 31 jours ; refus sans confirmation ; réservation réussie puis répétée ; refus occupé/passé/mauvais type/Draft ; sortie de suivi excluant un message contenant une injection ; refus des lots de plus de dix demandes.
- checkBusinessActions.apex : mêmes interfaces appelées dans l'org réelle sur les codes TF-DEMO, sans réservation confirmée ni données personnelles dans les preuves.
- Concurrence : deux exécutions réellement simultanées vers le même créneau, avec intervalles serveur observés ; une seule réservation finale. Deux appels séquentiels ne valident pas ce cas.
- Preview : configuration et conversations réelles séparées, notamment confirmation et absence d'outil RH/générique. Statut NotRun tant que non observées.
