# Matrice d'accès — état initial

7 novembre 2026. Les permission sets sont additifs ; les droits réels du profil, des autres permission sets, des groupes et du partage doivent être testés. Leur simple déploiement ne prouve pas la restriction effective.

| Ensemble | Usage | Données | Écriture | Limite |
|---|---|---|---|---|
| TF_Recruiter | Recruteur interne | Profils, créneaux, étapes, satisfaction | Dossier courant, créneaux et création de satisfaction | Aucune identité ou approbation directe |
| TF_AgentAccess | Base minimale des actions | Champs minimisés du profil, créneaux et états d'étapes | État d'entretien et réservation | Pas d'identité, satisfaction, approbation ou message de parcours |
| TF_HiringApprover | RH autorisé, en complément du recrutement | Identités, profils, satisfaction, étapes | Identités et validation via service dédié | Custom permission TF_ApproveHiring ; ne pas exposer le service à l'agent |
| TF_DemoAdmin | Outils restreints du démonstrateur | Six objets | Gestion du lot synthétique | Pas de contournement de l'approbation, pas de partage global accordé |

## Contrôles serveur

- Les six objets sont privés ; aucun ModifyAllRecords/ViewAllRecords n'est ajouté.
- Les champs universellement obligatoires suivent les règles Salesforce ; les autres ont des permissions de champ explicites.
- TF_ProfileGuard refuse les insertions ou modifications d'approbation, de cycle et les entrées/sorties de Hired hors service RH.
- TF_HiringService vérifie la custom permission, la confirmation, le droit de modifier la date, l'accès utilisateur au dossier et son état InterviewScheduled. Il verrouille le dossier puis enregistre lui-même acteur/date/cycle.
- L'écriture des seuls champs d'approbation utilise une élévation explicite en mode système, après ces contrôles ; ces champs restent en lecture seule dans l'interface.

## Frontière Agentforce

Le modèle conseillé est Employee Agent. Le contexte effectif n'est pas encore confirmé. S'il réutilise les droits du RH, l'absence de droits dans TF_AgentAccess ne les retire pas : la frontière repose aussi sur les quatre outils limités, les DTO de sortie, l'absence d'outil générique et un contexte de page sans identité.
Ni la custom permission ni le service Apex ne prouvent seuls qu'une personne a cliqué. Le Screen Flow séparé, les actions exposées et les conversations doivent être testés.

## Tests attendus

1. Utilisateur de recrutement : dossier autorisé lisible ; champs d'approbation non modifiables.
2. Utilisateur sans partage : dossier inaccessible, sans révélation de son existence.
3. Acteur sans TF_ApproveHiring : service RH refusé.
4. RH autorisé : transition via parcours distinct et acteur/date corrects ; écriture forgée refusée.
5. Actions agent : aucune restitution d'identité, satisfaction, champ d'approbation ou note privée.

Statut : matrice préparée ; tests des droits effectifs encore NotRun.
