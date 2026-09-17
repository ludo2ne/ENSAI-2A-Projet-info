
## :construction: Todo

- https://ensae-reproductibilite.github.io/website/chapters/code-quality.html
- Docker: https://ensae-reproductibilite.github.io/website/chapters/portability.html

### A corriger


```pages/home.py
-    if response:
+    if response.get("status_code") == 200:
         logger.info("Database successfully reset")
         st.toast("Database successfully reset ✅")
```


### Projet

- [ ] maj Template
  - pytest + cov
  - CI
  - https://github.com/ClementValot/Projet2A_Template
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

Base : une appli avec des joueurs et des matchs
Objectifs : fonctionnalité pour gérer des tournois

Steps:

- Fournir écran vide: liste des tournois, s'inscrire
- Créer BO Tournoi
- Créer table tournoi, inscription
- Créer TournoiDAO, InscriptionDAO
- Créer TournoiService, InscriptionService
- Màj vue

#### TP1 : Environnement de dev, outils

- Rappels Git
- Format, lint
- VSCode settings
- Logs
- [ ] Nommer repo projet : `Projet-info-2A-equipe-<numéro_equipe>`

#### TP2 : Refresh Python, POO, TU

-

#### TP3 : WS

- [ ] Passer de Insomnia à [usebruno](https://www.usebruno.com/)

#### TP4 : DAO
  
- [ ] coquilles modèle données SQL

#### TP5 : Vues

- [ ] mettre au propre et à dispo en autonomie
- [ ] Remplacer inquierPy par https://streamlit.io/ ? 

---

# TP5

- Service to list players' games
- Menu to play Dice
- Tests




#### Projet info améliorations


- [ ] Note gestion projet, suivi hebdo, participation

- CM à part de 1h pour présentation du projet
- Suivi hebdo
    - [ ] Dire de détailler plus
    - [ ] Note de suivi coef 1/4 ? Rajoute du travail aux tuteurs...
- Rapport
  - [ ] intégrer suivi hebdo au rapport final en annexe ?
  - [ ] 20-25 pages hors annexe
  - [ ] Parties : Métier, implémentation Technique (ciblage), Organisation d'équipe, Qualité
  - [ ] Grille notation format excel, imprimer une dizaine
- Soutenance
  - parler du projet sous un autre angle que le rapport
  - mais ne pas aller trop loin quand même
  - Petite mise en scéne bien sans aller trop loin
- Code
  - [ ] pas de .env sur GitHub, encore moins avec mdp
  - [ ] présence .gitignore
  - [ ] Insister sur Ruff
  - [ ] IHM Streamlit
    - Demandée mais code non noté
    - Aide IA recommandée
  - [ ] Demander à mettre repo public aprés rendu final
- Logistique
  - Le presta récupére sa machine café quand il vient déposer les plateaux
  - [ ] Midi : Demander cafetiere et sac poubelle à la logistique
  - [ ] Donner Modop connexion Wifi
- TP
  - [ ] TP sur les design pattern
  - [ ] Remettre un peu de POO (héritage, polymorphisme)
    - Variantes de puissance4


# TP

- [ ] Uniformiser format -> prompt quarto
- [ ] Faire relire
- [ ] Branche start
- [ ] API example client mode (external url)

## TP1 Back/Front, Couches, Git


## TP2 Business_object



## TP3 DAO

PlayerService.username_already_used() -> PlayerDAO.find_by_username()


## TP4 API

- [ ] elo: int en passant par le front (entre 1000 et 3000)
  - et par l'api on peut mettre ce qu'on veut




## TP IHM et Sécurité

- [ ] Modification pour ne pas utiliser un seul Model mais 2

```python
# backend/src/schemas/player_schemas.py
from pydantic import BaseModel, EmailStr, Field

class PlayerCreate(BaseModel):
    """Ce que le client ENVOIE pour créer"""
    username: str
    password: str = Field(..., min_length=12)
    email: EmailStr

class PlayerResponse(BaseModel):
    """Ce que l'API RENVOIE au client (on cache le password !)"""
    id_player: int
    username: str
    email: EmailStr
    elo: int
```






---


Pour passer d'un simple script de mise à jour d'Elo à un véritable système de gestion de jeux, tu vas devoir passer d'une logique de **"calcul immédiat"** à une logique de **"gestion d'événements"**.

Voici l'analyse de la transformation nécessaire.

### 🛠️ 1. Liste des composants à créer / modifier

#### **A. Les Business Objects (Les entités)**
*   **`Player` (Modifier) :** Doit rester pur. Il contient les infos et l'Elo.
*   **`GameResult` (Nouveau) :** Un objet qui représente une partie terminée. Il doit stocker : `id_game`, `player1_id`, `player2_id`, `game_type` (pile/face ou dés), `winner_id` (ou `None` en cas d'égalité), et la `date`.

#### **DAOs (L'accès aux données)**
*   **`PlayerDao` (Modifier) :** Pour gérer les joueurs.
*   **`GameDao` (Nouveau) :** Pour enregistrer et lire l'historique des parties jouées.

#### **Services (La logique)**
*   **`GameService` (À refondre) :** Il ne fera plus le calcul lui-même. Il va :
    1. Récupérer les joueurs.
    2. Appeler un moteur de jeu pour obtenir le résultat.
    3. Appeler un moteur de score pour calculer le nouvel Elo.
    4. Sauvegarder le résultat dans le `GameDao`.

---

### 🏗️ 2. Ordre de mise en œuvre judicieux

Il ne faut pas tout coder d'un coup. Suis cet ordre pour valider chaque étape :

1.  **Étape 1 : Persistance des résultats.** Crée le `GameResult` et le `GameDao`. Avant de changer les règles du jeu, assure-toi que tu sais enregistrer qu'une partie a eu lieu.
2.  **Étape 2 : Diversification des jeux.** Introduis les nouveaux types de jeux (Dice) et gère la notion d'égalité (`winner = None`).
3.  **Étape 3 : Découplage du calcul.** Séple le calcul de l'Elo de la logique du jeu (pour pouvoir changer de règles de calcul plus tard).

---

### 🎨 3. Design Patterns : Lesquels et pourquoi ?

Pour que ce soit pédagogique et "propre", voici les deux patterns les plus adaptés à ton besoin :

#### **A. Le Pattern STRATEGY (Pour les types de jeux)**
**Pourquoi ?** Actuellement, ton `play` fait un `secrets.choice(["heads", "tails"])`. Si tu ajoutes les dés, tu vas mettre un `if`. C'est l'occasion d'utiliser une stratégie.

*   **L'idée :** Créer une interface `GameRules`.
*   **Implémentations :** `CoinFlipRules` (renvoie heads/tails) et `DiceRules` (renvoie 1 à 6).
*   **Bénéfice :** Ton `GameService` ne connaît pas les règles, il dit juste : `rules.execute()`.

#### **B. Le Pattern FACTORY (Pour la création des jeux)**
**Pourquoi ?** Pour que le contrôleur n'ait pas à savoir comment instancier chaque jeu.

*   **L'idée :** Une `GameFactory.get_game(type: str)`.
*   **Bénéfice :** Si tu veux ajouter un jeu de "Blackjack" plus tard, tu ajoutes juste une ligne dans la Factory. Le reste du code ne change pas.

---

### 📝 Résumé de la nouvelle architecture cible

| Couche | Composant | Rôle |
| :--- | :--- | :--- |
| **Controller** | `GameController` | Reçoit `player1`, `player2` et `game_type`. |
| **Service** | `GameService` | Orchestre : `Factory` $\rightarrow$ `Rules` $\rightarrow$ `Elo` $\rightarrow$ `GameDao`. |
| **Strategy** | `CoinFlipRules` / `DiceRules` | Définit le résultat (gagnant ou égalité). |
| **Factory** | `GameFactory` | Choisit le bon moteur de jeu selon le type. |
| **DAO** | `GameDao` | Sauvegarde l'historique des parties. |
| **Model** | `GameResult` | L'objet qui contient la trace de la partie. |


----

### Comment découper la méthode `play()` ?

Pour transformer la méthode `play()` actuelle (qui est un "script" linéaire) en une architecture de jeu évolutive, tu dois appliquer le principe de **Responsabilité Unique**. 

Voici la stratégie de découpage en 3 composants :

#### A. Le Moteur de Jeu (Le "What") **Pattern Strategy**

La méthode `play()` actuelle mélange le "Quoi" (le tirage) et le "Comment" (l'Elo).
*   **Action** : Créer une classe `GameEngine` ou `MatchEngine`.
*   **Rôle** : Elle ne connaît pas la base de données. Elle prend deux objets `Player`, elle utilise une `GameRules` (stratégie) pour décider qui gagne, et elle renvoie un objet `MatchResult`.
*   **Pourquoi ?** Cela permet de tester la logique du jeu sans jamais toucher à la base de données.


#### B. Le Calculateur de Score (Le "Math") **Pattern Strategy**

*   **Action** : Sortir le calcul de l'Elo de la méthode de jeu.
*   **Rôle** : Créer un `ScoringService` qui prend un `MatchResult` et retourne les nouveaux scores.
*   **Pourquoi ?** Si demain tu veux un mode "Tournoi" où les points sont multipliés par 2, tu ne modifies pas le jeu, tu changes juste la stratégie de score.

#### C. L'Orchestrateur (Le "Coordinator") **Le Service actuel**

Le `GameService` devient un chef d'orchestre qui fait le lien entre les composants.

**Le nouveau flux de `play()` ressemblerait à ceci :**

```python
def play(self, player_id, opponent_id, game_type):
    # 1. Récupération des données (Data Access)
    p1 = self.player_service.find_by_id(player_id)
    p2 = self.player_service.find_by_id(opponent_id)

    # 2. Sélection du moteur de jeu (Factory)
    game_engine = self.game_factory.get_engine(game_type)

    # 3. Exécution du match (Strategy - Pure Logic)
    # Le moteur retourne un objet MatchResult (winner, result_type, etc.)
    match_result = game_engine.execute(p1, p2)

    # 4. Calcul des nouveaux scores (Strategy)
    # On injecte le résultat du match dans le calculateur
    new_scores = self.scoring_service.compute(p1, p2, match_result)

    # 5. Persistance (Data Access)
    p1.elo, p2.elo = new_scores
    self.player_service.update(p1)
    self.player_service.update(p2)
    self.game_dao.save_result(match_result)

    return match_result
```

### Résumé pour tes étudiants :
*   **Avant** : Une seule fonction qui fait tout (Tout est mélangé).
*   **Après** : 
    *   Le **Service** orchestre (le chef d'orchestre).
    *   Le **GameEngine** décide du résultat (le joueur).
    *   Le **ScoringService** calcule les points (l'arbitre).
    *   Le **DAO** enregistre tout (le secrétaire).

---


Après analyse de ce sujet de TP, voici mes observations concernant les incohérences, les erreurs potentielles et les points d'attention importants.

### ⚠️ Incohérences et Erreurs détectées

1.  **Erreur de description dans la Factory** :
    *   Dans la tâche : *"returns the corresponding `GameModeFactory` object"*.
    *   **Correction** : La méthode doit retourner un objet de type `GameMode` (une instance de `DiceMode` ou `CoinFlipMode`), et non un objet `GameModeFactory`. La factory est l'outil de création, pas le produit créé.

2.  **Ambiguïté sur la signature de `ScoringStrategy.compute`** :
    *   Le sujet demande d'implémenter `compute(p1, p2, winner)`.
    *   **Incohérence de conception** : Si la `ScoringStrategy` est une classe métier (Business Object), elle ne devrait normalement pas modifier directement l'attribut `elo` des objets `Player` passés en paramètres (principe d'immuabilité ou de séparation des responsabilités). Habituellement, elle devrait *calculer* les nouveaux scores et renvoyer les valeurs, laissant le `GameService` (ou un DAO) s'occuper de la persistance. 
    *   *Note : Je suivrai l'instruction telle quelle (mise à jour directe), mais je le signalerai si cela pose problème lors de l'implémentation des tests.*

3.  **Incohérence de l'objet `Game` dans le diagramme vs instructions** :
    *   Le diagramme Mermaid montre `GameService ..> Game : creates`.
    *   Cependant, la section "Polymorphic Game Modes" suggère que c'est le `GameMode.play()` qui retourne un objet `Game`. 
    *   **Clarification** : Il faudra décider si c'est le `GameMode` qui instancie le `Game` ou si le `GameService` instancie le `Game` à partir des résultats fournis par le mode. L'approche la plus propre est que le `GameMode` retourne les données du résultat, et le `GameService` crée l'objet `Game` complet (incluant les timestamps, etc.).

### 💡 Ce qu'il manque (Points d'attention)

1.  **Gestion des imports et des chemins** : 
    Le sujet demande de créer des fichiers dans de nouveaux dossiers (`game_mode/` dans `business_object/`). Il faudra être très vigilant sur les imports relatifs (ex: `from ..player import Player`) pour ne pas casser la structure du projet.

2.  **Le cas du "Draw" (Match nul)** :
    Le sujet mentionne pour le `DiceMode` que si les dés sont égaux, `winner = None`. Il faudra s'assurer que la `ScoringStrategy` et la méthode `__str__` de `Game` gèrent correctement ce cas de figure (`winner` étant `None`).

3.  **Type de retour de `play()`** :
    La section "GameService refactor" dit : *"We should return a Game object, but for now, let's leave it as is"*. Cela signifie que pour l'instant, la méthode `play()` du service ne retournera probablement rien (ou l'ancien format). Il faudra bien suivre cette consigne pour ne pas faire de "sur-ingénierie" prématurée.

---

**Résumé pour la suite :**
Le sujet est cohérent sur le plan pédagogique (progression logique), malgré la petite erreur de texte sur la Factory. Je suis prêt à commencer l'implémentation dès que tu me donneras le signal.

---

Ce troisième TP est le plus critique en termes d'architecture : il introduit la **persistance** et le passage d'un modèle purement en mémoire à un modèle relié à une base de données SQL via le pattern **DAO**.

Voici mon analyse du sujet :

### ⚠️ Incohérences et points de vigilance

1.  **Incohérence SQL / Python (Le type de l'ID)** :
    *   Dans le script SQL : `id_game SERIAL PRIMARY KEY`. En PostgreSQL, `SERIAL` crée un entier auto-incrémenté.
    *   Dans le `GameDao.create()` : Le sujet demande d'extraire l'ID retourné par la base pour mettre à jour l'objet `Game`. 
    *   **Attention** : Il faudra utiliser `cursor.RETURNING id_game` dans la requête `INSERT` pour pouvoir récupérer cet ID immédiatement après l'insertion de manière propre.

2.  **Le piège de la performance (N+1 Query Problem)** :
    *   Le sujet contient un avertissement très important dans une `callout-caution` sur l'utilisation de `PlayerDao().find_by_id()` à l'intérieur d'une boucle ou d'une conversion d'objet.
    *   **Incohérence pédagogique** : Le sujet demande d'implémenter `find_all_by_player` en utilisant la méthode de conversion "standard" (qui appelle le `PlayerDao` pour chaque ligne), tout en prévenant que c'est une mauvaise pratique en production.
    *   **Conseil** : Pour le TP, je suivrai l'instruction (utiliser le `PlayerDao`), mais je garderai en tête que pour un projet réel, il faudrait un `JOIN` SQL.

3.  **La gestion de la transaction (Atomicité)** :
    *   Le sujet demande de mettre à jour l'Elo des joueurs (TP2) et de créer un jeu (TP3).
    *   **Risque** : Si l'insertion du `Game` échoue mais que l'Elo des joueurs a déjà été incrémenté en base, la base de données est dans un état incohérent. 
    *   *Note : Le sujet ne demande pas explicitement de gérer les transactions (`commit`/`rollback`), mais c'est un point qu'il faudra surveiller lors de l'implémentation du `GameService`.*

4.  **Le schéma SQL vs l'environnement** :
    *   Le script SQL utilise `project.game`. La note précise que le script `reset_database.py` gère le schéma via une variable d'environnement.
    *   **Attention** : Lors de l'écriture du `GameDao`, je ne dois **jamais** hardcoder le nom du schéma (`project.`) dans mes requêtes SQL, sinon le code ne fonctionnera pas dans l'environnement de test (sandbox).

### 💡 Ce qu'il faut bien comprendre pour réussir

*   **Le rôle du Singleton** : Le `GameDao` doit être un `Singleton`. Cela signifie que peu importe où tu l'appelles dans ton application, tu utiliseras toujours la même instance, ce qui est crucial pour la gestion de la connexion via `DBConnection`.
*   **La conversion de type (Mapping)** : C'est l'étape la plus laborieuse. On passe d'un dictionnaire "plat" (`row["id_player1"]`) à un objet riche (`player1: Player`). C'est le cœur du travail du DAO.
*   **Le concept de "Sandbox" pour les tests** : Le sujet insiste sur le fait de ne pas tester sur la base de données réelle. Pour la partie "Unit Tests", il faudra s'assurer que les tests utilisent un schéma de test isolé.

---

Ce quatrième TP est le plus complet car il boucle la boucle : vous passez du rôle de **Client** (consommer une API externe) à celui de **Serveur** (exposer votre propre API de manière professionnelle). Il introduit les concepts de **Data Mapping**, de **Validation** et de **Sécurité**.

Voici mon analyse des tâches et des points de vigilance :

### ⚠️ Incohérences et points de vigilance

1.  **Le Schéma de l'API Externe (Mapping)** :
    *   Le JSON fourni pour l'API externe utilise des clés comme `players_list`, `winner_name`, `location_name`, etc.
    *   **Attention** : Votre classe `Game` (créée au TP3) utilise probablement des noms différents (ex: `player1`, `player2`, `winner`). Le cœur de l'exercice est de transformer le dictionnaire "sale" de l'API externe en vos objets métier "propres". Ne tentez pas de modifier votre classe `Game` pour qu'elle ressemble à l'API externe, faites l'inverse dans le client.

2.  **La structure du `GameModel` (Pydantic)** :
    *   Le sujet demande de créer un modèle qui inclut des sous-modèles (ex: `player1: aPlayerModel`).
    *   **Point technique** : Pour que cela fonctionne, votre `PlayerModel` doit être disponible. Lors de la création de `GameModel`, assurez-vous de bien importer `PlayerModel`.
    *   **Attention au cycle d'importation** : Si `PlayerModel` a besoin de `GameModel` et vice versa, vous aurez une erreur. Gardez les modèles de réponse (`ResponseModels`) simples.

3.  **La gestion de l'ID dans `get_games()`** :
    *   L'API externe fournit un `id` (string) tandis que votre base de données utilise un `id_game` (int). 
    *   **Vigilance** : Lors du mapping dans `game_client.py`, soyez attentif au type de données (conversion `int(elt["id"])` si nécessaire).

4.  **Sécurité (Token)** :
    *   Le sujet demande de protéger les routes `POST` et `DELETE`. 
    *   **Attention** : N'oubliez pas que pour tester cela dans **Swagger**, vous devrez utiliser l'interface de test pour ajouter le header `X-Auth-Token`, sinon vous recevrez systématiquement des `401 Unauthorized`.


---

C'est une excellente question. En analysant les trois TP d'un coup, on remarque que la progression est globalement logique (on construit une architecture de plus en plus complexe), mais il existe effectivement des **redondances** et des **décalages** qui pourraient perdre un étudiant ou créer de la confusion.

Voici mon analyse de la cohérence globale :

### 1. Ce qui est cohérent (La force de la progression)
*   **L'évolution du `Game`** : 
    *   TP2 : On crée l'objet métier `Game` (le "cerveau").
    *   TP3 : On crée le `GameDao` pour enregistrer ce `Game` en base de données (la "mémoire").
    *   TP4 : On crée un `GameModel` (le "contrat") pour envoyer ce `Game` sur le réseau sans fuiter de données sensibles. 
    *   *C'est une progression parfaite du concept de donnée.*
*   **Le passage de Monolithe à Modulaire** : Le refactoring du TP2 (Strategy/Factory) prépare parfaitement le terrain pour le TP3 (DAO) et le TP4 (Modèles multiples). Sans le TP2, le TP3 et le TP4 seraient des cauchemars de code spaghetti.

### 2. Ce qui est "en trop" ou redondant (Les points de friction)

Il y a deux éléments qui pourraient être optimisés pour éviter que l'étudiant n'ait l'impression de "refaire la même chose" ou de travailler sur du code obsolète :

*   **Le "Mock" du TP4 vs le "Réel" du TP3** :
    *   Au TP4, vous demandez d'ajouter un endpoint `GET /game` qui commence par un **mock** (tableau statique), puis de le remplacer par un appel au **Service/DAO**.
    *   **Incohérence** : L'étudiant vient de passer tout le TP3 à implémenter un DAO et un Service ultra-propres pour la persistance. Lui demander de revenir à un "mock" au début du TP4 est une régression pédagogique.
    *   **Conseil** : Supprimez l'étape "Add this endpoint [mock]" au TP4. Allez directement à l'étape "Modify the existing endpoint to use the Service/DAO".

*   **La redondance du `GameModel`** :
    *   Au TP2, on crée la classe `Game` (Business Object).
    *   Au TP4, on crée `GameModel` (Pydantic Model).
    *   Pour un débutant, la distinction entre `Game` (logique) et `GameModel` (transport) est subtile. Si l'étudiant ne comprend pas bien la différence, il risque de mélanger les deux et d'essayer d'utiliser `Game` (l'objet avec les méthodes métier) comme `response_model` dans FastAPI, ce qui causera des erreurs de sérialisation.

### 3. Les "oublis" ou manques de liens

*   **Le lien entre le Client (TP4) et le Serveur (TP3/TP4)** :
    *   Le TP4 demande de créer un `game_client.py` qui consomme une API externe (Star Wars ou autre). 
    *   **Manque de boucle** : Il n'y a pas de consigne qui demande à l'étudiant de faire l'inverse : **utiliser son propre `game_client.py` pour consommer l'API qu'il vient de construire au TP3/TP4.** 
    *   *L'expérience serait complète si l'étudiant faisait : "Je crée mon serveur $\rightarrow$ Je crée mon client $\rightarrow$ Mon client appelle mon serveur".*

### Résumé de mes recommandations pour vos supports :

1.  **Élagage TP4** : Supprimez l'étape de création de l'endpoint "mock" au TP4. L'étudiant doit déjà avoir un endpoint fonctionnel avec le DAO grâce au TP3.
2.  **Clarification Terminologique** : Dans le TP4, insistez lourdement sur la différence entre `Business Object` (ce qu'on manipule dans le code) et `Pydantic Model` (ce qu'on affiche sur le web).
3.  **Boucle de rétroaction** : Ajoutez une petite tâche à la fin du TP4 : *"Utilisez votre client `game_client.py` pour interroger votre propre API locale au lieu de l'API externe"*. Cela prouve qu'ils ont compris les deux côtés de la médaille.