# Emploi et pauvreté en Côte d'Ivoire : profil de pauvreté à partir de l'ENV 1998

Profil de pauvreté réalisé par Matteo Guerraz et Hawa Kebe (décembre 2025) dans le cadre du cours « Concepts et outils d'analyse de la pauvreté et des inégalités » du M2 Économie Internationale et Développement, Université Paris Dauphine-PSL.

*English summary: a poverty profile (in French) of Côte d'Ivoire based on the 1998 household living standards survey (ENV 1998). It computes FGT poverty indices with survey weights and relates poverty to employment status, occupational category, type of contract and multiple job holding, in Stata. Co-authored with Matteo Guerraz.*

## Résumé

Le travail décrit la pauvreté des individus en Côte d'Ivoire en 1998 à partir de l'Enquête Niveau de Vie des ménages (4 198 ménages, 24 589 individus). Il calcule les indicateurs FGT (incidence, profondeur, sévérité) avec les poids d'extrapolation, puis construit des profils de pauvreté selon le statut d'emploi, la catégorie socio-professionnelle, le type de contrat et le cumul d'emplois. Des faits stylisés sur le travail des enfants et l'informalité complètent l'analyse.

## Contenu

| Fichier | Description |
|---|---|
| `Profil_pauvrete_CIV_GUERRAZ_KEBE.pdf` | Rapport |
| `profil_pauvrete_civ.do` | Do-file Stata : appariement des modules de l'enquête, indicateurs FGT, profils de pauvreté, tests de significativité |

## Données

Les microdonnées de l'ENV 1998 ont été fournies dans le cadre du cours et ne sont pas redistribuées ici.

## Exécution

Logiciel : Stata 16 ou plus récent, avec la commande `povdeco`. Adapter les chemins `raw` et `processed` en tête du do-file, puis lancer le do-file. Le do-file part d'un fichier intermédiaire construit en cours (agrégat de consommation et seuils de pauvreté).
