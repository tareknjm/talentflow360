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
sf.cmd project deploy start --manifest .\manifest\package.xml --target-org TFDev --wait 10
```

Résultat constaté : `Succeeded`, 1 composant déployé, 0 erreur. La Tooling API confirme la version active 1.

## 6. État des composants locaux

- `force-app` : sonde technique initiale, puis socle métier déployé le 7 novembre 2026. Les actions métier ajoutées localement suivent une validation séparée : voir progress.md.
- `manifest/package.xml` : manifeste historique de la sonde ; ne constitue pas encore l'inventaire complet du socle.
- Dépendances npm : non installées ; elles ne sont pas nécessaires au diagnostic actuel.
- Dépôt distant Git : non configuré.

## 7. Preuve Agentforce à réaliser dans l'interface

1. Ouvrir Salesforce dans le navigateur puis Setup (roue dentée). Ne pas créer de projet dans Agentforce Vibes : c'est un éditeur, distinct du Builder.
2. Rechercher « Agentforce Agents » ou « Agents », ouvrir le Builder disponible et constater le type d'agent ainsi que son utilisateur d'exécution. Résultat attendu : l'interface de configuration est accessible ; noter le refus exact sinon.
3. Créer un agent de test limité à la sonde, sans outil générique de recherche ou modification. Résultat attendu : aucun accès métier ajouté.
4. Ajouter une action de référence Flow, choisir `TF_ConnectionProbe`. Entrée texte `candidateCode`, sortie texte `safeSummary`. Résultat attendu : l'action référence le Flow actif existant, sans redéploiement inutile.
5. Donner l'instruction : « Pour tester la connexion, appeler la sonde avec le code synthétique fourni et restituer sa sortie. Ne pas inventer le résultat. » Résultat attendu : la sonde est la seule action du domaine de diagnostic.
6. Dans Preview en exécution réelle, demander « Teste la connexion avec TF-PROBE-001 ». Résultat attendu : la trace montre l'appel, le code en entrée et la sortie synthétique exacte du Flow. Une réponse textuelle seule ou un mode de simulation d'action ne suffit pas.
7. Consigner date, version de l'agent, contexte effectif, résultat et preuve expurgée dans test-results.md. Ne fournir ni capture de jeton ni identité réelle.

Vérification CLI du 7 novembre : la liste Metadata API `Bot` retourne zéro composant. Cela ne prouve pas à elle seule l'absence de tous les types d'agents possibles dans cette version. Aucune configuration Agentforce n'est annoncée comme terminée.

## 8. Accès à l'application après déploiement du socle

1. Confirmer le résultat du déploiement dans test-results.md. Résultat attendu : Succeeded, et non seulement un dry-run réussi.
2. Pour le compte de démonstration, affecter TF_Recruiter. Ajouter TF_HiringApprover seulement au RH, et TF_DemoAdmin seulement au responsable du jeu synthétique. Résultat attendu : permissions additives connues, aucune affectation à un compte de production.
3. Dans le lanceur d'applications, rechercher TalentFlow 360. Résultat attendu : dossiers, créneaux et étapes visibles selon les droits.
4. Dans Object Manager, ouvrir chaque objet TalentFlow puis Page Layouts / Page Layout Assignment. Affecter le layout TalentFlow aux profils de test concernés, après lecture de leurs affectations existantes. Résultat attendu : champs d'approbation et références internes en lecture seule. La présence d'un fichier layout ne prouve pas son affectation.
5. Depuis un dossier, vérifier la lecture sans ouvrir de chat sur une page d'identité ou de satisfaction. Résultat attendu : le contexte de l'agent ne contient aucune donnée interdite.

## 9. Seed et reset synthétiques

1. Revalider la cible TFDev par une lecture Organization et confirmer Developer Edition. Résultat attendu : org de développement attendue, aucune production.
2. Affecter TF_DemoAdmin au responsable de démonstration si nécessaire. Résultat attendu : custom permission TF_DemoTools active.
3. Exécuter `sf.cmd apex run --file scripts/apex/seedDemo.apex --target-org TFDev`. Résultat attendu : six profils, six identités fictives et huit créneaux dans TF360-DEMO-V1. Aucun email émis.
4. Répéter le seed. Résultat attendu : mêmes effectifs ; aucun écrasement des réservations ou approbations déjà réalisées.
5. Pour réinitialiser uniquement la démo, exécuter `sf.cmd apex run --file scripts/apex/resetDemo.apex --target-org TFDev`. Résultat attendu : seul le lot exact est réinitialisé. Une dépendance hors lot fait refuser le reset avant suppression. Cette opération est destructive dans le lot de démonstration.
6. Vérifier les effectifs et un témoin hors lot ; répéter une seconde fois pour la recette. Résultat attendu : témoin préservé, pas de message. Les tests unitaires isolés ne remplacent pas ces observations sur le jeu réellement présenté.
