# TalentFlow 360

TalentFlow 360 est un démonstrateur Salesforce de parcours RH interne. Le MVP couvre la préparation d'un dossier pseudonymisé, la préparation et la réservation d'un entretien, une décision humaine distincte, puis un parcours d'intégration de J-7 à J+90.

## État actuel

Le socle métier est déployé dans **TFDev, Developer Edition** : six objets, navigation standard, droits et protection d'approbation. Neuf tests ont réussi et le seed répété conserve six profils, six identités fictives et huit créneaux. Les actions métier sont en validation séparée. Le Flow technique `TF_ConnectionProbe` est déployé et exécuté directement avec succès ; son appel depuis Agentforce reste à prouver.

Le suivi factuel se trouve dans [docs/progress.md](docs/progress.md).

## Périmètre du MVP

- Salesforce Lightning, objets personnalisés, Flow et Apex si nécessaire.
- Agentforce doit appeler une véritable action Salesforce.
- L'agent aide à résumer des preuves déclarées et à préparer l'entretien ; il ne classe pas les candidats et ne décide pas l'embauche.
- La validation d'embauche reste dans un Screen Flow réservé aux RH.
- Le parcours couvre J-7, J0, J+1, J+30, J+60 et J+90.
- Toutes les données de démonstration sont fictives.

Hors périmètre : portail candidat public, backend Spring Boot, React, base externe, OCR/PDF, calendrier externe, WhatsApp, provisioning informatique réel et envoi automatique vers des personnes réelles.

## Prérequis constatés

- Windows et PowerShell
- Git 2.49.0
- Java Temurin 21.0.11 LTS
- Salesforce CLI 2.157.8
- VS Code 1.144.0 avec les extensions Salesforce et Codex

La CLI Salesforce nécessite actuellement une variable `SHELL` temporaire sur ce poste. Voir [docs/setup.md](docs/setup.md).

## Démarrage

```powershell
Set-Location C:\Users\Dell\talentflow360
$env:SHELL = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
sf.cmd --version
sf.cmd org list
```

La sonde est déjà déployée selon les résultats consignés. La prochaine preuve attendue est son appel observable depuis Agentforce Preview. La lecture de TFDev a de nouveau réussi le 7 novembre 2026.

Le calendrier accepté est dans [docs/sprints.md](docs/sprints.md). Consulter la progression pour distinguer les fichiers préparés, les composants déployés et les fonctions testées.

## Documentation

- [Progression](docs/progress.md)
- [Backlog](docs/backlog.md)
- [Installation et manipulations](docs/setup.md)
- [Modèle de données](docs/data-model.md)
- [Décisions](docs/decisions.md)

## Limites actuelles

L'accès au nouveau Builder a été constaté sur les captures utilisateur ; aucune invocation Preview n'est encore prouvée. Les droits minimaux sont testés par Apex, mais l'interface, l'agent et les automatismes du parcours nécessitent leurs propres preuves. Une fonctionnalité ne sera marquée comme terminée qu'après déploiement et test réel.
