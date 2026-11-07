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
