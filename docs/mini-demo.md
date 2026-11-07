# Petite démonstration — point du 7 novembre 2026

Durée : environ cinq minutes. Les données sont fictives. Ne pas réinitialiser le lot avant cette visite : il contient les résultats des essais réels.

## 1. Ouvrir l'application

Dans Salesforce, quitter Setup et cliquer sur le lanceur d'applications (les neuf points), rechercher **TalentFlow 360**, puis ouvrir l'application.
Résultat attendu : onglets Dossiers talents, Créneaux d'entretien, Étapes de parcours et Tâches. Les libellés de l'interface Salesforce peuvent rester en anglais ; les libellés métier TalentFlow sont en français.

## 2. Voir le dossier déjà traité

Dans **Dossiers talents**, choisir la vue **Tous les dossiers TalentFlow**, puis repérer **TF-DEMO-001** dans la colonne Code candidat. Ouvrir sa référence TP-… .
Résultat attendu : rôle Ingénierie qualité, état Embauche validée, date d'arrivée, acteur et date de validation en lecture seule. Ces valeurs viennent d'un essai technique réel ; le clic humain du Screen Flow reste à tester avec toi.
Le dossier pseudonymisé est distinct de l'objet Identités candidats. Ne pas ouvrir de chat sur une page d'identité ou de satisfaction.

## 3. Voir les six jalons

Ouvrir **Étapes de parcours** puis **Toutes les étapes TalentFlow**. Le jeu actuel comporte six étapes pour le dossier traité : J−7, J0, J+1, J+30, J+60, J+90.
Résultat attendu : J+1 exécuté par une vraie échéance planifiée ; J+30/J+60/J+90 marqués **Simulation** ; les autres étapes encore ouvertes. Exécutée signifie que le traitement a créé ses tâches, pas que toutes les tâches humaines sont accomplies.
Le test J+1 a décalé exprès une échéance synthétique dans le passé, puis attendu un vrai Flow Once. La modification de date seule n'est pas la preuve : Cron et horodatage d'exécution sont consignés dans test-results.md.

## 4. Voir les tâches et l'alerte

Ouvrir **Tâches** et choisir une vue montrant les tâches ouvertes de l'opérateur. Avant de nouvelles manipulations, le dossier TF-DEMO-001 dispose de cinq tâches : trois simulations, une tâche J+1 et une alerte de satisfaction.
Les simulations ont un sujet commençant par « Simulation J+… ». L'alerte provient d'une réponse synthétique 1/5 ; une réponse 4/5 n'a pas créé d'alerte supplémentaire.

## 5. Montrer la vraie preuve Agentforce

L'agent est pour l'instant une **sonde de diagnostic en Preview CLI**, pas un assistant métier publié dans Lightning. La trace expurgée se trouve dans [evidence/agent-probe.json](evidence/agent-probe.json) : mode Live Test, action connection_probe, code TF-PROBE-001 et sortie réelle du Flow.
Pour rejouer le Preview dans le terminal :

```powershell
$env:SHELL = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
sf.cmd agent preview start --authoring-bundle TalentFlow_Assistant --use-live-actions --target-org TFDev
sf.cmd agent preview send --authoring-bundle TalentFlow_Assistant --utterance "Teste la connexion avec TF-PROBE-001" --target-org TFDev
```

Si plusieurs sessions sont ouvertes, utiliser le Preview interactif `sf.cmd agent preview --authoring-bundle TalentFlow_Assistant --use-live-actions --target-org TFDev`. Le flag --use-live-actions est nécessaire : sans lui ce Preview interactif simule les actions. Les détails des options sont disponibles avec --help.

## Ce qui reste pour la suite

- Relier les quatre actions métier à l'agent, tester les refus et la confirmation dans les conversations, puis publier/activer l'assistant.
- Recetter ensemble les boutons « Valider l'embauche », « Saisir la satisfaction » et « Simulation J+… » dans l'interface.
- Réaliser les deux resets sur le jeu réellement présenté ; ils ont déjà été exercés en tests Apex isolés.
- Mesurer les essais manuels/assistés, préparer la vidéo et la démonstration finale.

La première action de reprise sera le raccordement métier Agentforce ; aucune nouvelle fonction n'est lancée pendant cette pause de démonstration.
