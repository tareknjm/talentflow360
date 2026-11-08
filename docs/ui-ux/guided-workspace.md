# Mon espace et actions contextuelles — 8 novembre 2026

Évolution native déployée dans TFDev, Developer Edition CAN96, API 68.0. Aucun LWC, service Apex, Flow, statut métier ou enregistrement candidat ajouté/modifié. L'apparence reste celle de Lightning, avec un accueil métier et des indications adaptées au dossier. Ce livrable ne constitue pas une validation des processus ou de la charte interne Deloitte.

## Parcours utilisateur

1. Rouvrir **TalentFlow 360** depuis le lanceur Salesforce, puis actualiser. Résultat attendu : **Mon espace** dans la navigation. Une navigation personnalisée ou un onglet déjà ouvert peut conserver l'ancien ordre.
2. Ouvrir **Mon espace**. Résultat attendu : trois onglets, **Dossiers à examiner**, **Réservations** et **Étapes à exécuter**. Les listes sont réelles, pas les chiffres de la maquette HTML. Elles affichent jusqu'à huit lignes par vue, avec les contrôles standard disponibles pour consulter davantage d'éléments.
3. Depuis une ligne, ouvrir sa référence pour consulter le dossier ou l'élément associé. Les vues couvrent les enregistrements accessibles au compte ; elles ne filtrent pas uniquement sur leur propriétaire. Réservations inclut les créneaux Reserved même s'ils sont passés : consulter la date et le fuseau affiché avant toute action.
4. Ouvrir **TF-DEMO-002**, déjà validé d'après la capture de démonstration. Résultat attendu : **Valider l'embauche** absent, **Saisir la satisfaction** proposé et aide « Suivre l'intégration ». Ne pas créer une nouvelle réponse pour cette simple vérification visuelle.
5. Ouvrir un dossier à examiner, par exemple TF-DEMO-003 si son état est toujours ReadyForReview. Résultat attendu : aide « Préparer l'entretien », aucune action de satisfaction ou de validation d'embauche à ce stade. Les données réelles peuvent avoir évolué ; ne pas changer l'état uniquement pour obtenir ce résultat.
6. Pour un dossier réellement InterviewScheduled et un RH possédant TF_ApproveHiring : résultat attendu **Valider l'embauche** disponible. Pour un compte sans cette permission : bouton absent. Ne pas lancer une embauche pour tester seulement l'affichage.
7. Vérifier la liste **Intégration** : configuration du conteneur en mode amélioré ADVGRID avec showActionBar=false. Résultat attendu : pas de bouton New dans ce conteneur. L'effet visuel reste à constater : ne pas annoncer sa disparition sur la seule métadonnée.
8. Vérifier **Modifier** : conservé pour changer la disponibilité, le rôle ou la date d'arrivée selon les droits. Après embauche, la modification du rôle/date doit rester possible pour la replanification ; les champs d'approbation continuent d'être protégés côté serveur.

## Règles livrées

| Situation | Action / aide | Garantie et limite |
|---|---|---|
| Draft | Compléter le dossier | Aide informative uniquement ; aucune transition automatique |
| ReadyForReview | Préparer l'entretien | Ouvrir Préparation puis le panneau Agentforce existant avec le code |
| InterviewRequested | Choisir un créneau | Réservation seulement après confirmation et retour réel d'action |
| InterviewScheduled | Consulter la réservation | Bouton RH uniquement avec la custom permission TF_ApproveHiring |
| Hired | Suivre l'intégration | Satisfaction proposée ; validation d'embauche masquée |
| Tout état | Modifier selon les droits existants | Aucun retrait d'autorisation de replanification par la nouvelle page |

Le modèle actuel ne comporte pas de statut « entretien réalisé ». La validation RH reste donc soumise au contrat existant InterviewScheduled + permission + confirmation du service. La frise du processus est un texte d'orientation, pas un nouveau workflow ni une preuve qu'un entretien a eu lieu. Ajouter cette transition demanderait une évolution fonctionnelle distincte.

Les règles visuelles ne constituent pas une frontière d'accès : le service RH et les contrôles objet/champ/partage continuent de refuser les opérations non autorisées. L'aide conditionnelle lit uniquement Status__c. Aucun champ d'identité, satisfaction, approbation ou note privée n'est ajouté à la fiche ou à un contexte Agentforce. Le contexte effectivement transmis au panneau global et les comptes restreints restent à recetter.

## Technique et affectations

- **TF_MyWorkspace** : AppPage standard, modèle flexipage:defaultAppHomeTemplate ; CustomTab Mon espace placé en premier dans TalentFlow360. Aucun remplacement de la Home globale de l'org.
- Trois composants flexipage:filterListCard sur les vues existantes TF_AwaitingReview, TF_ReservedSlots et TF_OpenSteps. Pas de dashboard avec utilisateur d'exécution privilégié, de requête Apex en mode système ni de compteur fictif.
- **TF_WorkspaceAccess** : nouveau permission set contenant uniquement la visibilité du nouvel onglet ; aucun droit objet, champ, Flow ou RH. Affecté au seul opérateur connecté. Les autres utilisateurs autorisés auront besoin de cette affectation en complément de leurs droits métier.
- **TF_TalentWorkspace** : actions dynamiques via actionNames/valueList et règles de visibilité. Référence custom permission acceptée : `{!$Permission.CustomPermission.TF_ApproveHiring}`. Le service TF_HiringService n'est pas exposé à l'agent.
- Scripts build_guided_workspace.py et stage_guided_workspace.py : bootstrap depuis sauvegardes vérifiées, puis staging borné de cinq composants. Ne pas régénérer des pages déjà éditées par le binôme. Les fichiers de force-app restent la source de référence.
- Sauvegardes avant intervention : test-results/ux-guided-baseline et ux-guided-predeploy ; comparaison sans changement concurrent. Ces fichiers sont ignorés par Git et à conserver sur le poste pour un retour arrière comparé aux changements ultérieurs.

## Vérifications réellement exécutées

- Validation complète Succeeded : 0AfgK00000Z9gLfSAJ ; déploiement cinq composants Succeeded : 0AfgK00000Z9LqgSAF.
- Ajustement pour préserver Modifier après embauche : validation un composant 0AfgK00000Z9vqvSAB et déploiement 0AfgK00000Z9Ak2SAF, tous deux Succeeded.
- Récupération après envoi : règles d'actions, aides par état, vues et navigation relues depuis l'org. Affectation du droit d'onglet : 1 succès, 0 échec.
- UI API : trois vues HTTP 200 ; 4 dossiers, 3 réservations et 6 étapes au moment du contrôle, limités à la page demandée. Ces nombres peuvent évoluer et ne sont pas des indicateurs globaux.
- UI API apps avec formFactor=Large : HTTP 200, Mon espace en premier dans navItems de TalentFlow360 pour le compte connecté. Ce n'est pas une capture du panneau dans le navigateur.
- Aucun test Apex relancé : aucune logique serveur changée ; validations Metadata API NoTestRun et lectures UI API consignées séparément.

## Recette restante et suite

Affichage réellement masqué/visible des actions et de New, comportement de chaque onglet, état vide, compte restreint, clavier/zoom et affichage mobile : **NotRun** jusqu'à observation. Les contrôles serveur déjà testés ne remplacent pas ces essais UI.

Après recette, évaluer les limites concrètes du standard : un LWC d'accueil ou de parcours pourra améliorer la présentation si nécessaire. Les compteurs globaux, les suggestions Agentforce à un clic, le passage automatique d'un code au chat, la frise graphique J+90 et un nouveau statut d'entretien restent hors de cette livraison.

Références : [FlexiPage Metadata API](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-flexipage.html), [actions d'un panneau natif dans LWC Recipes](https://github.com/trailheadapps/lwc-recipes/blob/main/force-app/main/default/flexipages/Contact_Record_Page.flexipage-meta.xml). Le contrat final a été validé empiriquement dans TFDev ; les propriétés rejetées lors des essais sont conservées dans test-results.md.
