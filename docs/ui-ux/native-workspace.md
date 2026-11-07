# Espace candidat natif — livraison du 7 novembre 2026

Premier incrément UI/UX déployé dans TFDev, Developer Edition CAN96, API 68.0. Il transpose la navigation et la fiche candidat de la maquette avec des composants Lightning standard. L'accueil à indicateurs, la frise LWC et les actions conditionnelles avancées restent des travaux distincts.

## Ouvrir le résultat

1. Dans Salesforce, ouvrir l'application **TalentFlow 360** depuis les neuf points. Si l'application était ouverte, l'actualiser.
2. Dans **Dossiers talents**, sélectionner **Tous les dossiers TalentFlow**, puis ouvrir TF-DEMO-003 en cliquant sa référence TP-… . N'effectuer aucune réservation ni validation pour cette visite d'affichage.
3. Vérifier le bandeau : code candidat, rôle, état, disponibilité et date d'arrivée si renseignée. Les valeurs viennent du dossier réel ; elles peuvent différer de la maquette.
4. Parcourir **Vue d'ensemble**, **Préparation**, **Entretiens**, **Intégration**. Vérifier qu'une liste vide reste compréhensible ; ne pas modifier le dossier pour la remplir artificiellement.
5. Ouvrir un dossier dont le parcours a déjà été généré, par exemple TF-DEMO-001, puis **Intégration** : consulter échéances, états et mode d'exécution des étapes.
6. Dans **Créneaux d'entretien → Créneaux réservés**, vérifier la nouvelle colonne **Dossier talent**. Elle affiche la référence cliquable du dossier, pas directement son code candidat. Ouvrir le lien pour confirmer le code.
7. Relever les résultats réels, notamment boutons accessibles, champs manquants, état vide et affichage à zoom 200 %. La recette avec un compte réellement restreint reste nécessaire.

La barre de navigation peut conserver une personnalisation utilisateur Salesforce. Si l'ordre affiché ne correspond pas à Dossiers → Créneaux → Étapes → Tâches, rouvrir l'application et vérifier la personnalisation avant de conclure que le déploiement est absent.

## Réalisé et portée

- **CustomApplication TalentFlow360** : navigation centrée sur le travail, couleur de marque bleu profond, affectation de la nouvelle page pour TalentProfile__c sur ordinateur dans cette application. Aucune affectation de page pour une autre application n'est ajoutée.
- **TF_TalentWorkspace** : page native à quatre onglets, sept champs métier en lecture seule via Dynamic Forms, listes associées limitées aux entretiens et étapes, aide latérale pour le panneau Agentforce existant. L'aide est du texte statique, pas un nouvel assistant ou une preuve d'appel d'action.
- **TF_TalentSummary** : compact layout avec code, rôle, état, disponibilité et date d'arrivée. Son affectation est au niveau de l'objet : la synthèse peut donc changer aussi dans d'autres usages de cet objet.
- **Layout TalentProfile__c-TalentFlow** : sections en deux colonnes ; lot/cycle techniques retirés ; champs de validation RH conservés en lecture seule dans le layout, sans être ajoutés aux champs de la nouvelle FlexiPage. Le bouton Modifier et les deux Quick Actions RH existants sont conservés. Ce layout peut être utilisé par plusieurs profils ; leurs affectations ne sont pas changées.
- **Libellés de relations** : Entretiens et Étapes de parcours, sans modification des noms API des relations.
- **Créneaux réservés** : colonne Dossier talent ajoutée pour comprendre à quel dossier appartient chaque réservation.

Les onglets Identités, Satisfaction et Audit sortent de la navigation principale. Cela ne retire aucun droit : les permissions et contrôles serveur continuent de s'appliquer. Aucun service Apex, Flow, permission ou donnée métier n'a été modifié. Les deux métadonnées de champs lookup n'ont changé que pour leur libellé de relation.

Le rendu Lightning ne reproduit pas au pixel près le HTML de conception. Les cartes d'indicateurs, suggestions interactives Agentforce, frise graphique, filtrage avancé des boutons et page d'accueil métier ne sont pas livrés dans cet incrément.

## Preuves techniques

- Cible relue : Developer Edition CAN96 ; sauvegardes isolées dans test-results/ui-baseline, ui-predeploy et ui-list-baseline, ignorées par Git.
- Inventaire FlexiPage : aucune page TalentFlow préexistante ; app sans actionOverride/profileActionOverride avant intervention.
- Première validation à blanc 0AfgK00000Z8t5jSAB refusée pour parentFieldApiName absent. Correction à TalentProfile__c.Id, validée par Salesforce.
- Validation cinq composants : 0AfgK00000Z9DBZSA3 Succeeded ; déploiement réel : 0AfgK00000Z99kgSAB Succeeded.
- Validation huit composants avec finition : 0AfgK00000Z8iPWSAZ Succeeded ; déploiement final : 0AfgK00000Z9EQzSAN Succeeded.
- Métadonnées récupérées après déploiement : override d'application Large vers TF_TalentWorkspace et compactLayoutAssignment TF_TalentSummary confirmés. Sept champs de page vérifiés contre la liste blanche ; aucun champ d'identité/approbation/satisfaction ajouté à cette page.
- UI API des deux listes : HTTP 200, libellés français et colonnes attendues. Ce contrôle ne remplace pas un essai d'utilisateur restreint ni une capture du navigateur.
- Les champs, validations et anciennes vues TalentProfile relus avant/après sont identiques. Aucun test Apex relancé : aucun code ni logique métier modifié. Déploiements NoTestRun, résultats UI séparés dans test-results.md.

## Déployer cet incrément seul

Les fichiers de force-app sont la source de référence. Le script build_native_record_ui.py est un bootstrap lié à la sauvegarde initiale et refuse une page existante : ne pas le relancer sur des pages modifiées par le binôme.

1. Vérifier TFDev et récupérer/comparer l'existant avant mutation. Résultat attendu : org de développement et aucune modification distante non intégrée.
2. Exécuter `python scripts/python/stage_ui_workspace.py`. Résultat attendu : huit fichiers dans test-results/ui-workspace-deploy, dont seulement deux libellés de lookup. Les autres champs du modèle ne sont pas inclus.
3. Exécuter `sf.cmd project deploy start --source-dir test-results/ui-workspace-deploy --dry-run --test-level NoTestRun --target-org TFDev --api-version 68.0`. Résultat attendu : Succeeded ; corriger avant déploiement sinon.
4. Déployer le même répertoire sans --dry-run. Résultat attendu : Succeeded, sans écrasement de métadonnées métier étrangères à l'incrément.
5. Relire application, objet, compact layout, FlexiPage et listes ; vérifier l'affectation de page et le rendu avec les utilisateurs concernés. Résultat attendu : comportement visible dans TalentFlow, pas seulement fichiers présents.

Le manifeste backend complet inclut désormais FlexiPage ; un déploiement de ce manifeste réapplique aussi le reste du socle. Pour la seule UI, employer le staging borné ci-dessus.

## Retour à l'affichage précédent

Les sauvegardes locales avant changement sont dans test-results/ui-baseline et ui-list-baseline. Préserver ces fichiers avant un nettoyage du poste. Pour revenir en arrière, comparer d'abord les éventuelles modifications postérieures du binôme, restaurer les paramètres d'application, le layout et l'affectation de compact layout d'origine ; retirer l'affectation de page dans Lightning App Builder si nécessaire. Vérifier le résultat dans Salesforce. La page devenue inutilisée peut rester dans l'org jusqu'à décision de nettoyage ; aucun rollback automatique ni suppression de données n'est déclenché.

Sources de schéma consultées : [application native LWC Recipes](https://github.com/trailheadapps/lwc-recipes/blob/main/force-app/main/default/applications/LWC_Recipes.app-meta.xml) et [page native Dreamhouse](https://github.com/trailheadapps/dreamhouse-lwc/blob/main/force-app/main/default/flexipages/Property_Record_Page.flexipage-meta.xml). Les contrats effectivement acceptés ont été vérifiés par les validations Metadata API de TFDev.
