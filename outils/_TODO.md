
# TP

## TP1 Back/Front, Couches, Git


## TP2 Business_object


## TP3 API


## TP4 DAO

PlayerService.username_already_used() -> PlayerDAO.find_by_username()


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

- [ ] elo: int en passant par le front (entre 1000 et 3000)
  - et par l'api on peut mettre ce qu'on veut




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

## Json-server



sudo apt update
sudo apt install nodejs npm
npm install -g json-server

Create file data/db.json

```json
{
  "games": [
    {
      "id": "1",
      "players_list": [
        "Alice",
        "Bob"
      ],
      "winner_name": "Alice",
      "location_name": "Arena 1",
      "duration_seconds": 120,
      "mode_type": "coinflip"
    },
    {
      "id": "2",
      "players_list": [
        "Eve",
        "Frank"
      ],
      "winner_name": "Eve",
      "location_name": "Secret Cave",
      "duration_seconds": 300,
      "mode_type": "dice"
    }
  ],
  "$schema": "./node_modules/json-server/schema.json"
}
```

json-server --watch data/db.json --port 5000


curl -X GET http://localhost:5000/games

curl -X POST http://localhost:5000/games \
     -H "Content-Type: application/json" \
     -d '{
           "uuid_match": 103,
           "players_list": ["Eve", "Boris"],
           "winner_name": "Eve",
           "location_name": "Secret Cave",
           "duration_seconds": 300,
           "mode_type": "dice"
         }'
		 
		 
curl -X PUT http://localhost:5000/games/1 \
     -H "Content-Type: application/json" \
     -d '{
           "uuid_match": 101,
           "players_list": ["Alice", "Bob"],
           "winner_name": "Bob",
           "location_name": "Arena 1 (Updated)",
           "duration_seconds": 150,
           "mode_type": "coinflip"
         }'
		 
curl -X DELETE http://localhost:5000/games/2