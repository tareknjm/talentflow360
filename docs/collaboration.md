# Collaboration

## Répartition et rituels

Tarek possède les actions Apex, la sécurité et les déploiements. Le binôme possède les Flows, les contenus et les écrans métier. Chacun relit l'autre. Dix minutes d'alignement en début de séance et dix minutes de démonstration en fin de séance.
Un seul éditeur par Flow dans l'org partagée. Avant de modifier : lire les sources, contrôler git status et relever les changements Setup du binôme. Récupérer les composants concernés dans un répertoire de comparaison avant de les intégrer.

## Git

Le dépôt distant n'est pas configuré à ce stade. Utiliser des commits locaux ciblés après vérification des exclusions et du contenu. Aucune publication distante implicite.
Après mise en place du distant, utiliser une branche par tâche et une PR relue par l'autre personne. La branche Git ne protège pas les métadonnées déjà modifiées dans l'org.
Ne jamais versionner .sf, .sfdx, .env, logs contenant des identités, captures d'authentification ou données réelles.

## Compte rendu

Chaque changement significatif met à jour progress.md. Chaque test consigne date, environnement, commande ou scénario, résultat et référence de preuve dans test-results.md. Un job lancé n'est pas encore un job réussi.
