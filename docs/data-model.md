# Modèle de données — brouillon initial

Statut : **Spécification MVP figée / métadonnées en préparation / tests org à exécuter**

Ce modèle formalise le MVP avant création des métadonnées. Les noms API restent en anglais ; les libellés Lightning seront en français. Les données de démonstration seront exclusivement fictives.

## Principes

- L'identité est séparée du profil manipulable par l'agent.
- `CandidateCode__c` sert au rapprochement côté serveur autorisé ; aucune relation navigable vers l'identité n'est exposée à l'agent.
- Les preuves décrivent leur provenance et ne deviennent pas un score de mérite.
- Une embauche exige une validation humaine distincte.
- Une étape planifiée, un message préparé et un message réellement envoyé sont trois états différents.

## CandidateIdentity__c — Identité candidat

Visible uniquement pour les RH autorisés.

| Champ | Type proposé | Contraintes |
|---|---|---|
| `Name` | Auto Number `CID-{0000}` | Standard |
| `CandidateCode__c` | Text(30) | Required, Unique, External ID |
| `FullName__c` | Text(120) | Required |
| `Email__c` | Email | Required, adresse fictive pour la démo |

## TalentProfile__c — Dossier talent

| Champ | Type proposé | Contraintes |
|---|---|---|
| `Name` | Auto Number `TP-{0000}` | Standard |
| `CandidateCode__c` | Text(30) | Required, Unique, External ID |
| `Role__c` | Picklist | Required ; `JavaBackendDeveloper`, `QAEngineer` |
| `JavaEvidence__c` | Picklist | Required, défaut `NotProvided` |
| `SpringEvidence__c` | Picklist | Required, défaut `NotProvided` |
| `Availability__c` | Date | Facultatif tant que l'information manque |
| `Status__c` | Picklist | Required, défaut `Draft` |
| `HumanApproved__c` | Checkbox | Défaut `false` |
| `ApprovedBy__c` | Lookup(User) | Renseigné par le parcours RH autorisé |
| `ApprovedAt__c` | DateTime | Renseigné par le parcours RH autorisé |
| `StartDate__c` | Date | Requis pour passer à `Hired` |
| `OnboardingCycle__c` | Text(40) | Clé stable du cycle d'intégration |

Valeurs de preuve : `NotProvided`, `DeclaredProject`, `RecordedAssessment`.

Valeurs de statut : `Draft`, `ReadyForReview`, `InterviewRequested`, `InterviewScheduled`, `Hired`.

## InterviewSlot__c — Créneau d'entretien

| Champ | Type proposé | Contraintes |
|---|---|---|
| `Name` | Auto Number `IS-{0000}` | Standard |
| `Start__c` | DateTime | Required |
| `End__c` | DateTime | Required, strictement après `Start__c` |
| `Recruiter__c` | Lookup(User) | Obligatoire via règle de validation ; relation User techniquement facultative |
| `Status__c` | Picklist | `Available`, `Reserved`, `Cancelled` |
| `TalentProfile__c` | Lookup(TalentProfile__c) | Vide tant que le créneau est libre |
| `ReservationKey__c` | Text(80) | Unique ; clé d'idempotence |

## JourneyStep__c — Étape de parcours

| Champ | Type proposé | Contraintes |
|---|---|---|
| `Name` | Auto Number `JS-{0000}` | Standard |
| `TalentProfile__c` | Lookup(TalentProfile__c) | Required |
| `Stage__c` | Picklist | Required |
| `Status__c` | Picklist | Required, défaut `Pending` |
| `DispatchStatus__c` | Picklist | Required, défaut `NotApplicable` |
| `DueDate__c` | Date | Required |
| `AssignedTo__c` | Lookup(User) | Facultatif selon l'étape |
| `StepKey__c` | Text(100) | Required, Unique, External ID |
| `MessagePreview__c` | Long Text Area(4000) | Contenu fictif préparé, sans secret |

Étapes : `PreArrival`, `Arrival`, `Day1`, `Day30`, `Day60`, `Day90`.

États : `Pending`, `Completed`, `Cancelled`, `Failed`.

États d'envoi : `NotApplicable`, `Prepared`, `Sent`, `Failed`. `Sent` ne sera utilisé qu'après un véritable envoi confirmé.

## PulseResponse__c — Satisfaction

| Champ | Type proposé | Contraintes |
|---|---|---|
| `Name` | Auto Number `PR-{0000}` | Standard |
| `TalentProfile__c` | Lookup(TalentProfile__c) | Required |
| `Score__c` | Number(2,1) + validation | Entier de 1 à 5 ; décimales représentables refusées avant validation métier |
| `SubmittedAt__c` | DateTime | Required |

Une note inférieure ou égale à 2 doit créer au maximum une tâche d'alerte RH pour cette réponse. Le mécanisme exact d'idempotence sera arrêté avec le Flow de phase 7.

## AgentAudit__c — Journal d'action

| Champ | Type proposé | Contraintes |
|---|---|---|
| `Name` | Auto Number `AA-{0000}` | Standard |
| `ProfileCode__c` | Text(30) | Code pseudonymisé uniquement |
| `ActionName__c` | Text(80) | Required |
| `Result__c` | Text(40) | Code de retour stable |
| `ReasonCode__c` | Text(80) | Motif technique ou métier non sensible |
| `CorrelationId__c` | Text(80) | Corrélation sans prompt complet |
| `Actor__c` | Lookup(User) | Acteur effectif lorsque disponible |
| `OccurredAt__c` | DateTime | Required |

## Validations prévues

1. `InterviewSlot__c` : refuser `End__c <= Start__c`.
2. `PulseResponse__c` : refuser un score hors de 1 à 5 ou non entier.
3. `TalentProfile__c` : refuser `Status__c = Hired` si `HumanApproved__c` est faux, ou si `ApprovedBy__c`, `ApprovedAt__c` ou `StartDate__c` manque.
4. La permission de validation RH et les contrôles serveur restent obligatoires ; une formule de validation ne constitue pas à elle seule la frontière de sécurité.

## Décisions d'implémentation — 7 novembre 2026

- Les six objets ont un partage privé. Les activités sont activées pour TalentProfile__c.
- Rôles : `JavaBackendDeveloper` (Développement Java backend), `QAEngineer` (Ingénierie qualité).
- Les six objets portent `DemoBatch__c` Text(40), réservé au repérage strict des données synthétiques ; aucune sortie agent ne le contient. Le reset n'utilise jamais un simple préfixe de nom pour supprimer des données.
- PulseResponse__c porte `AlertTaskId__c` Text(18), non modifiable par les écrans, pour repérer la tâche créée dans la même transaction. Pas de note ni d'alerte dans les sorties agent.
- InterviewSlot__c porte `DemoKey__c` Text(80), unique/external ID pour le seed répétable.
- Les champs d'approbation sont protégés côté serveur ; le service dédié enregistrera acteur/date. Une formule n'est pas considérée comme une preuve d'intervention humaine.
- Les étapes ouvertes sont replanifiées ; les étapes exécutées restent historiques. Les dates échues seront traitées par le prochain passage quotidien.
- Le contexte d'exécution réel de l'agent reste à constater avant exposition des actions. Aucun permission set ne retire les droits déjà accordés ailleurs.
- Écart au brouillon : Score__c conserve une décimale technique et une validation MOD, afin de refuser 1,5 au lieu de l'arrondir silencieusement. Le futur Screen Flow et son service n'accepteront que les cinq entiers ; les arrondis de précision de la plateforme ne constituent pas une validation de saisie.
