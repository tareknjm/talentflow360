# Petite démonstration — point du 7 novembre 2026

Durée : environ cinq minutes. Les données sont fictives. Ne pas réinitialiser le lot avant cette visite : il contient les résultats des essais réels.
Les effectifs ci-dessous sont ceux du checkpoint ; une nouvelle saisie ou le passage quotidien peut les faire évoluer.

**Nouvelle interface déployée :** suivre [l'ouverture de l'espace candidat natif](ui-ux/native-workspace.md). La fiche propose maintenant Vue d'ensemble, Préparation, Entretiens et Intégration. Les captures HTML de la maquette sont distinctes du rendu Salesforce réel.

## 1. Ouvrir l'application

Dans Salesforce, quitter Setup et cliquer sur le lanceur d'applications (les neuf points), rechercher **TalentFlow 360**, puis ouvrir l'application.
Résultat attendu : onglets Dossiers talents, Créneaux d'entretien, Étapes de parcours et Tâches. Les libellés de l'interface Salesforce peuvent rester en anglais ; les libellés métier TalentFlow sont en français.

## 2. Voir le dossier déjà traité

Dans **Dossiers talents**, choisir la vue **Tous les dossiers TalentFlow**, puis repérer **TF-DEMO-001** dans la colonne Code candidat. Ouvrir sa référence TP-… .
Résultat attendu : rôle Ingénierie qualité, état Embauche validée, date d'arrivée, acteur et date de validation en lecture seule. Ces valeurs viennent d'un essai technique réel ; le clic humain du Screen Flow reste à tester avec toi.
Le dossier pseudonymisé est distinct de l'objet Identités candidats. Ne pas ouvrir de chat sur une page d'identité ou de satisfaction.

## 3. Voir les six jalons

Ouvrir **Étapes de parcours** puis **Toutes les étapes TalentFlow**. Le jeu actuel comporte six étapes pour le dossier traité : J−7, J0, J+1, J+30, J+60, J+90.
Résultat attendu après reprise : J−7 et J+1 exécutés par de vraies échéances planifiées ; J+30/J+60/J+90 marqués **Simulation** ; J0 encore ouvert. Exécutée signifie que le traitement a créé ses tâches, pas que toutes les tâches humaines sont accomplies.
Le test J+1 a décalé exprès une échéance synthétique dans le passé, puis attendu un vrai Flow Once. La modification de date seule n'est pas la preuve : Cron et horodatage d'exécution sont consignés dans test-results.md.

## 4. Voir les tâches et l'alerte

Ouvrir **Tâches** et choisir une vue montrant les tâches ouvertes de l'opérateur. Après le passage quotidien observé le 7 novembre, le dossier TF-DEMO-001 dispose de six tâches : trois simulations, une tâche J+1, une tâche J−7 et une alerte de satisfaction.
Les simulations ont un sujet commençant par « Simulation J+… ». L'alerte provient d'une réponse synthétique 1/5 ; une réponse 4/5 n'a pas créé d'alerte supplémentaire.

## 5. Montrer la vraie preuve Agentforce

Les quatre actions métier ont été appelées réellement dans Preview Live Test ; la version 1 est désormais publiée et Active dans TFDev. Les preuves sont dans les fichiers agent-business-*.json du dossier evidence ; le brief du runtime publié est dans [evidence/agent-published-brief.json](evidence/agent-published-brief.json). La sonde initiale reste une preuve historique distincte.
Pour une conversation avec le runtime publié dans le terminal :

```powershell
$env:SHELL = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
sf.cmd agent preview start --api-name TalentFlow_Assistant --use-live-actions --target-org TFDev
sf.cmd agent preview send --api-name TalentFlow_Assistant --session-id <sessionId-retourne> --utterance "Lis le brief de TF-DEMO-003" --target-org TFDev
sf.cmd agent preview end --api-name TalentFlow_Assistant --session-id <sessionId-retourne> --target-org TFDev
```

Remplacer le marqueur de session par la valeur retournée, sans la publier. Pour tester le brouillon local, utiliser --authoring-bundle au lieu de --api-name et conserver --use-live-actions. Ne pas rejouer la commande historique de sonde avec le bundle métier : la configuration de sonde est archivée séparément.

## 6. Prochaine recette humaine dans Lightning

1. Ouvrir le panneau Agentforce dans Lightning et chercher **TalentFlow Assistant** dans le sélecteur d'agents. Résultat attendu : agent accessible grâce au droit TF_AssistantAccess. Visibilité non encore constatée dans le navigateur ; si absent, vérifier Setup → Agentforce Agents → TalentFlow Assistant → Agent Access, sans créer de deuxième agent.
2. Demander « Lis le brief de TF-DEMO-003 ». Résultat attendu : rôle, preuves déclarées et disponibilité, sans identité ni décision RH.
3. Fermer le panneau puis ouvrir **TF-DEMO-002**, désormais Entretien planifié après la réservation réelle du 8 novembre 18:00–18:45 UTC. Cliquer **Valider l'embauche**, choisir une date d'arrivée et confirmer en tant que RH. Résultat attendu : acteur et heure serveur, état Embauche validée et six étapes. Cette validation humaine est séparée du chat.
4. Cliquer **Saisir la satisfaction**, choisir 1/5. Résultat attendu : une tâche RH pour cette nouvelle réponse. Revenir sur la même réponse ne doit pas retraiter son alerte ; une nouvelle saisie crée une nouvelle réponse distincte.
5. Sur une étape J+30 du lot de démo, lancer la simulation et lire l'avertissement. Résultat attendu : vraie tâche synthétique marquée Simulation, sans message externe.

Consigner les résultats réels de ces clics dans test-results.md ; ils restent NotRun jusqu'à cette visite.

## Ce qui reste pour la suite

- Vérifier l'accès Lightning de la version publiée et refaire les conversations en compte restreint.
- Recetter ensemble les boutons « Valider l'embauche », « Saisir la satisfaction » et « Simulation J+… » dans l'interface.
- Réaliser les deux resets sur le jeu réellement présenté ; ils ont déjà été exercés en tests Apex isolés.
- Mesurer les essais manuels/assistés, préparer la vidéo et la démonstration finale.

Le raccordement métier est terminé pour les scénarios de Preview documentés ; la prochaine action est la recette humaine ci-dessus.
