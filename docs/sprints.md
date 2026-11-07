# Sprints — TalentFlow 360

Plan accepté le 7 novembre 2026. Démonstration le 27 novembre, gel fonctionnel le 25.
Deux personnes à 4 h/jour chacune, week-ends compris : 160 heures-personnes du 7 au 26, dont 128 engagées et 32 de réserve. Les dates sont des objectifs, jamais des preuves de livraison.

| Sprint | Dates novembre 2026 | Phases | Travail prévu | Charge / réserve | Sortie attendue |
|---|---|---|---|---|---|
| S0 | 7–8 | 0–1 | Cible, Git, règlement, sonde Agentforce réelle | 12 h / 4 h | Appel d'action observable ou blocage documenté |
| S1 | 9–13 | 2–3 | Six objets, données synthétiques, application, droits | 32 h / 8 h | Validations et accès testés dans l'org |
| S2 | 14–17 | 4–5 | Brief, liste/réservation, suivi, assistant | 26 h / 6 h | Actions réelles et refus testés |
| S3 | 18–20 | 6–8 | Approbation humaine, parcours J−7 à J+90, satisfaction, vues | 20 h / 4 h | Parcours complet et déclenchement automatique observé |
| S4 | 21–24 | 9 | Recette, corrections, six essais de mesure, deux resets | 26 h / 6 h | Aucun défaut critique ouvert et preuves consignées |
| S5 | 25–26 | 10 | Gel, documentation, slides, vidéo, répétitions | 12 h / 4 h | Version identifiée et supports accessibles |

## Répartition

- Tarek : Apex, sécurité, Git, déploiements et tests techniques ; relecture des Flows.
- Binôme : règles métier, Flows, contenus, écrans standard et recette fonctionnelle ; relecture des résultats techniques.
- Codex : assistance à l'implémentation et aux vérifications ; les interventions humaines et preuves absentes restent visibles.
- Un seul éditeur par Flow dans l'org. Une branche Git n'isole pas les modifications Salesforce.

## Contrat de livraison

Chaque tâche a un propriétaire, un relecteur, une estimation et un critère d'acceptation dans le backlog. Les sous-tâches complètent les identifiants existants.
Avant une mutation distante : contrôler TFDev par une lecture, vérifier le type d'org et comparer les changements du binôme. Ne pas écraser un composant existant sans inspection.
Une tâche métier n'est Done qu'après fichiers relus, déploiement confirmé, activation vérifiée et tests positifs/négatifs exécutés. Les tests ont les statuts Passed, Failed, Blocked ou NotRun.
Après chaque étape significative, consigner réalisé, vérifié, bloqué et prochaine action dans progress.md.

## Arbitrages

- API 68.0 conservée ; Lightning standard avant LWC.
- Aucun backend externe, calendrier externe, envoi de message, classement ou décision RH par l'agent.
- Les quatre actions, la frontière RH humaine, les six étapes, les tests de sécurité et le reset restent prioritaires.
- Réduire les KPI et la finition avant de réduire les contrôles.
- Si Agentforce bloque, poursuivre les travaux indépendants sans annoncer l'intégration terminée. Les manipulations et preuves Preview restent distinctes des tests directs du Flow.
- Règlement, durée officielle et produits imposés : à confirmer humainement, sans supposer leur contenu.
- Le 27 novembre : contrôle court et présentation, aucune nouvelle fonctionnalité.
