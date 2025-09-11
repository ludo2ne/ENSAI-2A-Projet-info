+# ENSAI-2A-Projet-info

Projet informatique de 2e année

## Courss

| CM 1                  | Temps estimé   |
|-----------------------|----------------|
| Intro                 | 10 min         |
| Projet                | 20 min         |
| Outils Dev            | 20 min         |
| Git                   | 30 min         |
| Analyse fonctionnelle | 1 h            |s
| POO Avancée           | 30 min         |

| CM 2                  | Temps estimé   |
|-----------------------|----------------|
| Tests Unitaires       | 30 min         |
| Webservices           | 60 min         |
| DAO - Sécurité        | 90 min         |

## :rocket: Publier les pages

Site construit avec [Quarto](https://quarto.org/) ([Tutoriel](https://ludo2ne.github.io/Quarto-tuto/))

Pour générer les pages :

- en local : `quarto render quarto-site` (les pages sont créées dans le dossier *quarto-site/_site*)
- sur [GitHub](https://ludo2ne.github.io/ENSAI-2A-Projet-info) : voir fichier `.github/workflows/publish.yml`

## :construction: Todo

- [ ] Projet et TP sur Datalab
- [ ] TP simplifiés
  - from template -> ajouter fonctionnalité "inscription tournoi" ?

### Projet

- [ ] maj Template
  - pytest + cov
  - CI
- [ ] Bilan du point hebdo
- Notice élèves
  - [ ] Compléter section livraison dossier analyse (voir mail)

### CM

- [ ] Projet Flask pour les démo en CM -> tournoi-echecs
- [ ] Git : simples rappels car cours donné en 1A
- [ ] API : https://pythonds.linogaliana.fr/content/manipulation/04c_API_TP.html
- https://datacrafting.substack.com/p/jour-19-ii-python-the-right-way-ecrire
- https://datacrafting.substack.com/p/jour-20-ii-python-the-right-way-les
- Sécurité
  - pas trop de sécurité abusive
  - principe POLP
  - SSO, RSA
  - .gitignore
  - màj version
  - password
  - code smell
  - venv, poetry

### TP

#### TP1 : Git, VSCode, Logs et Template

- [ ] Nommer repo projet : `Projet-info-2A-equipe-<numéro_equipe>`

#### TP2 : Refresh Python, POO, TU

#### TP3 : WS

- [ ] Passer de Insomnia à [usebruno](https://www.usebruno.com/)

#### TP4 : DAO
  
- [ ] coquilles modèle données SQL

#### TP5 : Vues

- [ ] mettre au propre et à dispo en autonomie
- [ ] Remplacer inquierPy par https://streamlit.io/ ? 

## Licence

Ce projet est sous licence [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-nc-sa/4.0/).

Vous êtes libre de partager et modifier ce travail à des fins non commerciales, à condition de me créditer et de redistribuer sous la même licence.
