# Backlog

Statuts : `Todo`, `InProgress`, `Blocked`, `Done`.

| ID | Phase | Tâche | Responsable proposé | Priorité | Statut | Critère de sortie |
|---|---:|---|---|---|---|---|
| TF-000 | 0 | Diagnostiquer dépôt, Git, Java, CLI et VS Code | Codex / Tarek | P0 | Done | Versions et état réel consignés dans `docs/progress.md` |
| TF-001 | 0 | Réauthentifier l'org de développement `TFDev` | Tarek | P0 | Done | `sf data query` réussit sur `Organization` sans exposer de secret |
| TF-002 | 0 | Créer le cadrage local initial | Codex | P0 | Done | README, AGENTS, progression, backlog, setup, modèle et décisions présents |
| TF-010 | 1 | Construire le Flow autolaunched `TF_ConnectionProbe` | Binôme / Codex | P0 | Done | Entrée `candidateCode`, sortie `safeSummary`, déploiement réussi |
| TF-011 | 1 | Vérifier activation, licence et permissions Agentforce | Tarek | P0 | Done | Builder accessible et Preview Employee réellement démarré |
| TF-012 | 1 | Appeler `TF_ConnectionProbe` depuis un agent de test | Tarek / Codex | P0 | Done | Preuve Live Test et FunctionStep dans docs/evidence/agent-probe.json |
| TF-020 | 2 | Créer les six objets et leurs validations | Tarek | P0 | Done | Déploiement réel 0AfgK00000Z4L1hSAF et 9 tests réussis |
| TF-021 | 2 | Créer six profils synthétiques et des créneaux | Binôme | P1 | InProgress | Seed répété et effectifs vérifiés ; consultation UI à constater |
| TF-030 | 3 | Définir permission sets et matrice d'accès | Tarek | P0 | Done | Droits minimaux et partage exercés par TF_AccessTest ; contexte Employee partagé documenté |
| TF-040 | 4 | Implémenter le brief candidat minimisé | Tarek | P0 | Done | Tests minimaux et appel direct réel, liste blanche sans identité |
| TF-041 | 4 | Lister et réserver les créneaux de façon idempotente | Tarek | P0 | Done | Libre/occupé/passé/répété testés ; deux transactions concurrentes, une seule réservation |
| TF-050 | 5 | Configurer `TalentFlow Assistant` | Binôme / Tarek | P0 | Done | Quatre actions métier réellement appelées dans Preview Live Test ; confirmation et refus vérifiés, preuves expurgées |
| TF-060 | 6 | Créer le Screen Flow de validation RH | Binôme | P0 | InProgress | Flow actif, service autorisé/refusé testé ; clics UI à recetter |
| TF-070 | 7 | Générer le parcours J-7 à J+90 sans doublon | Binôme / Tarek | P0 | Done | Six étapes, replanification, vraie échéance Once et passage quotidien définitif du 7 novembre vérifiés |
| TF-071 | 7 | Saisir la satisfaction et créer l'alerte RH | Binôme | P1 | InProgress | 1/5 et 4/5 exercés dans l'org, alerte unique ; écran à recetter |
| TF-080 | 8 | Construire les vues Lightning et KPI factuels | Binôme | P1 | InProgress | Application/listes/layouts déployés ; visite humaine et suivi visuel à valider |
| TF-090 | 9 | Exécuter la recette sécurité, métier et IA responsable | Les deux | P0 | InProgress | 18 tests complets et 5 ciblés antérieurs ; conversations métier réelles effectuées ; recette UI, compte restreint et mesures restantes |
| TF-100 | 10 | Préparer démo, reset et solution de secours | Les deux | P0 | InProgress | Petite démo prête ; resets réels, vidéo et gel final non exécutés |

## Affectation aux sprints et charges

Voir `sprints.md` pour dates, capacités et réserves. Les charges ci-dessous sont des heures-personnes totales, pas une mesure du temps réellement consommé. Les identifiants suffixés découpent les tâches parentes ; la tâche parente n'est Done que lorsque toute sa sortie est démontrée.

| Sprint | ID | Travail | Propriétaire | Relecteur | h | Dépendance | Critère de sortie |
|---|---|---|---|---|---:|---|---|
| S0 | TF-003 | Revalider cible et exclusions Git | Tarek | Binôme | 1 | TF-001 | Lecture TFDev et exclusions réussies |
| S0 | TF-011 | Constater accès et contexte Builder | Tarek | Binôme | 2 | TF-003 | Capture expurgée et contexte documentés |
| S0 | TF-012 | Relier puis appeler la sonde dans Preview | Tarek | Binôme | 5 | TF-011 | Action réelle observable |
| S0 | TF-004 | Contraintes du règlement et calendrier | Binôme | Tarek | 1 | Aucune | Confirmation utilisateur enregistrée |
| S0 | TF-005 | Commit initial et méthode Git | Tarek | Binôme | 3 | TF-003 | Contenu inspecté, aucun secret, commit local |
| S1 | TF-020-A | Champs exacts et six objets | Tarek | Binôme | 8 | TF-003 | Déploiement confirmé |
| S1 | TF-020-B | Validations et garde d'approbation | Tarek | Binôme | 5 | TF-020-A | Données invalides et approbation forgée refusées |
| S1 | TF-022 | Application, onglets et pages standard | Binôme | Tarek | 4 | TF-020-A | Consultation métier possible |
| S1 | TF-021 | Seed de six profils et créneaux | Binôme | Tarek | 4 | TF-020-A | Deux exécutions sans doublon ni message |
| S1 | TF-030 | Permissions et tests d'accès | Tarek | Binôme | 8 | TF-020-B | Matrice et refus en contexte restreint |
| S1 | TF-023 | Scénarios de recette modèle | Binôme | Tarek | 3 | TF-020-A | Cas négatifs et preuves consignés |
| S2 | TF-040 | Brief candidat minimisé | Tarek | Binôme | 4 | TF-030 | Sortie sûre et refus testés |
| S2 | TF-041-A | Liste bornée des créneaux | Tarek | Binôme | 3 | TF-030 | Période et autorisations contrôlées |
| S2 | TF-041-B | Réservation transactionnelle | Tarek | Binôme | 7 | TF-041-A | Répétition et appels concurrents vérifiés |
| S2 | TF-042 | Lecture du parcours | Tarek | Binôme | 3 | TF-030 | Sortie vide ou étapes limitées |
| S2 | TF-050 | Assistant et quatre actions | Binôme | Tarek | 5 | TF-012, TF-040/041/042 | Appels métier réels dans Preview |
| S2 | TF-051 | Refus et confirmation avant réservation | Les deux | Les deux | 4 | TF-050 | Aucun faux succès ni mutation interdite |
| S3 | TF-060 | Écran RH et contrôle serveur | Binôme | Tarek | 4 | TF-030 | Confirmation, acteur/date et refus |
| S3 | TF-070-A | Génération et replanification du parcours | Tarek | Binôme | 5 | TF-060 | Six étapes uniques, changements cohérents |
| S3 | TF-070-B | Passage quotidien et simulation restreinte | Binôme | Tarek | 4 | TF-070-A | Exécution réelle et simulation distinguées |
| S3 | TF-071 | Satisfaction et alerte unique | Binôme | Tarek | 4 | TF-070-A | 1/5 alerte une fois, 4/5 aucune |
| S3 | TF-080 | Vues métier et suivi assistant | Binôme | Tarek | 3 | TF-071, TF-042 | Navigation standard utilisable |
| S4 | TF-090-A | Recette technique, accès et concurrence | Tarek | Binôme | 10 | S3 | Aucun défaut critique ouvert |
| S4 | TF-090-B | Recette fonctionnelle et conversations | Binôme | Tarek | 6 | S3 | Preuves métier/Agentforce séparées |
| S4 | TF-091 | Corrections puis tests ciblés | Les deux | Les deux | 5 | TF-090-A/B | Régressions concernées vérifiées |
| S4 | TF-092 | Trois essais manuels et trois assistés | Les deux | Les deux | 3 | TF-091 | Médianes et manipulations mesurées |
| S4 | TF-100-A | Deux resets bornés | Tarek | Binôme | 2 | TF-021 | Données hors lot préservées |
| S5 | TF-100-B | Gel et documentation de transfert | Tarek | Binôme | 4 | S4 | Version identifiée, limites explicites |
| S5 | TF-100-C | Slides et vidéo locale | Binôme | Tarek | 4 | TF-100-B | Secours accessible hors réseau |
| S5 | TF-100-D | Répétitions et contrôle matériel | Les deux | Les deux | 4 | TF-100-C | Parcours expliqué par chacun |

État de reprise du 7 novembre : les quatre actions métier sont raccordées et réellement invoquées dans Preview Live Test. La réservation exige une confirmation et sa répétition ne crée pas de doublon. Publication suivie séparément dans progress.md ; activation Lightning et recette UI non annoncées terminées. Le checkpoint de pause b1f0b1a reste sur GitHub.
