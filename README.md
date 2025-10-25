<!--
  ZCOIN Launchpad — README.md
  Nerfed / Redacted: external RPC, program IDs, secrets, and file paths are templated.
-->

<p align="center">
  <img src="https://img.shields.io/badge/ZCOIN%20Launchpad-online-brightgreen?logo=solana" alt="status">
  <img src="https://img.shields.io/badge/Node.js-18%2B-026e00?logo=node.js&logoColor=white" alt="node">
  <img src="https://img.shields.io/badge/Express-4.x-black?logo=express" alt="express">
  <img src="https://img.shields.io/badge/Pinata-IPFS-blue?logo=pinboard" alt="pinata">
  <img src="https://img.shields.io/badge/Solana-Web3-purple?logo=solana" alt="solana">
</p>

<h1 align="center"> ZCOIN Launchpad — Server</h1>

<p align="center">
  A lightweight Node/Express backend for creating virtual token pools on Solana using
  Meteora DBC, uploading assets to IPFS via Pinata, caching images, live token chat via WebSockets,
  on-chain trade ingestion (Jupiter Data API), quests/points, leaderboards, and fee-claim helpers.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-MIT-informational" alt="license">
  <img src="https://img.shields.io/badge/Database-lowdb-lightgrey" alt="lowdb">
  <img src="https://img.shields.io/badge/WebSockets-ws-ff69b4" alt="ws">
</p>

 TL;DRPOST /create — build a new pool (and optional first buy), assets pinned to IPFS, returns a base64 tx for the client to sign.
POST /sign-and-send — server partially signs with the mint vanity keypair, broadcasts to Solana, returns signature.
POST /confirm-creation — verifies tx, extracts pool address, indexes token in lowdb, awards quests.
Realtime chat: WebSocket channels per-token.
Stats/feeds: platform stats, top tokens, historical charts, holders, leaderboard, bounties, comments, nicknames.
Nerfed/Redacted bits are templated like "<YOUR_...>". Replace with your real values.

Branding: All references updated to ZCOIN Launchpad / ZCOIN.
 BrandingProduct: ZCOIN Launchpad
Ticker/Examples: ZCOIN
Default site (example): https://0xzerebro.io/ (placeholder)

 Features Pool Creation via Meteora Dynamic Bonding Curve SDK
 IPFS Uploads (Pinata) for token image + metadata JSON
 lowdb JSON storage (tokens, trades, wallets, quests, comments)
 Realtime Chat per-token room (WebSockets)
 Trade Ingestion from Jupiter Data API
 Quests & Points engine (volume-based, flips, snipes, launches)
 Nicknames, Comments, Leaderboard
 Image Cache proxy with disk caching
 Platform Stats + Historical Stats
 Fee Quote & Claim helpers for DBC pools
 Auto-Migration status checker (marks pools as graduated)

 RequirementsNode.js 18+
A Solana mainnet RPC endpoint
A funded wallet secret key (Base58) for server-side signing of the mint (vanity) when finalizing tx
Pinata JWT for IPFS uploads

 File Structure (excerpt)

.
├── server.js # This server
├── db.json # lowdb storage (auto-created)
├── configs.json # Quote config mapping (quote => public key)
├── quests2.json # Quest catalog (fallback)
├── /public
│ └── zcoin.png # Fallback token image
├── /uploads # Multer temp (local)
└── /vanity # Mint vanity keypairs (.json), moved to /vanity/used after consumption

On Render: use /data/ for persistent volumes (paths are handled in code).
 Environment VariablesCreate a .env file:ini

# --- Required ---
WALLET_SECRET=<YOUR_SERVER_WALLET_SECRET_BASE58>
PINATA_JWT=<YOUR_PINATA_JWT>

# Optional overrides
PORT=3000
RENDER=false

# Solana RPC (REDACTED HERE)
SOLANA_RPC_URL=<YOUR_SOLANA_MAINNET_RPC_URL>  # e.g., https://<provider>/<key>
Note: The code currently defaults to a placeholder RPC in server; swap it to process.env.SOLANA_RPC_URL for production.

 Quick Startbash

# 1) Install
npm i

# 2) Prepare data dirs (local)
mkdir -p uploads vanity public image_cache
cp path/to/your/zcoin.png public/zcoin.png

# 3) Add configs.json (quote mint configs)
cat > configs.json <<'JSON'
{
  "SOL": "So11111111111111111111111111111111111111112",
  "USDC": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
}
JSON

# 4) Add quests2.json (sample)
echo '[]' > quests2.json  # or your real quests

# 5) Run
node server.js

Console:

ZCOIN Launchpad server running on http://localhost:3000

 Key Redactions (Nerfed)RPC URL → SOLANA_RPC_URL env.
Program IDs → keep your own; placeholders in docs.
External fee config list → example keys shown as comments.
Brand → ZCOIN Launchpad/ZCOIN.
Default links like createdOn set to https://0xzerebro.io/ (placeholder).

 REST APIUpload

POST /upload-file
multipart/form-data: file=<binary>, target=/data (optional)

Saves file to /data (Render) or local.Create Pool

POST /create
Content-Type: multipart/form-data
fields: name, symbol, description, website, twitter, quote (SOL|USDC|...), deployer (pubkey), initialBuyAmount (optional)
file: image (optional)

Pins image + metadata to IPFS (Pinata)Returns { transaction, baseMint, keypairFile, uri, imageUrl } (base64 tx unsigned by server).Sign & Send

POST /sign-and-send
{
  "userSignedTransaction": "<BASE64>",
  "keypairFile": "<FILENAME_FROM_CREATE>"
}

Server partial-signs with mint vanity keypair and broadcasts.Confirm Creation

POST /confirm-creation
{
  "signature": "<tx sig>",
  "baseMint": "<mint>",
  "quote": "SOL",
  "deployer": "<pubkey>",
  "name": "MyToken",
  "symbol": "ZCOIN",
  "description": "desc",
  "keypairFile": "<vanity.json>",
  "uri": "https://ipfs/...json",
  "website": "https://...",
  "twitter": "https://twitter.com/...",
  "imageUrl": "https://ipfs/...png"
}

Verifies chain tx and extracts pool address from instructions.Indexes token in DB, moves vanity key to /vanity/used/, and awards quests.Token Image Proxy (cached)

GET /token-image?url=<http-url>

Caches to /image_cache. On failure, returns /public/zcoin.png.Comments

GET  /api/comments/:tokenMint       # last 24h, enriched with nickname
POST /api/comments                   # { tokenMint, wallet, text }

Nickname

POST /api/nickname  # { walletAddress, nickname } (max 20 chars, 5 changes/month)

Leaderboard

GET /api/leaderboard?page=1&search=term

Top Tokens (by internal trade volume)

GET /api/top-tokens

Bounties (example/demo)

GET /api/bounties/:walletAddress

Copy updates: strings now reference ZCOIN Launchpad instead of old branding.Platform Stats

GET /platform-stats

Returns totals, top-5 by volume/mcap, and estimated platform earnings.Historical Stats (for charts)

GET /historical-stats

Wallet Profile

GET /api/profile/:walletAddress

Recent activity, unlocked achievements, basic holdings (via Jupiter holders).All Tokens / User Tokens

GET /all-tokens
GET /tokens?deployer=<pubkey>

DBC Fee Helpers

POST /quote-fees   # { poolAddresses: [ "...", ... ] } -> { [pool]: unclaimed }
POST /claim-fees   # { poolAddress, ownerWallet } -> { transaction }

 WebSocketsConnect to the same origin as HTTP.Messages:{"type":"subscribe","token":"<baseMint>"} — join room.
{"type":"chatMessage","wallet":"<pubkey>","text":"Hello"} — broadcast in room.

Server sends:{"type":"history","messages":[...]} — last 2 minutes.
{"type":"newMessage","message":{...}} — realtime.

Chat history pruned every 30s to keep last 2 minutes only. Quests & Points (Server Engine)Volume milestones, single large trades, first trade, pioneer (early buyers), sniper (<=30s after launch), flips (profit heuristic).New trades fetched every 30s from Jupiter Data API (nerfed URL pattern remains). Auto-Migration Checker (Simplified)Polls pools marked migrated: falseUses DBC client to read curve progressWhen progress >= 1.0 → sets migrated: trueNo tx sent; only status update in DB. Configsconfigs.json maps quote to its config public key (DBC blueprints):json

{
  "SOL": "So11111111111111111111111111111111111111112",
  "USDC": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
  "USD1": "USD1ttGY1N17NEEHLmELoaybftRBUSErhqYiQzvEmuB",
  "MET": "METvsvVRapdj9cFLzq4Tr43xK4tAjQfwX76z3n6mWQL"
}

Replace/extend with your actual DBC blueprint/config public keys. Metadata Template (Pinata)Example JSON the server pins:json

{
  "name": "My ZCOIN",
  "symbol": "ZCOIN",
  "description": "A ZCOIN Launchpad token.",
  "image": "ipfs://<CID>",
  "website": "https://0xzerebro.io/",
  "twitter": "https://twitter.com/zcoin",
  "createdOn": "https://0xzerebro.io/"
}

 Security NotesNever commit .env, vanity/ keys, or real RPC URLs.Rotate PINATA_JWT periodically; scope to minimal permissions.Use rate limiting and auth in production (endpoints accept public input).Consider moving partial signing to a hardened worker with strict allowlists. cURL Examplesbash

# Create (no image)
curl -X POST http://localhost:3000/create \
  -F name="ZCOIN Alpha" \
  -F symbol="ZCOIN" \
  -F description="Genesis token" \
  -F website="https://0xzerebro.io/" \
  -F twitter="https://twitter.com/zcoin" \
  -F quote="SOL" \
  -F deployer="<YOUR_PUBKEY>" \
  -F initialBuyAmount="0.5"

# Post a comment
curl -X POST http://localhost:3000/api/comments \
  -H 'Content-Type: application/json' \
  -d '{"tokenMint":"<MINT>","wallet":"<WALLET>","text":"wen moon?"}'

 TroubleshootingCould not load configs.json / quests2.json
Ensure files exist alongside server.js (or /data/ on Render).
Transaction not found on-chain in /confirm-creation
The server retries a few times; if still missing, increase RPC commitment or retries.
No fees to claim
API may return unclaimed: 0. Wait or verify pool ownership.

 LicenseMIT © ZCOIN Launchpad Contributors CreditsSolana Web3.js
Meteora DBC SDK
Jupiter Data API
Pinata SDK
ws, lowdb, multer
EOF

