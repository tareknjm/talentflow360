# Décisions techniques

## ADR-001 — Tranche Salesforce native

- Date : 7 novembre 2026
- Statut : Accepted
- Décision : construire le MVP avec Lightning, objets personnalisés, Flow, Agentforce et Apex seulement lorsque nécessaire.
- Conséquence : aucun backend Spring Boot, React, base externe ou API OpenAI dans le MVP.

## ADR-002 — Séparer identité et profil agent

- Date : 7 novembre 2026
- Statut : Accepted
- Décision : stocker l'identité fictive dans `CandidateIdentity__c` et exposer à l'agent uniquement un dossier pseudonymisé `TalentProfile__c`.
- Conséquence : le rapprochement se fait côté serveur autorisé par `CandidateCode__c`, sans relation navigable fournie à l'agent.

## ADR-003 — Décision d'embauche humaine et distincte

- Date : 7 novembre 2026
- Statut : Accepted
- Décision : réserver l'embauche au Screen Flow `TF_ApproveHiring`, jamais à une action Agentforce.
- Conséquence : l'agent ne reçoit aucun outil générique permettant de modifier les champs d'approbation ou le statut `Hired`.

## ADR-004 — Conserver l'API source 68.0 pendant le diagnostic

- Date : 7 novembre 2026
- Statut : Accepted
- Décision : conserver la version `68.0` déjà définie dans `sfdx-project.json` jusqu'à vérification de l'org.
- Conséquence : toute incompatibilité observée sera documentée avant un changement de version.

## ADR-005 — Ne pas masquer le blocage d'authentification

- Date : 7 novembre 2026
- Statut : Accepted
- Décision : considérer `TFDev` comme déconnectée tant qu'une requête de lecture réelle échoue.
- Conséquence : aucun déploiement ni accès Agentforce n'est annoncé avant reconnexion et vérification.

## ADR-006 — Sprints et capacités

- Date : 7 novembre 2026 ; statut : Accepted par l'utilisateur.
- Démonstration le 27 novembre, 4 h/jour/personne pour deux personnes ; 128 heures prévues et 32 de réserve. Voir sprints.md et backlog.md.
- L'utilisateur confirme que code préparé et assistance sont permis. Aucun produit supplémentaire n'est ajouté.

## ADR-007 — Agent interne Employee et frontière explicite

- Date : 7 novembre 2026 ; statut : choix retenu, contexte réel à vérifier.
- Les captures montrent le nouveau Builder et le modèle Agentforce Employee Agent. Ce modèle est retenu pour le recruteur connecté.
- Aucun agent créé ni appel Preview constaté à cette étape. Pas d'identité technique séparée supposée.

## ADR-008 — Protection RH dès la création du modèle

- Date : 7 novembre 2026 ; statut : implémentation locale, validation en cours.
- Installer la garde d'approbation en même temps que les champs, avant le Screen Flow. Le service dédié est le seul à ouvrir sa porte transactionnelle sur un dossier verrouillé ; il renseigne acteur/date/cycle.
- Une seule demande humaine par invocation du service RH ; les lots sont refusés sans écriture. Ce service n'est jamais configuré comme action Agentforce.
- Le mode système est explicite pour les seuls champs protégés après contrôle du rôle, de la confirmation, de l'accès au dossier et de l'état. Les tests utilisateur restent indispensables.

## ADR-009 — Contraintes de métadonnées constatées dans TFDev

- Date : 7 novembre 2026 ; statut : corrections après dry-runs réels.
- User ne permet pas Restrict/Cascade sur une relation enfant ; le recruteur est donc obligatoire par validation métier plutôt que required sur le lookup.
- Les blocs PermissionSet suivent l'ordre du schéma ; les champs universellement requis n'ont pas de FLS configurable.
- Score conserve une décimale technique avec validation d'entier ; le service de saisie contrôlera l'entrée avant stockage pour éviter les arrondis implicites.

## ADR-010 — Raccordement métier et publication de développement

- Date : 7 novembre 2026 ; statut : réalisé dans TFDev à la reprise demandée.
- Quatre actions Apex uniquement ; aucune sonde, action RH ou recherche générique dans la version métier. Confirmation conversationnelle et require_user_confirmation Salesforce pour réserver. Id Apex déclaré object/lightning__recordIdType dans Agent Script, exigence constatée au démarrage Preview.
- Publication puis activation de la version 1 dans la Developer Edition vérifiée, après appels réels. Métadonnées générées conservées séparément du manifeste backend. Droit TF_AssistantAccess indépendant, déployé après publication et affecté à l'opérateur.
- Runtime publié testé techniquement ; visibilité Lightning, clics humains et conversation sous compte restreint restent à recetter. Aucun utilisateur technique séparé ni restriction des droits Admin existants n'est revendiqué.

## ADR-011 — Navigation guidée native avant composants personnalisés

- Date : 8 novembre 2026 ; statut : déployé dans TFDev, recette visuelle en attente.
- Mon espace est une AppPage et un onglet propre à TalentFlow, sans modification de la Home globale ; trois listes de données accessibles, pas de dashboard exécuté sous administrateur ou de KPI figé.
- Droit d'onglet indépendant TF_WorkspaceAccess ; aucune extension des droits métier. App et page relues avant mutation, sauvegardes conservées hors Git.
- Actions RH conditionnées par état et permission avec contrôles serveur inchangés. Modifier reste proposé après Hired pour permettre les changements de date/rôle et la replanification existante.
- Le pipeline visuel et les aides décrivent les cinq états déjà implémentés. Un état « entretien réalisé » et une matrice Deloitte spécifique demanderaient une évolution fonctionnelle séparée ; aucune validation de processus Deloitte n'est revendiquée.
