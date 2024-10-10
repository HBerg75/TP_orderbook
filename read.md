
# OrderBook Smart Contract

## Description

Ce smart contract **OrderBook** permet de gérer un carnet d'ordres d'achat et de vente pour deux tokens ERC20 (tokenA et tokenB). Il permet aux utilisateurs de placer des ordres d'achat ou de vente, d'exécuter automatiquement des ordres correspondants lorsque les prix et les quantités sont compatibles, et d'historiser les ordres exécutés.

Le smart contract est conçu pour traiter les ordres d'achat et de vente de manière FIFO (First In, First Out) en cas d'égalité de prix.

## Fonctionnalités

- **Placer un ordre d'achat**
- **Placer un ordre de vente**
- **Exécuter des ordres correspondants automatiquement**
- **Historique des ordres exécutés**
- **Récupérer les ordres d'achat et de vente en cours**

## Déploiement

Le smart contract nécessite deux adresses de tokens ERC20 (tokenA et tokenB) lors de son déploiement.

```solidity
constructor(address _tokenA, address _tokenB) {
    tokenA = IERC20(_tokenA);
    tokenB = IERC20(_tokenB);
}
```

## Principales Fonctions

### `placeBuyOrder(uint256 price, uint256 quantity)`

- Permet à un utilisateur de placer un ordre d'achat de `tokenA` à un prix et une quantité spécifiés.
- L'utilisateur doit d'abord approuver le contrat pour transférer `tokenA`.
- Si un ordre correspondant existe dans le carnet des ventes, l'exécution de l'ordre a lieu automatiquement.

### `placeSellOrder(uint256 price, uint256 quantity)`

- Permet à un utilisateur de placer un ordre de vente de `tokenB` à un prix et une quantité spécifiés.
- L'utilisateur doit d'abord approuver le contrat pour transférer `tokenB`.
- Si un ordre correspondant existe dans le carnet des achats, l'exécution de l'ordre a lieu automatiquement.

### `matchOrders()`

- Fonction interne qui vérifie les ordres d'achat et de vente pour trouver des correspondances.
- Si les prix et les quantités correspondent, l'exécution de l'ordre est déclenchée.

### `executeOrder(uint256 buyIndex, uint256 sellIndex)`

- Fonction interne qui exécute un ordre correspondant. Elle transfère les tokens entre l'acheteur et le vendeur.
- Une fois l'exécution terminée, les ordres sont retirés du carnet d'ordres actif et enregistrés dans l'historique des ordres exécutés.

### `getReadableBuyOrders()`

- Renvoie les informations sur tous les ordres d'achat en cours.
- Retourne un ensemble de tableaux contenant les adresses des utilisateurs, les prix, les quantités et les timestamps des ordres d'achat.

### `getReadableSellOrders()`

- Renvoie les informations sur tous les ordres de vente en cours.
- Retourne un ensemble de tableaux contenant les adresses des utilisateurs, les prix, les quantités et les timestamps des ordres de vente.

### `getReadableExecutedOrders()`

- Renvoie l'historique des ordres exécutés, en détaillant les acheteurs, les vendeurs, les prix, les quantités, et les timestamps des exécutions.

### Events

#### `NewOrder(address indexed user, uint256 price, uint256 quantity, bool isBuyOrder)`

- Emis lorsqu'un nouvel ordre est placé dans le carnet d'achat ou de vente.

#### `OrderExecuted(address indexed buyer, address indexed seller, uint256 price, uint256 quantity)`

- Emis lorsqu'un ordre d'achat et de vente correspondant est exécuté avec succès.

## Structure du Carnet d'Ordres

Le carnet d'ordres est divisé en trois tableaux principaux :

- **buyOrders** : Tableau contenant les ordres d'achat en attente.
- **sellOrders** : Tableau contenant les ordres de vente en attente.
- **executedOrders** : Historique des ordres exécutés.

Chaque ordre est représenté par la structure suivante :

```solidity
struct Order {
    address user;
    uint256 price;
    uint256 quantity;
    bool isBuyOrder;
    uint256 timestamp;
}
```

## Exemple d'utilisation

1. **Placer un ordre d'achat** :
   L'utilisateur appelle `placeBuyOrder` avec le prix et la quantité souhaités après avoir approuvé le contrat pour le transfert de `tokenA`.

2. **Placer un ordre de vente** :
   L'utilisateur appelle `placeSellOrder` avec le prix et la quantité souhaités après avoir approuvé le contrat pour le transfert de `tokenB`.

3. **Exécution automatique** :
   Si un ordre correspondant existe dans le carnet (prix et quantité compatibles), l'ordre est exécuté automatiquement, transférant `tokenA` à l'acheteur et `tokenB` au vendeur.

---

### Remarques importantes

- Les utilisateurs doivent approuver le contrat pour transférer les tokens via `IERC20.approve()` avant de placer des ordres.
- Si plusieurs ordres ont le même prix, l'exécution est réalisée sur la base du premier ordre placé (FIFO).
- Les ordres ne sont exécutés que si les prix et les quantités correspondent exactement.