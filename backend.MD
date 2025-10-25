# Backend Architecture Guide: $zCoin Launchpad

This document provides a detailed overview of the backend architecture for the **$zCoin Launchpad**. The server is a single-file Node.js application built with Express.js, designed to support the `index.html` frontend with data persistence, Solana blockchain interactions, and real-time features.

## Table of Contents

1.  [Overall Philosophy](#1-overall-philosophy)
2.  [Setup & Configuration](#2-setup--configuration)
3.  [Core Technologies](#3-core-technologies)
4.  [Architecture Overview](#4-architecture-overview)
    - [Server & Middleware](#server--middleware)
    - [Database (LowDB)](#database-lowdb)
    - [Solana Integration](#solana-integration)
5.  [API Endpoints](#5-api-endpoints)
6.  [Background Processes](#6-background-processes)
7.  [Real-time Communication (WebSockets)](#7-real-time-communication-websockets)

---

### 1. Overall Philosophy

The backend is built for simplicity, rapid development, and easy deployment, especially on platforms like Render.

-   **Minimalist Stack:** It uses Express.js for the server and LowDB for the database, avoiding the complexity of larger database systems.
-   **Server-Side Wallet:** The server holds a master "hot wallet" derived from the `WALLET_SECRET`. This wallet is used to co-sign specific transactions (like token creation) that require a signature from the mint keypair, which is managed by the server.
-   **Backend-for-Frontend (BFF):** It acts as a dedicated backend for the single-page frontend, providing tailored endpoints and aggregating data from both its internal database and external services like the Jupiter API.
-   **Asynchronous Operations:** All blockchain and external API interactions use `async/await` to remain non-blocking and efficient.

### 2. Setup & Configuration

To run this server locally, you'll need Node.js and npm installed.

1.  **Clone the repository** and navigate into the project directory.

2.  **Install dependencies:**
    ```bash
    npm install
    ```

3.  **Create an `.env` file** in the root of the project with the following variables:
    ```env
    # Your server's primary Solana wallet secret key (base58 encoded)
    WALLET_SECRET="YOUR_WALLET_SECRET_KEY_HERE"

    # Your Pinata JWT for uploading to IPFS
    PINATA_JWT="YOUR_PINATA_JWT_HERE"

    # Set to 'true' when deploying to a service like Render to use correct file paths
    RENDER="false"
    ```

4.  **Required Files:** Ensure these files are in the project root:
    -   `quests.json`: A JSON array defining all available user quests.
    -   `configs.json`: A JSON object mapping quote assets (e.g., "SOL", "USDC") to their Meteora configuration public keys.
    -   A `vanity/` directory containing pre-generated Solana keypair `.json` files. The server uses one of these for each new token mint.

5.  **Run the server:**
    ```bash
    node server.js
    ```
    The server will start, typically on port 3000.

---

### 3. Core Technologies

-   **Express.js:** A minimal and flexible Node.js web application framework used to create the server and define API routes.
-   **LowDB:** A simple, file-based JSON database. It's used to persist data about tokens, trades, user profiles (wallets), and comments directly in a `db.json` file.
-   **Solana Web3.js:** The core library for interacting with the Solana blockchain. It's used for creating connections, handling public keys, and (de)serializing transactions.
-   **Meteora SDK:** The `@meteora-ag/dynamic-bonding-curve-sdk` is used specifically to construct the transactions required to create new bonding curve pools.
-   **Pinata SDK:** Used to upload token metadata (JSON) and images to IPFS, making them permanently accessible.
-   **Multer:** A middleware for handling `multipart/form-data`, used for processing token image uploads.
-   **WebSocket (ws):** Implements the real-time chat functionality, allowing clients to subscribe to token-specific chat rooms.

---

### 4. Architecture Overview

#### Server & Middleware

-   The application starts by initializing an `express` app and an `http` server. The HTTP server is passed to the `WebSocketServer` to handle both API requests and real-time connections on the same port.
-   **Middleware:**
    -   `express.static('public')`: Serves the `index.html` file and any other static assets.
    -   `express.json()`: Parses incoming JSON request bodies.
    -   `multer`: Handles file uploads for the token creation endpoint.

#### Database (LowDB)

The server uses a single `db.json` file to store all persistent state.

-   **`tokens`**: An array of objects, where each object represents a token created on the platform. It stores metadata like `name`, `symbol`, `deployer`, `pool` address, and `migrated` status.
-   **`trades`**: An array that logs every trade fetched from the Jupiter API. This is used for historical analysis and powering the "Quest Engine".
-   **`wallets`**: Stores user profiles. Each object contains a wallet `address`, `points`, `completedQuests`, and a `nickname`. This is the core of the leaderboard and quest system.
-   **`comments`**: An array of all comments made on tokens, linking a `wallet`, `tokenMint`, and `text`.

#### Solana Integration

-   **Server Wallet:** The server loads a `Keypair` from the `WALLET_SECRET`. This wallet is *not* used for creating pools itself, but rather for co-signing. The actual mint authority comes from the pre-generated vanity keypairs.
-   **Transaction Flow (Token Creation):** The token creation process is a secure, three-step dance between the client and server:
    1.  **`POST /create`**: The client sends token metadata. The server uploads the metadata to IPFS, grabs a vanity keypair for the mint, and uses the Meteora SDK to construct an unsigned transaction. This transaction is sent back to the client as a base64 string.
    2.  **Client-Side Signing**: The user signs the transaction in their wallet.
    3.  **`POST /sign-and-send`**: The client sends the partially signed transaction back. The server loads the corresponding mint keypair from the `vanity/` directory, co-signs the transaction, and sends it to the Solana network.
    4.  **`POST /confirm-creation`**: After the transaction is sent, the client calls this endpoint with the signature. The server confirms the transaction on-chain, finds the newly created pool address from the transaction logs, and saves the token's final details to the database.

---

### 5. API Endpoints

The server exposes a RESTful API for the frontend.

| Method | Endpoint                    | Description                                                              |
| :----- | :-------------------------- | :----------------------------------------------------------------------- |
| `POST` | `/create`                   | **1/3 Token Creation**: Prepares a transaction for the user to sign.     |
| `POST` | `/sign-and-send`            | **2/3 Token Creation**: Co-signs and sends the user-signed transaction.  |
| `POST` | `/confirm-creation`         | **3/3 Token Creation**: Confirms the transaction and saves token data.   |
| `GET`  | `/all-tokens`               | Fetches all platform tokens, enriched with live Jupiter API data.        |
| `GET`  | `/tokens?deployer=[address]`| Fetches tokens deployed by a specific wallet.                            |
| `POST` | `/quote-fees`               | Fetches claimable fee amounts for a list of pool addresses.              |
| `POST` | `/claim-fees`               | Creates a transaction for a user to claim their creator fees.            |
| `GET`  | `/platform-stats`           | Retrieves aggregate stats like 24h volume, new tokens, and top lists.    |
| `GET`  | `/api/leaderboard`          | Returns a paginated and searchable list of top traders by points.        |
| `GET`  | `/api/quests`               | Returns the master list of all available quests.                         |
| `GET`  | `/api/wallet/:address`      | Fetches a user's profile, including points and completed quests.         |
| `GET`  | `/api/comments/:tokenMint`  | Retrieves all recent comments for a specific token.                      |
| `POST` | `/api/comments`             | Submits a new comment for a token.                                       |
| `POST` | `/api/nickname`             | Sets or updates a user's nickname, with a monthly change limit.          |
| `GET`  | `/token-image`              | Serves token images from a local cache to reduce external requests.      |

---

### 6. Background Processes

The server runs two critical background jobs using `setInterval`.

1.  **Data Engine (`updateDataEngine`)**
    -   **Frequency:** Runs every 30 seconds.
    -   **Purpose:** To keep the platform's trade history and quest progression up-to-date.
    -   **Process:**
        1.  It iterates through every token in the `tokens` database.
        2.  For each token, it fetches the 100 most recent transactions from the Jupiter Data API.
        3.  It filters out any trades that are already stored in the `trades` database.
        4.  If new trades are found, they are saved to `db.json`.
        5.  These new trades are then passed to the `processNewTradesForQuests` function, which checks if the trade's criteria (e.g., volume, timing) unlock any quests for the trader. If so, the user's profile in the `wallets` table is updated with the completed quest and awarded points.

2.  **Auto-Migration Engine (`autoMigratePools`)**
    -   **Frequency:** Runs every 30 seconds.
    -   **Purpose:** To automatically detect when a token's bonding curve is complete and it "graduates" to a standard liquidity pool on Meteora.
    -   **Process:**
        1.  It queries all tokens in the database that are not yet marked as `migrated: true`.
        2.  For each token, it uses the Meteora SDK's `getPoolCurveProgress` function to check the fill percentage of the bonding curve.
        3.  If the progress is >= 1 (100%), it updates the token's entry in the `db.json` file to `migrated: true`. This is a state change in our database only; no on-chain transaction is required from the server.

---

### 7. Real-time Communication (WebSockets)

A WebSocket server provides a live chat experience on the token insights page.

-   **Connection:** When a client connects, they send a `subscribe` message with a `token` mint address. The server then maps that client to a "room" for that token.
-   **Messaging:** When a client sends a `chatMessage`, the server identifies which room they are in and broadcasts that message to all other clients subscribed to the same room.
-   **State:** The chat history is stored in-memory in the `chatRooms` map and is ephemeral. Messages older than 2 minutes are automatically pruned to manage memory usage. This is separate from the persistent `/api/comments` functionality.
