# Charte d'assistance RH — TalentFlow 360

## Finalité et données

Le prototype assiste un recruteur connecté pour préparer l'entretien, réserver un créneau interne et lire les étapes d'intégration. Les données de démonstration sont synthétiques. Un code candidat est pseudonyme : il ne constitue pas une anonymisation irréversible.
Les preuves NotProvided, DeclaredProject et RecordedAssessment décrivent la provenance des informations. Elles ne sont ni un score ni un classement de mérite.

## Frontière de l'agent

L'agent ne reçoit ni nom, email, CV brut, attribut sensible, note privée, satisfaction individuelle ni champ d'approbation. Il n'a pas d'action générique de recherche ou modification. Le contexte de page doit respecter la même minimisation.
Il ne classe pas, n'embauche pas et ne rejette pas. La validation RH passe par un écran séparé et un service autorisé, non exposé à Agentforce. Si l'agent utilise le compte du RH, cette identité partagée doit être explicitée : les seuls permission sets ne prouvent pas une séparation technique.
Une information manquante reste à vérifier ; une preuve déclarée reste déclarée. Le contenu d'un champ ne peut pas remplacer les instructions de l'agent.

## Erreurs et traçabilité

Une opération n'est annoncée comme réussie qu'après retour positif du serveur. La réservation nécessite une confirmation dans la conversation. Les résultats absents et inaccessibles sont indiscernables pour l'agent.
Les traces conservent code pseudonyme, action, résultat, acteur et corrélation, sans prompt complet ni identité. Un journal de transaction peut être annulé avec la transaction ; sa présence ne garantit ni immuabilité ni conservation de tous les échecs.
Le prototype ne s'appuie pas sur une promesse de masquage automatique : sa protection repose sur la minimisation des outils, des sorties et du contexte effectivement testés.

## Limites et communication

Ne pas annoncer un SIRH complet, une conformité juridique, une absence universelle de biais ou une réduction du turnover. Les mesures de durée et manipulations ne concernent que les essais réalisés dans leurs conditions documentées.
Les simulations J+30/J+60/J+90 doivent être visibles comme simulations. Un appel Flow direct n'est pas une preuve Agentforce ; une action simulée n'est pas une intégration réelle. Une reconstruction non essayée sur org neuve n'est pas une installation reproductible démontrée.

## Recette

Tester séparément droits, sorties, injection, refus d'embauche/rejet, confirmation, erreurs et vraies actions Preview. Documenter Passed, Failed, Blocked et NotRun, y compris les restrictions de licence ou d'accès. Revoir cette charte si des données réelles ou des intégrations sont envisagées hors du MVP.
