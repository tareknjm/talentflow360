# TalentFlow 360

TalentFlow 360 est un démonstrateur Salesforce de parcours RH interne. Le MVP couvre la préparation d'un dossier pseudonymisé, la préparation et la réservation d'un entretien, une décision humaine distincte, puis un parcours d'intégration de J-7 à J+90.

## État actuel

**Point de démonstration du 7 novembre 2026 — développement en pause à la demande de l'utilisateur.**

Le socle et les quatre actions métier sont déployés dans **TFDev, Developer Edition**. Le parcours J−7 à J+90, la replanification et l'alerte de satisfaction ont été exécutés sur données fictives. La dernière suite complète compte **18 tests Apex réussis**, puis **5 tests ciblés réussis** après ajout de l'indicateur de simulation. La réservation a aussi été vérifiée par deux transactions réellement concurrentes et une vraie échéance Flow a été observée.

**Agentforce a réellement appelé la sonde TF_ConnectionProbe dans un Preview Live Test.** Le bundle Employee reste local : il n'est pas encore publié/activé dans Lightning, et ses quatre actions métier ne sont pas encore raccordées.

Commencer par la [petite démonstration guidée](docs/mini-demo.md). Les [résultats réels](docs/test-results.md) distinguent les tests réussis, échoués et non exécutés.

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

L'application se trouve dans le lanceur Salesforce sous **TalentFlow 360**. Le jeu actuel contient six profils, six identités fictives et huit créneaux ; TF-DEMO-001 porte les résultats du parcours testé. Le seed est répétable et n'écrase pas les essais en cours.

`manifest/package.xml` inventorie le socle Salesforce ; `manifest/probe.xml` conserve la sonde initiale. La configuration Agentforce suit un workflow de compilation/Preview puis publication distinct. Une installation complète sur org neuve n'a pas été testée.

Le calendrier accepté est dans [docs/sprints.md](docs/sprints.md). Consulter la progression pour distinguer les fichiers préparés, les composants déployés et les fonctions testées.

## Documentation

- [Progression](docs/progress.md)
- [Backlog](docs/backlog.md)
- [Installation et manipulations](docs/setup.md)
- [Modèle de données](docs/data-model.md)
- [Décisions](docs/decisions.md)
- [Démo de cinq minutes](docs/mini-demo.md)
- [Contrats et preuve Agentforce](docs/agent-actions.md)
- [Sprints](docs/sprints.md)

## Limites actuelles

Le Preview de diagnostic est prouvé, mais les conversations métier et le canal Lightning restent à réaliser. Les écrans sont actifs et les layouts Admin sont affectés ; leurs clics humains restent à recetter. Les deux resets sur jeu réel, les mesures de valeur, la vidéo et la reconstruction sur org neuve ne sont pas encore validés. Aucun gain métier ni conformité n'est revendiqué.
