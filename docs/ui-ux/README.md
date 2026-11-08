# TalentFlow 360 — conception UI/UX

**Livraison du 8 novembre :** [Mon espace et actions contextuelles](guided-workspace.md) sont déployés dans TFDev. Accueil standard avec listes réelles, règles d'actions et indications par état ; recette navigateur restante. Les chiffres et composants HTML ci-dessous restent ceux de la maquette.

7 novembre 2026. Livrable local de conception, sans déploiement Salesforce. La demande « ok proceed » poursuit la proposition de maquette et de backlog ; les composants de production restent ceux du checkpoint existant.

**Mise à jour après « go » :** le premier incrément natif est maintenant déployé dans TFDev : navigation, fiche candidat à quatre onglets, synthèse et listes associées. Voir [livraison et ouverture de la vraie page](native-workspace.md). Le prototype ci-dessous reste une conception plus large, avec des exemples fixes ; il n'est pas connecté à l'org.

## Consulter la maquette

Ouvrir [prototype.html](prototype.html) dans Edge, Chrome ou Firefox depuis l'explorateur Windows : clic droit sur le fichier, puis Ouvrir avec. Aucun serveur, installation, connexion réseau ou compte n'est nécessaire.

Accès directs : [dossier](prototype.html#dossier), [parcours](prototype.html#parcours), [vue RH](prototype.html#rh).

Aperçus rendus dans Chrome : [accueil](apercu-accueil.png) et [dossier](apercu-dossier.png). Ces captures montrent la maquette, pas des écrans Salesforce déployés.

1. Observer **Mon espace** : priorités, entretiens et échéances.
2. Cliquer **Préparer cet entretien** : ouverture du dossier et de l'onglet Préparation.
3. Parcourir Vue d'ensemble, Préparation, Entretien et Intégration. Les flèches gauche/droite naviguent entre les onglets lorsque leur barre a le focus.
4. Choisir **Responsable RH** en haut : apparition du suivi RH et de l'alerte d'accueil.
5. Ouvrir **Suivi RH** : le panneau d'assistant disparaît dans cet aperçu.
6. Revenir en vue Recruteur : le suivi RH disparaît. Cette bascule est une illustration d'interface, pas un mécanisme de sécurité.

Les valeurs et compteurs sont des exemples fixes, indépendants de TFDev. Le dossier TF-DEMO-003 est présenté dans un scénario hypothétique d'entretien planifié ; ne pas en déduire son état réel. La frise est explicitement un autre scénario d'intégration, distinct de ce dossier.

## Décisions de conception

| Décision | Besoin utilisateur | Mise en œuvre Salesforce proposée |
|---|---|---|
| Accueil orienté travail du jour | Savoir quoi traiter sans ouvrir six listes | Home FlexiPage, listes/rapports compatibles avec les droits |
| Navigation : accueil, dossiers, créneaux, étapes, tâches | Retrouver rapidement le parcours principal | CustomApplication ; objets sensibles retirés de la navigation principale, sans remplacer les permissions |
| Bandeau dossier compact | Lire code, rôle, état et disponibilité immédiatement | CompactLayout et Highlights Panel sur Record FlexiPage |
| Sections métier, détails techniques à part | Éviter la longue section de champs actuelle | Layout réorganisé, Tabs et Record Detail ; Dynamic Forms seulement si nécessaire et vérifié dans l'org |
| Boutons selon état et permission | Comprendre la prochaine action | Actions dynamiques ; réutilisation des Quick Actions et Flows existants |
| Fuseau explicite | Éviter l'ambiguïté 10 h locale / 18 h UTC | Affichage basé sur le fuseau utilisateur et libellé associé ; vérifier changement de date et heure d'été |
| Parcours avec six jalons | Comprendre la progression sans lire une table entière | D'abord liste associée standard ; LWC de frise si le résultat standard reste insuffisant |
| Vocabulaire « Tâches générées » | Distinguer automatisation et travail humain | Présentation de Completed sans changer sa valeur API ; état réel des Task consultable séparément |
| Badge Simulation visible | Ne pas présenter un futur simulé comme exécution planifiée | Lecture de ExecutionMode__c ; rester explicite sur les tâches synthétiques réellement créées |
| Interface Agentforce existante | Garder les appels réels et leurs confirmations | Panneau existant ; suggestions représentées dans la maquette à vérifier avant toute promesse d'intégration |

## Données et sécurité

- Recrutement courant : code, rôle, preuves, disponibilité, réservation, états de parcours ; jamais nom/email/CV/satisfaction dans le chat.
- RH : validation et satisfaction dans un parcours séparé. Masquer un composant ne retire pas les droits et ne prouve pas que son contenu est absent du contexte agent. Vérifier les permissions, DTO et traces de conversation ; ne pas ajouter de grounding de page privée.
- Le prototype juxtapose l'aperçu d'assistant aux seules sections minimisées. L'affectation d'une vraie page et le comportement du panneau global Agentforce doivent être testés indépendamment.
- Aucun bouton « Valider l'embauche » dans une action Agentforce. La validation réelle continue à utiliser TF_ApproveHiring et son service serveur.
- Une prochaine action est une règle d'état, pas une recommandation d'embaucher. Ne pas rendre Hired modifiable via Path/Kanban ou édition rapide ; garder la garde serveur.
- Les alertes RH sont des tâches dérivées des réponses, pas un score du candidat. Leur consultation ne rend pas ces informations accessibles à l'agent.

## Définition des indicateurs proposés

| Indicateur | Définition avant réalisation | Point de vigilance |
|---|---|---|
| Dossiers en cours | Profils accessibles dont Status__c n'est pas Hired | Décompte de dossiers, sans classement |
| Entretiens à venir | Créneaux accessibles Reserved dont Start__c est dans les 7 prochains jours | Ancrer la période à l'heure courante ; afficher le fuseau |
| Étapes ouvertes en retard | Étapes accessibles Pending dont DueDate__c est strictement antérieure à aujourd'hui | Ne pas compter Completed/Simulation comme travail humain terminé ; Failed à traiter séparément |
| Alertes RH à traiter | Tâches d'alerte ouvertes, dans le périmètre RH autorisé | Confirmer une identification structurée : ne pas dépendre seulement du texte du sujet ou d'un accès système global |

Les rapports et tableaux de bord devront respecter le périmètre de l'utilisateur. Un tableau de bord exécuté au nom d'un administrateur peut élargir les données visibles : vérifier le mode d'exécution et les licences avant affectation. Si l'indicateur d'alerte ne peut être obtenu proprement avec le modèle actuel, commencer par une liste de tâches plutôt qu'ajouter un champ ou du code.

## Réalisation par incréments

Les charges sont une estimation initiale en heures-personnes, pas une consommation ni un engagement de délai. Deux personnes ne réduisent pas automatiquement la durée de moitié. Le calendrier accepté reste inchangé ; remplacer/reprioriser la finition existante TF-080/TF-091 avant d'engager cette charge. La réserve de sécurité n'est pas automatiquement affectée à l'UI.

| Lot | Identifiants | Charge proposée | Sortie |
|---|---|---:|---|
| A — Lecture et navigation | TF-080-UX-01 à 03 | 6 h | Application et dossier compréhensibles avec composants standard |
| B — Travail guidé | TF-080-UX-04 à 06 | 8 h | Accueil, actions conditionnelles et états utiles |
| C — Recette UI | TF-090-UX-01 | 3 h | Vérification métier, accès, clavier et fenêtres étroites |
| Option frise LWC | TF-080-UX-07 | 6–10 h | À retenir seulement après évaluation de la liste standard |

Socle proposé : **17 h**, option frise exclue. Si la capacité manque, garder A et la recette, puis réduire les indicateurs et l'accueil. Les preuves de sécurité et la recette critique existante restent prioritaires.

## Backlog détaillé

Propriétaires proposés selon l'organisation actuelle. Relecteur distinct ; affectations à ajuster si les disponibilités réelles diffèrent. Après le premier incrément : UX-01 et UX-02 sont InProgress (déploiement/affectation vérifiés, recette navigateur restante), UX-03 InProgress (colonne dossier ajoutée aux réservations ; fuseau à valider), UX-04 à 07 et la recette UX dédiée restent Todo. Aucune tâche de réalisation n'est annoncée Done sur la seule preuve de déploiement.

| ID | Priorité | Propriétaire / relecteur | h | Dépendance | Acceptation et preuve attendue |
|---|---|---|---:|---|---|
| TF-080-UX-00 | P1 | Codex / Tarek et binôme | Non mesuré | Diagnostic local | Done pour les artefacts : maquette autonome et spécification écrites ; revue visuelle utilisateur encore NotRun |
| TF-080-UX-01 | P1 | Tarek / Binôme | 1 | UX-00 | Lire TFDev et récupérer les composants existants ; comparaison du binôme, sauvegarde des affectations de pages ; ordre de navigation métier déployé et constaté |
| TF-080-UX-02 | P1 | Binôme / Tarek | 3 | UX-01 | CompactLayout + page dossier à onglets ; code/rôle/état visibles ; lot/cycle hors vue métier ; aucun nouveau champ obligatoire ni changement d'API |
| TF-080-UX-03 | P1 | Binôme / Tarek | 2 | UX-02 | Listes avec code candidat, rôle, état et date ; réservation avec dossier et fuseau ; zéro ambiguïté sur le scénario de démonstration |
| TF-080-UX-04 | P1 | Binôme / Tarek | 4 | UX-01, UX-03 | Accueil standard affecté à TalentFlow ; compteurs définis et recoupés avec listes, pas de données plus larges via utilisateur d'exécution du dashboard |
| TF-080-UX-05 | P1 | Tarek / Binôme | 2 | UX-02 | Actions visibles selon état/permission, Flows existants réutilisés ; refus serveur inchangés ; compte recruteur sans contrôle RH ni contexte privé transmis au chat |
| TF-080-UX-06 | P1 | Binôme / Tarek | 2 | UX-02, UX-05 | Succès/refus/absence/chargement compréhensibles ; Simulation et Tâches générées distincts ; états sans réservation et sans parcours correctement expliqués |
| TF-090-UX-01 | P0 | Les deux / relecture croisée | 3 | UX-01 à 06 | Recette de chaque rôle réellement restreint ; navigation clavier, zoom 200 %, largeur 390/768/1440 ; confirmations et absence de données privées vérifiées ; résultats datés dans test-results.md |
| TF-080-UX-07 | P2 | Tarek / Binôme | 6–10 | UX-06, évaluation standard | Frise LWC seulement si besoin confirmé ; UI API/LDS en priorité, partage et FLS si Apex nécessaire ; six étapes, doublons absents, erreurs et vide gérés ; accessibilité vérifiée |

## Vérification de la maquette et passage à Salesforce

- Contrôles locaux exécutés : structure HTML, cibles de navigation/ARIA et syntaxe JavaScript. Accueil et dossier rendus dans Chrome à 1440 × 1100 et inspectés visuellement. Cela ne prouve pas l'accessibilité complète.
- Capture étroite demandée à 390 × 1000 : sortie tronquée, même après correction des contraintes de largeur. La largeur effective de rendu headless n'a pas été instrumentée ; cette capture n'est pas retenue comme validation responsive. Une recette avec émulation navigateur et mesure du viewport reste NotRun.
- Revue attendue : comparer les deux rôles, ouvrir chaque onglet, tester la fenêtre étroite, clavier et zoom ; consigner uniquement ce qui est observé.
- Réalisation Salesforce : une tâche testable à la fois ; vérifier TFDev, récupérer l'existant, déployer, affecter/activer les pages, puis recetter. Un fichier FlexiPage local ne prouve pas sa disponibilité utilisateur.
- Ne pas modifier les dates ni les états des dossiers pour les faire correspondre aux exemples visuels. Ne pas réinitialiser la démo pour une refonte d'affichage.

Sources de référence consultées dans la proposition : [Lightning App Builder](https://trailhead.salesforce.com/content/learn/modules/lightning_app_builder/lightning_app_builder_intro), [choix des formulaires](https://architect.salesforce.com/docs/architect/decision-guides/guide/build-forms), [visibilité des composants](https://help.salesforce.com/s/articleView?id=sf.lightning_page_components_visibility.htm&language=en_US&type=5), [accessibilité des composants Lightning](https://developer.salesforce.com/docs/platform/lwc/guide/base-components-accessibility.html). Faisabilité exacte, éditions et affectations à vérifier dans TFDev lors de l'implémentation.
