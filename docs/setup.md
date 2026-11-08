# Installation et manipulations Salesforce

Dernière vérification locale : 7 novembre 2026.

## 1. Ouvrir le bon projet

Dans le terminal PowerShell intégré à VS Code :

```powershell
Set-Location C:\Users\Dell\talentflow360
Test-Path .\sfdx-project.json
```

Résultat attendu : `True`.

## 2. Contournement temporaire de la CLI Salesforce

Sur ce poste, `sf.cmd` est installé mais échoue avec `uv_os_get_passwd` et `ENOMEM` lorsque la variable `SHELL` est absente. Pour le terminal courant uniquement :

```powershell
$env:SHELL = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
sf.cmd --version
```

Résultat constaté : `@salesforce/cli/2.157.8 win32-x64 node-v26.13.0`.

Cette variable n'est pas rendue permanente à ce stade. Il faudra réexécuter la première ligne dans chaque nouveau terminal tant que la cause n'est pas corrigée par la CLI ou l'environnement.

## 3. Reconnecter TFDev — réalisé le 7 novembre 2026

1. Dans le même terminal, exécuter :

   ```powershell
   $env:SHELL = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
   sf.cmd org login web --alias TFDev --set-default --browser chrome
   ```

2. Chrome s'ouvre sur la page officielle Salesforce.
3. Se connecter avec le **username de la Developer Edition**, qui peut être différent de l'adresse de contact, du compte Trailhead ou du compte ChatGPT.
4. Autoriser Salesforce CLI si la page le demande.
5. Revenir au terminal après le message de réussite.

Ne jamais copier le mot de passe, un code de vérification ou un jeton dans le dépôt ou la conversation. En cas de refus des identifiants, utiliser l'email d'activation ou la récupération de mot de passe Salesforce.

## 4. Vérifier la connexion sans afficher de jeton — réussi

Après la connexion :

```powershell
sf.cmd org list
sf.cmd data query --query "SELECT Id, OrganizationType, IsSandbox FROM Organization LIMIT 1" --target-org TFDev
```

Résultat constaté : la requête retourne exactement une `Developer Edition`, non sandbox, sur l'instance `CAN96`. Ne pas utiliser une commande qui affiche les détails d'authentification ou un access token.

Avant tout déploiement, confirmer que cette org est bien l'org de développement prévue et non une production inconnue.

## 5. Contrôles Agentforce après connexion

Le Flow est maintenant déployé et actif. Les licences Agentforce Builder et Agentforce par défaut sont actives, et l'utilisateur connecté possède les affectations Builder nécessaires. Les points d'interface restent à vérifier :

1. Ouvrir Setup dans l'org de développement vérifiée.
2. Rechercher les réglages Einstein et Agentforce disponibles dans cette édition.
3. Confirmer l'accès à Agentforce Builder dans l'interface sans supposer le nom exact des menus.
4. Noter le type d'agent disponible et le contexte d'exécution.
5. Déployer le Flow local `TF_ConnectionProbe`, puis créer une action Agentforce qui le référence.

Résultat attendu de la phase 1 : une conversation Preview déclenche réellement l'action et reçoit `safeSummary`. Ce premier Flow est une sonde technique, pas une fonction RH terminée.

Commande utilisée pour le premier déploiement :

```powershell
sf.cmd project deploy start --manifest .\manifest\probe.xml --target-org TFDev --wait 10
```

Résultat constaté : `Succeeded`, 1 composant déployé, 0 erreur. La Tooling API confirme la version active 1.

## 6. État des composants locaux

- `force-app` : sonde technique initiale, puis socle métier déployé le 7 novembre 2026. Les actions métier ajoutées localement suivent une validation séparée : voir progress.md.
- `manifest/package.xml` : inventaire explicite du socle Salesforce. Le manifeste initial de la sonde est conservé dans `manifest/probe.xml`. Le bundle Agentforce est compilé/testé dans un workflow distinct et n'est pas publié par ce manifeste.
- Dépendances npm : non installées ; elles ne sont pas nécessaires au diagnostic actuel.
- Destination GitHub de ce checkpoint : https://github.com/tareknjm/talentflow360 ; le résultat du push est consigné dans progress.md.

## 7. Procédure Agentforce manuelle de secours

La preuve de sonde a depuis été obtenue dans Preview CLI Live Test : voir docs/evidence/agent-probe.json. Pendant la pause de démonstration, ne pas créer un deuxième agent : le bundle Employee local TalentFlow_Assistant est le point de reprise. Les étapes ci-dessous servent à une vérification manuelle ultérieure, pas à annoncer une publication déjà réalisée.

1. Ouvrir Salesforce dans le navigateur puis Setup (roue dentée). Ne pas créer de projet dans Agentforce Vibes : c'est un éditeur, distinct du Builder.
2. Rechercher « Agentforce Agents » ou « Agents », ouvrir le Builder disponible et constater le type d'agent ainsi que son utilisateur d'exécution. Résultat attendu : l'interface de configuration est accessible ; noter le refus exact sinon.
3. Créer un agent de test limité à la sonde, sans outil générique de recherche ou modification. Résultat attendu : aucun accès métier ajouté.
4. Ajouter une action de référence Flow, choisir `TF_ConnectionProbe`. Entrée texte `candidateCode`, sortie texte `safeSummary`. Résultat attendu : l'action référence le Flow actif existant, sans redéploiement inutile.
5. Donner l'instruction : « Pour tester la connexion, appeler la sonde avec le code synthétique fourni et restituer sa sortie. Ne pas inventer le résultat. » Résultat attendu : la sonde est la seule action du domaine de diagnostic.
6. Dans Preview en exécution réelle, demander « Teste la connexion avec TF-PROBE-001 ». Résultat attendu : la trace montre l'appel, le code en entrée et la sortie synthétique exacte du Flow. Une réponse textuelle seule ou un mode de simulation d'action ne suffit pas.
7. Consigner date, version de l'agent, contexte effectif, résultat et preuve expurgée dans test-results.md. Ne fournir ni capture de jeton ni identité réelle.

En API 68, l'inventaire Agentforce utilise AiAgentDefinition et AiAuthoringBundle ; Bot ne suffit pas. Leur absence a été contrôlée avant génération du bundle local. Le Preview réel a ensuite réussi ; la publication/activation Lightning reste à faire.

## 8. Accès à l'application après déploiement du socle

1. Confirmer le résultat du déploiement dans test-results.md. Résultat attendu : Succeeded, et non seulement un dry-run réussi.
2. Pour le compte de démonstration, affecter TF_Recruiter. Ajouter TF_HiringApprover seulement au RH, et TF_DemoAdmin seulement au responsable du jeu synthétique. Résultat attendu : permissions additives connues, aucune affectation à un compte de production.
3. Dans le lanceur d'applications, rechercher TalentFlow 360. Résultat attendu : dossiers, créneaux et étapes visibles selon les droits.
4. Dans Object Manager, ouvrir chaque objet TalentFlow puis Page Layouts / Page Layout Assignment. Affecter le layout TalentFlow aux profils de test concernés, après lecture de leurs affectations existantes. Résultat attendu : champs d'approbation et références internes en lecture seule. La présence d'un fichier layout ne prouve pas son affectation.
5. Depuis un dossier, vérifier la lecture sans ouvrir de chat sur une page d'identité ou de satisfaction. Résultat attendu : le contexte de l'agent ne contient aucune donnée interdite.

Au checkpoint : les six affectations Admin ont été sauvegardées et contrôlées ; les boutons standard et listes sont déployés. Les profils d'autres utilisateurs doivent être vérifiés séparément. Pour la visite actuelle, suivre mini-demo.md sans reset préalable.

## 9. Rejouer la sonde par la CLI

**Historique du checkpoint sonde uniquement.** Le bundle courant a depuis été remplacé par la configuration métier publiée. Pour les commandes courantes, suivre la section 11 et mini-demo.md ; ne pas attendre connection_probe de l'assistant métier.

1. Dans le projet et le terminal configurés, lancer `sf.cmd agent validate authoring-bundle --api-name TalentFlow_Assistant --target-org TFDev`. Résultat attendu : success=true. La locale Agent Script est fr, pas fr_FR.
2. Lancer `sf.cmd agent preview start --authoring-bundle TalentFlow_Assistant --use-live-actions --target-org TFDev`. Résultat attendu : session ouverte avec actions réelles. Le marqueur INVALID reste technique et ne désigne aucun utilisateur à créer ; Employee utilise le contexte connecté.
3. Envoyer `sf.cmd agent preview send --authoring-bundle TalentFlow_Assistant --utterance "Teste la connexion avec TF-PROBE-001" --target-org TFDev`. Résultat attendu : appel connection_probe et safeSummary provenant du Flow réel. En interactif, lancer `sf.cmd agent preview --authoring-bundle TalentFlow_Assistant --use-live-actions --target-org TFDev` ; sans le flag, les actions sont simulées.
4. Vérifier la trace FunctionStep et mockMode=Live Test dans le répertoire de session .sfdx/agents/TalentFlow_Assistant. Résultat attendu : entrée synthétique et sortie exacte ; ne jamais exporter les prompts ou le contexte complet. export_agent_evidence.py extrait uniquement l'action autorisée.
5. Fermer la session avec `sf.cmd agent preview end --authoring-bundle TalentFlow_Assistant --target-org TFDev`. Résultat attendu : fin du seul Preview sélectionné ; ne ferme pas les sessions d'un autre utilisateur.

## 10. Seed et reset synthétiques

1. Revalider la cible TFDev par une lecture Organization et confirmer Developer Edition. Résultat attendu : org de développement attendue, aucune production.
2. Affecter TF_DemoAdmin au responsable de démonstration si nécessaire. Résultat attendu : custom permission TF_DemoTools active.
3. Exécuter `sf.cmd apex run --file scripts/apex/seedDemo.apex --target-org TFDev`. Résultat attendu : six profils, six identités fictives et huit créneaux dans TF360-DEMO-V1. Aucun email émis.
4. Répéter le seed. Résultat attendu : mêmes effectifs ; aucun écrasement des réservations ou approbations déjà réalisées.
5. Pour réinitialiser uniquement la démo, exécuter `sf.cmd apex run --file scripts/apex/resetDemo.apex --target-org TFDev`. Résultat attendu : seul le lot exact est réinitialisé. Une dépendance hors lot fait refuser le reset avant suppression. Cette opération est destructive dans le lot de démonstration.
6. Vérifier les effectifs et un témoin hors lot ; répéter une seconde fois pour la recette. Résultat attendu : témoin préservé, pas de message. Les tests unitaires isolés ne remplacent pas ces observations sur le jeu réellement présenté.

## 11. Publication métier et recette Lightning

Le 7 novembre : publication réussie, 16 éléments récupérés et 3 déployés ; version 1 Active relue. La récupération automatique a reformaté quatre classes Apex, sans changement fonctionnel ; ces différences cosmétiques ont été retirées après comparaison. Le backend garde API 68.

1. Avant publication, relire Organization et comparer l'inventaire AiAgentDefinition/AiAuthoringBundle TalentFlow aux modifications du binôme. Résultat attendu pour la première publication : aucun composant TalentFlow existant ; TFDev Developer Edition CAN96.
2. Valider le brouillon et le tester avec `agent preview start --authoring-bundle TalentFlow_Assistant --use-live-actions --target-org TFDev`. Résultat attendu : quatre actions réelles, sorties minimisées, confirmation avant mutation et refus documentés. Fermer chaque session sélectionnée avec son session-id.
3. Exécuter `sf.cmd agent publish authoring-bundle --api-name TalentFlow_Assistant --target-org TFDev --api-version 68.0`. Résultat attendu : success=true ; métadonnées de la version générées et récupérées. Cette publication crée une version, elle ne vaut pas activation. Opération déjà réalisée pour v1 ; ne pas la répéter sans changement voulu.
4. Activer la version précise avec `sf.cmd agent activate --api-name TalentFlow_Assistant --version 1 --target-org TFDev --api-version 68.0`. Résultat attendu : version 1 Active, relue via AiAgentDefinitionVersion. Opération déjà réalisée dans TFDev.
5. Déployer `manifest/agent-access.xml` après publication, puis affecter **TF_AssistantAccess** au seul utilisateur de recette autorisé. Résultat attendu : droit d'accès au seul assistant, sans nouveaux droits objet/RH. Déploiement déjà réussi : 0AfgK00000Z8uGzSAJ ; une affectation à l'opérateur courant confirmée. Le manifeste backend exclut ce droit pour ne pas dépendre d'un agent absent lors de l'installation initiale.
6. Dans Lightning, ouvrir le panneau Agentforce et son sélecteur. Résultat attendu : TalentFlow Assistant visible ; vérifier au besoin Setup → Agentforce Agents → TalentFlow Assistant → Agent Access. La visibilité réelle reste NotRun, malgré le statut Active et le droit affecté. Aucun changement global Einstein/Agentforce n'a été effectué.
7. Demander le brief de TF-DEMO-003, puis fermer le panneau et recetter séparément les boutons RH sur TF-DEMO-002 selon mini-demo.md. Résultat attendu : action réelle dans le chat, validation humaine dans le Screen Flow ; aucune validation RH exposée à l'agent.
8. Refaire les conversations sous un compte de recrutement restreint ayant accès au seul périmètre prévu. Résultat attendu : refus de dossier inaccessible et aucun accès RH induit. Statut actuel NotRun ; les tests Apex isolés ne remplacent pas cet essai.

Sources : [publication Agentforce DX](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-nga-publish.html), [accès Employee Agent](https://help.salesforce.com/s/articleView?id=ai.agent_manage_aea_access.htm&language=en_US&type=5), [connexion Lightning](https://help.salesforce.com/s/articleView?id=ai.agent_deploy_emp_lex.htm&language=en_US&type=5). Le champ surfacesEnabled=false relu dans la version n'est pas employé comme preuve de visibilité ou d'indisponibilité du panneau ; seul l'essai utilisateur pourra conclure ici.

## 12. Nouvelle fiche candidat native

La livraison initiale ci-dessous est complétée par la section 13 : Mon espace et actions dynamiques du 8 novembre.

Premier incrément déployé le 7 novembre : voir [native-workspace.md](ui-ux/native-workspace.md) pour fichiers, preuves, sauvegardes et retour à l'affichage précédent.

1. Rouvrir TalentFlow 360 depuis le lanceur puis actualiser. Résultat attendu : navigation Dossiers talents, Créneaux d'entretien, Étapes de parcours, Tâches ; une personnalisation utilisateur peut conserver un ordre différent.
2. Ouvrir TF-DEMO-003 depuis Tous les dossiers TalentFlow. Résultat attendu : nouvelle page à quatre onglets et synthèse code/rôle/état/disponibilité. Ne pas modifier le dossier pour le faire correspondre à la maquette.
3. Si l'ancienne page reste visible, ouvrir Object Manager → Dossier talent → Lightning Record Pages, puis TF_TalentWorkspace → Activation ; vérifier l'affectation ordinateur à TalentFlow 360 et les éventuelles affectations plus spécifiques. Résultat attendu : l'override d'application est celui relu dans la preuve ; ne pas changer le défaut de toute l'org sans vérifier les autres usages.
4. Vérifier les onglets Entretiens et Intégration sur les dossiers existants. Résultat attendu : uniquement les listes du dossier courant, sans identité/satisfaction/approbation dans les champs de page ; aucune confusion Simulation/travail humain terminé.
5. Refaire les contrôles avec compte recruteur restreint, clavier et zoom 200 %. Résultat attendu : droits objet/champ respectés et aucun contrôle RH induit. Consigner les observations dans test-results.md ; ces essais restent NotRun pour le moment.

## 13. Accueil guidé et actions du 8 novembre

1. Vérifier TFDev, récupérer/comparer les métadonnées du binôme, puis utiliser `python scripts/python/stage_guided_workspace.py` pour préparer les cinq composants UI. Résultat attendu : aucun objet métier, champ, Apex ou Flow dans le staging.
2. Valider à blanc puis déployer ce répertoire avec project deploy start --source-dir test-results/ux-guided-deploy --target-org TFDev --api-version 68.0, en conservant les niveaux de test adaptés aux seuls changements UI. Résultat attendu : Succeeded ; opération déjà réalisée pour ce checkpoint, ne pas redéployer par réflexe si une personnalisation d'utilisateur diffère.
3. Affecter TF_WorkspaceAccess aux utilisateurs de recette autorisés, en complément de leurs droits métier. Résultat attendu : seul l'accès à l'onglet Mon espace est ajouté. Affectation à l'opérateur déjà confirmée ; pas d'affectation globale à tous les utilisateurs.
4. Rouvrir TalentFlow 360 depuis le lanceur ; si nécessaire examiner la personnalisation de navigation. Résultat attendu : Mon espace disponible, trois onglets alimentés par les vues existantes, aucune donnée fictive de maquette.
5. Ouvrir un dossier Hired existant puis un dossier ReadyForReview. Résultat attendu : validation absente sur les deux, satisfaction proposée sur Hired seulement, aide correspondante. Modifier reste disponible selon les droits afin de conserver la replanification date/rôle.
6. Pour InterviewScheduled, comparer un RH autorisé et un recruteur restreint. Résultat attendu : validation seulement pour le RH, et refus serveur toujours actif en cas d'appel non autorisé. Ne pas modifier les états de démo pour simuler une preuve.
7. Vérifier le conteneur Intégration en mode amélioré et son absence attendue de New. Résultat attendu à constater visuellement ; ne pas assimiler showActionBar=false à une restriction de sécurité. Ne pas retirer les permissions globales de démo pour cacher un bouton.
8. Consigner les résultats observés. Les captures de l'ancienne fiche ne valident pas ces nouvelles règles. Pour revenir en arrière, comparer les sauvegardes ux-guided-baseline aux changements ultérieurs, restaurer la page et l'application puis retirer l'accès au nouvel onglet si nécessaire, sans supprimer de données.
